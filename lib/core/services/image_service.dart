import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:SmartERP/core/utils/logger.dart';
import 'package:uuid/uuid.dart';

class ImageService {
  final ImagePicker _picker = ImagePicker();

  Future<String?> pickFromCamera() async {
    try {
      final XFile? file = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 60,
        maxWidth: 600,
        maxHeight: 600,
      );
      if (file != null) {
        return _processPickedFile(file);
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
        imageQuality: 60,
        maxWidth: 600,
        maxHeight: 600,
      );
      if (file != null) {
        return _processPickedFile(file);
      }
      return null;
    } catch (e, stackTrace) {
      Logger.error('Failed to pick image from gallery', e, stackTrace);
      return null;
    }
  }

  Future<String?> _processPickedFile(XFile file) async {
    try {
      if (kIsWeb) {
        final Uint8List bytes = await file.readAsBytes();
        final ext = p.extension(file.name).toLowerCase();
        final mimeType = _mimeFromExtension(ext);
        final b64 = base64Encode(bytes);
        final dataUri = 'data:$mimeType;base64,$b64';
        Logger.success('Processed web image: ${dataUri.length} chars');
        return dataUri;
      } else {
        return await _saveToLocal(File(file.path));
      }
    } catch (e, stackTrace) {
      Logger.error('Failed to process picked file', e, stackTrace);
      return null;
    }
  }

  Future<String> _saveToLocal(File image) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final imagesDir = Directory(p.join(directory.path, 'products'));
      if (!await imagesDir.exists()) {
        await imagesDir.create(recursive: true);
      }
      final ext = p.extension(image.path);
      final fileName = '${const Uuid().v4()}${ext.isEmpty ? '.jpg' : ext}';
      final localPath = p.join(imagesDir.path, fileName);
      final savedFile = await image.copy(localPath);
      Logger.success('Saved image locally: $localPath');
      return savedFile.path;
    } catch (e, stackTrace) {
      Logger.error('Failed to save image locally', e, stackTrace);
      rethrow;
    }
  }

  Future<void> deleteImage(String imagePath) async {
    if (kIsWeb || imagePath.startsWith('data:')) return;
    try {
      final file = File(imagePath);
      if (await file.exists()) {
        await file.delete();
        Logger.success('Deleted image: $imagePath');
      }
    } catch (e, stackTrace) {
      Logger.error('Failed to delete image: $imagePath', e, stackTrace);
    }
  }

  String _mimeFromExtension(String ext) {
    switch (ext) {
      case '.png':
        return 'image/png';
      case '.gif':
        return 'image/gif';
      case '.webp':
        return 'image/webp';
      default:
        return 'image/jpeg';
    }
  }
}
