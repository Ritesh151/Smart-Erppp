import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'package:siddhivinayak_enterprise/core/models/employee_model.dart';
import 'package:siddhivinayak_enterprise/core/utils/logger.dart';
import 'package:siddhivinayak_enterprise/modules/payroll/services/employee_service.dart';
import 'package:siddhivinayak_enterprise/modules/payroll/services/image_storage_service.dart';
import 'package:siddhivinayak_enterprise/modules/payroll/utils/image_helper.dart';

class EmployeeProvider extends ChangeNotifier {
  final EmployeeService _service;
  final ImageStorageService? _imageStorageService;

  List<EmployeeModel> _employees = [];
  bool _isLoading = false;
  String? _error;

  // Image upload state
  bool _isUploadingImage = false;
  String? _uploadError;
  String? _uploadSuccess;

  // Image preview state
  String? _previewImageFile;

  List<EmployeeModel> get employees => _employees;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isUploadingImage => _isUploadingImage;
  String? get uploadError => _uploadError;
  String? get uploadSuccess => _uploadSuccess;
  String? get previewImageFile => _previewImageFile;

  EmployeeProvider(this._service, {ImageStorageService? imageStorageService})
      : _imageStorageService = imageStorageService;

  Future<void> loadEmployees() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _employees = await _service.getAllEmployees();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addEmployee(EmployeeModel employee) async {
    try {
      await _service.saveEmployee(employee);
      await loadEmployees();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateEmployee(EmployeeModel employee) async {
    try {
      await _service.updateEmployee(employee);
      await loadEmployees();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteEmployee(String id) async {
    try {
      await _service.deleteEmployee(id);
      await loadEmployees();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Aadhaar Image Operations
  // ─────────────────────────────────────────────────────────────────────────────

  /// Upload Aadhaar image for employee
  Future<bool> uploadAadhaarImage({
    required String employeeId,
    required String filePath,
    String? originalFileName,
  }) async {
    try {
      _isUploadingImage = true;
      _uploadError = null;
      _uploadSuccess = null;
      notifyListeners();

      final savedPath = await _service.uploadAadhaarImage(
        employeeId: employeeId,
        filePath: filePath,
        originalFileName: originalFileName,
      );

      if (savedPath != null) {
        _uploadSuccess = 'Aadhaar image uploaded successfully';
        await loadEmployees();
      }

      _isUploadingImage = false;
      notifyListeners();
      return savedPath != null;
    } catch (e, stackTrace) {
      _isUploadingImage = false;
      _uploadError = e.toString();
      Logger.error('Failed to upload Aadhaar image', e, stackTrace);
      notifyListeners();
      return false;
    }
  }

  /// Remove Aadhaar image for employee
  Future<bool> removeAadhaarImage(String employeeId) async {
    try {
      _isUploadingImage = true;
      _uploadError = null;
      _uploadSuccess = null;
      notifyListeners();

      await _service.removeAadhaarImage(employeeId);
      _uploadSuccess = 'Aadhaar image removed';
      await loadEmployees();

      _isUploadingImage = false;
      notifyListeners();
      return true;
    } catch (e, stackTrace) {
      _isUploadingImage = false;
      _uploadError = e.toString();
      Logger.error('Failed to remove Aadhaar image', e, stackTrace);
      notifyListeners();
      return false;
    }
  }

  /// Get employee Aadhaar image path
  Future<String?> getAadhaarImagePath(String employeeId) async {
    try {
      return await _service.getEmployeeAadhaarImagePath(employeeId);
    } catch (e) {
      return null;
    }
  }

  /// Check if employee has Aadhaar image
  Future<bool> hasAadhaarImage(String employeeId) async {
    try {
      return await _service.hasAadhaarImage(employeeId);
    } catch (e) {
      return false;
    }
  }

  /// Clear upload errors
  void clearUploadError() {
    _uploadError = null;
    notifyListeners();
  }

  /// Clear upload success message
  void clearUploadSuccess() {
    _uploadSuccess = null;
    notifyListeners();
  }

  /// Clear all messages
  void clearMessages() {
    clearUploadError();
    clearUploadSuccess();
  }

  /// Set preview image file
  void setPreviewImageFile(String? filePath) {
    _previewImageFile = filePath;
    notifyListeners();
  }

  /// Clear preview image
  void clearPreviewImage() {
    _previewImageFile = null;
    notifyListeners();
  }
}
