import 'package:siddhivinayak_enterprise/core/models/employee_model.dart';
import 'package:siddhivinayak_enterprise/modules/payroll/repositories/employee_repository.dart';
import 'package:siddhivinayak_enterprise/modules/payroll/repositories/aadhaar_repository.dart';
import 'package:siddhivinayak_enterprise/modules/payroll/services/image_storage_service.dart';

class EmployeeService {
  final EmployeeRepository _repository;
  final AadhaarRepository? _aadhaarRepository;
  final ImageStorageService? _imageStorageService;

  EmployeeService(
    this._repository, {
    AadhaarRepository? aadhaarRepository,
    ImageStorageService? imageStorageService,
  })  : _aadhaarRepository = aadhaarRepository,
        _imageStorageService = imageStorageService;

  Future<List<EmployeeModel>> getAllEmployees() => _repository.getAll();

  Future<EmployeeModel?> getEmployee(String id) => _repository.getById(id);

  Future<void> saveEmployee(EmployeeModel employee) =>
      _repository.save(employee);

  Future<void> updateEmployee(EmployeeModel employee) =>
      _repository.update(employee);

  Future<void> deleteEmployee(String id) => _repository.delete(id);

  Future<List<EmployeeModel>> searchEmployees(String query) =>
      _repository.search(query);

  // ─────────────────────────────────────────────────────────────────────────────
  // Aadhaar Image Operations
  // ─────────────────────────────────────────────────────────────────────────────

  /// Upload Aadhaar image for employee
  Future<String?> uploadAadhaarImage({
    required String employeeId,
    required String filePath,
    String? originalFileName,
  }) async {
    try {
      if (_imageStorageService == null) {
        throw Exception('Image storage service not initialized');
      }

      // Save file to storage
      final savedPath = await _imageStorageService!.saveImageFile(
        filePath: filePath,
        employeeId: employeeId,
        originalFileName: originalFileName,
      );

      // Update employee model with image path
      final employee = await _repository.getById(employeeId);
      if (employee != null) {
        final updatedEmployee = employee.copyWith(
          aadhaarImagePath: savedPath,
          updatedAt: DateTime.now(),
        );
        await _repository.update(updatedEmployee);
      }

      return savedPath;
    } catch (e, stackTrace) {
      throw Exception('Failed to upload Aadhaar image: ${e.toString()}');
    }
  }

  /// Remove Aadhaar image for employee
  Future<void> removeAadhaarImage(String employeeId) async {
    try {
      // Delete image file from storage
      if (_imageStorageService != null) {
        final imagePath = await _imageStorageService!.getEmployeeAadhaarImagePath(employeeId);
        if (imagePath != null) {
          await _imageStorageService!.deleteImageFile(imagePath);
        }
      }

      // Update employee model
      final employee = await _repository.getById(employeeId);
      if (employee != null) {
        final updatedEmployee = employee.copyWith(
          aadhaarImagePath: null,
          updatedAt: DateTime.now(),
        );
        await _repository.update(updatedEmployee);
      }
    } catch (e, stackTrace) {
      throw Exception('Failed to remove Aadhaar image: ${e.toString()}');
    }
  }

  /// Get employee Aadhaar image path
  Future<String?> getEmployeeAadhaarImagePath(String employeeId) async {
    try {
      // First check if employee model has image path
      final employee = await _repository.getById(employeeId);
      if (employee?.aadhaarImagePath != null) {
        return employee!.aadhaarImagePath;
      }

      // Fallback: check storage directory
      if (_imageStorageService != null) {
        return await _imageStorageService!.getEmployeeAadhaarImagePath(employeeId);
      }

      return null;
    } catch (e, stackTrace) {
      return null;
    }
  }

  /// Check if employee has Aadhaar image
  Future<bool> hasAadhaarImage(String employeeId) async {
    try {
      final employee = await _repository.getById(employeeId);
      if (employee?.aadhaarImagePath != null) {
        return true;
      }

      if (_imageStorageService != null) {
        final path = await _imageStorageService!.getEmployeeAadhaarImagePath(employeeId);
        return path != null;
      }

      return false;
    } catch (e) {
      return false;
    }
  }
}
