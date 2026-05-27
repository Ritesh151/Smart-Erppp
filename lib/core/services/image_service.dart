import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:smarterp/core/utils/logger.dart';
import 'package:uuid/uuid.dart';

class ImageService {
  final ImagePicker _picker = ImagePicker();

  Future<String?> pickFromCamera() async {
    try {
      final XFile? file = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 75,
        maxWidth: 800,
        maxHeight: 800,
      );
      if (file != null) {
        return await saveImage(File(file.path));
      }
      return null;
    } catch (e, stackTrace) {
      Logger.error('Failed to pick image from camera', e, stackTrace);
      return null;
    }
  }

  Future<String?> pickFromGallery() async {
    try {
      final XFile? file = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 75,
        maxWidth: 800,
        maxHeight: 800,
      );
      if (file != null) {
        return await saveImage(File(file.path));
      }
      return null;
    } catch (e, stackTrace) {
      Logger.error('Failed to pick image from gallery', e, stackTrace);
      return null;
    }
  }

  Future<String> saveImage(File image) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      // Ensure the images subdirectory exists
      final imagesDir = Directory(path.join(directory.path, 'products'));
      if (!await imagesDir.exists()) {
        await imagesDir.create(recursive: true);
      }
      
      final String extension = path.extension(image.path).isEmpty ? '.jpg' : path.extension(image.path);
      final String fileName = '${const Uuid().v4()}$extension';
      final String localPath = path.join(imagesDir.path, fileName);
      
      final File savedFile = await image.copy(localPath);
      Logger.success('Saved image locally: $localPath');
      return savedFile.path;
    } catch (e, stackTrace) {
      Logger.error('Failed to save image locally', e, stackTrace);
      rethrow;
    }
  }

  Future<void> deleteImage(String filePath) async {
    try {
      final File file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        Logger.success('Deleted image: $filePath');
      }
    } catch (e, stackTrace) {
      Logger.error('Failed to delete image: $filePath', e, stackTrace);
    }
  }
}
