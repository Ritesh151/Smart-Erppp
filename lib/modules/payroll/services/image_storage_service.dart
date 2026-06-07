import 'dart:io' show Directory, File, Platform;

import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:siddhivinayak_enterprise/core/exceptions/app_exception.dart';
import 'package:siddhivinayak_enterprise/core/utils/logger.dart';
import 'package:siddhivinayak_enterprise/modules/payroll/utils/image_helper.dart';

/// Image Storage Service handles local image file storage operations
class ImageStorageService {
  static const String _appImagesDir = 'app_images';
  static const String _employeesDir = 'employees';
  static const int _maxFileSize = 5 * 1024 * 1024; // 5MB

  /// Get the base directory for storing images
  Future<String> getBaseDirectory() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      return appDir.path;
    } catch (e, stackTrace) {
      Logger.error('Failed to get application documents directory', e, stackTrace);
      throw StorageException('Failed to get storage directory');
    }
  }

  /// Get the directory for employee images
  Future<String> getEmployeeImagesDirectory() async {
    try {
      final baseDir = await getBaseDirectory();
      final dir = Directory(path.join(baseDir, _appImagesDir, _employeesDir));
      
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
      
      return dir.path;
    } catch (e, stackTrace) {
      Logger.error('Failed to get employee images directory', e, stackTrace);
      throw StorageException('Failed to get employee images directory');
    }
  }

  /// Save image file to storage
  /// Returns the file path where the image was saved
  Future<String> saveImageFile({
    required String filePath,
    required String employeeId,
    String? originalFileName,
  }) async {
    try {
      // Validate input file exists
      final inputFile = File(filePath);
      if (!await inputFile.exists()) {
        throw ValidationException('Source file does not exist');
      }

      // Validate file size
      final stat = await inputFile.stat();
      if (stat.size > _maxFileSize) {
        throw ValidationException('File size exceeds 5MB limit');
      }

      // Validate image format
      final fileExtension = path.extension(filePath).toLowerCase();
      if (!ImageHelper.isSupportedFormat(fileExtension)) {
        throw ValidationException('Unsupported image format');
      }

      // Get employee images directory
      final empDir = await getEmployeeImagesDirectory();

      // Generate unique filename
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'aadhaar_${employeeId}_$timestamp$fileExtension';
      final destinationPath = path.join(empDir, fileName);

      // Copy file to destination
      final file = File(filePath);
      await file.copy(destinationPath);

      Logger.success('Image saved: $destinationPath');
      return destinationPath;
    } on ValidationException {
      rethrow;
    } catch (e, stackTrace) {
      Logger.error('Failed to save image file', e, stackTrace);
      throw StorageException('Failed to save image file');
    }
  }

  /// Get image file path for employee
  Future<String?> getEmployeeAadhaarImagePath(String employeeId) async {
    try {
      final empDir = await getEmployeeImagesDirectory();
      final dir = Directory(empDir);
      
      if (!await dir.exists()) return null;

      // Find files matching employee ID
      final files = dir.listSync();
      for (final entity in files) {
        if (entity is File) {
          final fileName = path.basename(entity.path);
          if (fileName.startsWith('aadhaar_$employeeId')) {
            return entity.path;
          }
        }
      }
      
      return null;
    } catch (e, stackTrace) {
      Logger.error('Failed to get employee aadhaar image path', e, stackTrace);
      return null;
    }
  }

  /// Delete image file from storage
  Future<void> deleteImageFile(String imagePath) async {
    try {
      final file = File(imagePath);
      
      if (await file.exists()) {
        await file.delete();
        Logger.success('Image deleted: $imagePath');
      }
    } catch (e, stackTrace) {
      Logger.error('Failed to delete image file', e, stackTrace);
      throw StorageException('Failed to delete image file');
    }
  }

  /// Check if image file exists
  Future<bool> imageFileExists(String imagePath) async {
    try {
      final file = File(imagePath);
      return await file.exists();
    } catch (e) {
      return false;
    }
  }

  /// Get image file size
  Future<int?> getImageFileSize(String imagePath) async {
    try {
      final file = File(imagePath);
      if (await file.exists()) {
        final stat = await file.stat();
        return stat.size;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Validate image file
  Future<bool> validateImageFile(String imagePath) async {
    try {
      final file = File(imagePath);
      if (!await file.exists()) return false;

      final stat = await file.stat();
      if (stat.size == 0 || stat.size > _maxFileSize) return false;

      // Check file extension
      final ext = path.extension(imagePath).toLowerCase();
      return ImageHelper.isSupportedFormat(ext);
    } catch (e) {
      return false;
    }
  }

  /// Clear all employee images
  Future<void> clearAllEmployeeImages() async {
    try {
      final empDir = await getEmployeeImagesDirectory();
      final dir = Directory(empDir);
      
      if (await dir.exists()) {
        final files = dir.listSync();
        for (final entity in files) {
          if (entity is File) {
            await entity.delete();
          }
        }
        Logger.success('All employee images cleared');
      }
    } catch (e, stackTrace) {
      Logger.error('Failed to clear employee images', e, stackTrace);
      throw StorageException('Failed to clear employee images');
    }
  }

  /// Get supported image extensions
  static List<String> getSupportedExtensions = const [
    '.jpg',
    '.jpeg',
    '.png',
  ];

  /// Check if format is supported
  static bool isSupportedFormat(String extension) {
    final ext = extension.toLowerCase();
    return getSupportedExtensions.contains(ext);
  }

  /// Validate image file before saving
  void validateImageBeforeUpload(String filePath) {
    if (filePath.isEmpty) {
      throw ValidationException('No file selected');
    }

    final ext = path.extension(filePath).toLowerCase();
    if (!isSupportedFormat(ext)) {
      throw ValidationException('Invalid image format. Use JPG, JPEG, or PNG');
    }
  }
}
