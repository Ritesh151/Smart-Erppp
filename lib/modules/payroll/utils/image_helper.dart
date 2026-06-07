import 'dart:convert';
import 'dart:io' show File, Platform;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:siddhivinayak_enterprise/core/utils/platform_image_provider.dart';

/// Image Helper handles image-related utilities and platform-specific operations
class ImageHelper {
  /// Check if running on Android
  static bool isAndroid() => Platform.isAndroid;

  static bool isIOS() => Platform.isIOS;

  static bool isWeb() => kIsWeb;

  static bool isWindows() => Platform.isWindows;

  static bool isMacOS() => Platform.isMacOS;

  static bool isLinux() => Platform.isLinux;

  static bool supportsImagePicker() =>
      isAndroid() || isIOS() || isWindows() || isMacOS() || isLinux();

  static bool supportsCamera() => isAndroid() || isIOS();

  static List<String> getSupportedExtensions = const ['.jpg', '.jpeg', '.png'];

  static bool isSupportedFormat(String extension) {
    final ext = extension.toLowerCase();
    return getSupportedExtensions.contains(ext);
  }

  static bool isValidImageFile(String filePath) {
    try {
      if (isWeb()) return true;
      final file = File(filePath);
      if (!file.existsSync()) return false;
      final ext = path.extension(filePath).toLowerCase();
      if (!isSupportedFormat(ext)) return false;
      final length = file.lengthSync();
      if (length == 0 || length > 5 * 1024 * 1024) return false;
      return true;
    } catch (e) {
      return false;
    }
  }

  static ImagePicker getImagePicker() => ImagePicker();

  static List<ImageSource> getSupportedSources() {
    final sources = <ImageSource>[ImageSource.gallery];
    if (supportsCamera()) sources.add(ImageSource.camera);
    return sources;
  }

  static Future<String?> pickImageFromGallery() async {
    try {
      final picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      return pickedFile?.path;
    } catch (e) {
      return null;
    }
  }

  static Future<String?> pickImageFromCamera() async {
    try {
      if (!supportsCamera()) return null;
      final picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      return pickedFile?.path;
    } catch (e) {
      return null;
    }
  }

  static Future<String?> pickImageFromFilePicker() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png'],
        withData: isWeb(),
      );
      if (result == null || result.files.isEmpty) return null;
      final file = result.files.first;
      if (isWeb() && file.bytes != null) {
        return 'data:image/${path.extension(file.name).replaceAll('.', '')};base64,${base64Encode(file.bytes!)}';
      }
      return file.path;
    } catch (e) {
      return null;
    }
  }

  static String? getImageExtension(String filePath) {
    try {
      if (filePath.startsWith('data:')) {
        final mime = filePath.split(';')[0].split(':')[1];
        return getExtensionFromMimeType(mime);
      }
      final ext = path.extension(filePath);
      return ext.isNotEmpty ? ext : null;
    } catch (e) {
      return null;
    }
  }

  static String? getImageType(String filePath) {
    final ext = getImageExtension(filePath)?.toLowerCase();
    switch (ext) {
      case '.jpg':
      case '.jpeg':
        return 'image/jpeg';
      case '.png':
        return 'image/png';
      default:
        return null;
    }
  }

  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  static const int maxFileSize = 5 * 1024 * 1024;

  static bool isValidFileSize(int fileSize) =>
      fileSize > 0 && fileSize <= maxFileSize;

  static List<ImageSource> getImageOptions() {
    if (isAndroid() || isIOS()) {
      return [ImageSource.gallery, ImageSource.camera];
    }
    return [ImageSource.gallery];
  }

  static bool get hasCamera => supportsCamera();

  static String getPlatformName() {
    if (isAndroid()) return 'Android';
    if (isIOS()) return 'iOS';
    if (isWindows()) return 'Windows';
    if (isMacOS()) return 'macOS';
    if (isLinux()) return 'Linux';
    if (isWeb()) return 'Web';
    return 'Unknown';
  }

  static String? getExtensionFromMimeType(String mimeType) {
    switch (mimeType) {
      case 'image/jpeg':
      case 'image/jpg':
        return '.jpg';
      case 'image/png':
        return '.png';
      default:
        return null;
    }
  }

  static String? getMimeTypeFromExtension(String extension) {
    final ext = extension.toLowerCase();
    switch (ext) {
      case '.jpg':
      case '.jpeg':
        return 'image/jpeg';
      case '.png':
        return 'image/png';
      default:
        return null;
    }
  }

  static ImageProvider? getImageProvider(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) return null;
    return platformImageProvider(imagePath);
  }

  static Future<String> pickImage() async {
    final sources = getSupportedSources();
    if (sources.length == 1) {
      final path = await pickImageFromGallery();
      if (path != null) return path;
    }
    final path = await pickImageFromGallery();
    if (path != null) return path;
    throw Exception('No image selected');
  }
}
