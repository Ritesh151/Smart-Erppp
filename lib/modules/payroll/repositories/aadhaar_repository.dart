import 'package:siddhivinayak_enterprise/core/exceptions/app_exception.dart';
import 'package:siddhivinayak_enterprise/core/storage/storage_service.dart';
import 'package:siddhivinayak_enterprise/core/utils/logger.dart';
import 'package:siddhivinayak_enterprise/modules/payroll/models/aadhaar_image_model.dart';

/// Aadhaar Repository handles all data persistence for employee Aadhaar images
class AadhaarRepository {
  final StorageService<Map<dynamic, dynamic>> _storage;

  AadhaarRepository(this._storage);

  /// Save Aadhaar image record
  Future<void> saveAadhaarImage(AadhaarImageModel image) async {
    try {
      await _storage.save(image.id, image.toJson());
      Logger.success('Aadhaar image saved: ${image.id}');
    } catch (e, stackTrace) {
      Logger.error('Failed to save aadhaar image', e, stackTrace);
      throw StorageException('Failed to save aadhaar image');
    }
  }

  /// Get Aadhaar image by employee ID
  Future<AadhaarImageModel?> getByEmployeeId(String employeeId) async {
    try {
      final images = await getAll();
      return images.where((i) => i.employeeId == employeeId).firstOrNull;
    } catch (e, stackTrace) {
      Logger.error('Failed to get aadhaar image by employee id', e, stackTrace);
      return null;
    }
  }

  /// Get all Aadhaar images
  Future<List<AadhaarImageModel>> getAll() async {
    try {
      final data = _storage.getAll();
      return data
          .map((item) => AadhaarImageModel.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    } catch (e, stackTrace) {
      Logger.error('Failed to get all aadhaar images', e, stackTrace);
      throw StorageException('Failed to retrieve aadhaar images');
    }
  }

  /// Get Aadhaar image by ID
  Future<AadhaarImageModel?> getById(String id) async {
    try {
      final data = _storage.get(id);
      if (data == null) return null;
      return AadhaarImageModel.fromJson(Map<String, dynamic>.from(data));
    } catch (e, stackTrace) {
      Logger.error('Failed to get aadhaar image by id', e, stackTrace);
      return null;
    }
  }

  /// Update Aadhaar image record
  Future<void> update(AadhaarImageModel image) async {
    try {
      await _storage.update(image.id, image.toJson());
      Logger.success('Aadhaar image updated: ${image.id}');
    } catch (e, stackTrace) {
      Logger.error('Failed to update aadhaar image', e, stackTrace);
      throw StorageException('Failed to update aadhaar image');
    }
  }

  /// Delete Aadhaar image record
  Future<void> delete(String id) async {
    try {
      await _storage.delete(id);
      Logger.success('Aadhaar image deleted: $id');
    } catch (e, stackTrace) {
      Logger.error('Failed to delete aadhaar image', e, stackTrace);
      throw StorageException('Failed to delete aadhaar image');
    }
  }

  /// Delete Aadhaar image by employee ID
  Future<void> deleteByEmployeeId(String employeeId) async {
    try {
      final image = await getByEmployeeId(employeeId);
      if (image != null) {
        await delete(image.id);
      }
    } catch (e, stackTrace) {
      Logger.error('Failed to delete aadhaar image by employee id', e, stackTrace);
    }
  }

  /// Check if employee has Aadhaar image
  Future<bool> hasAadhaarImage(String employeeId) async {
    try {
      final image = await getByEmployeeId(employeeId);
      return image != null;
    } catch (e, stackTrace) {
      return false;
    }
  }

  /// Get total count of Aadhaar images
  Future<int> getTotalCount() async {
    try {
      return _storage.length;
    } catch (e, stackTrace) {
      Logger.error('Failed to get aadhaar image count', e, stackTrace);
      return 0;
    }
  }

  /// Clear all records (but not files)
  Future<void> clearAll() async {
    try {
      await _storage.clear();
      Logger.info('Aadhaar image records cleared');
    } catch (e, stackTrace) {
      Logger.error('Failed to clear aadhaar images', e, stackTrace);
      throw StorageException('Failed to clear aadhaar images');
    }
  }
}

extension FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
