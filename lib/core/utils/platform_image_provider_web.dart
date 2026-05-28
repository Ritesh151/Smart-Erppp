import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/widgets.dart';

ImageProvider? platformImageProvider(String path) {
  if (path.isEmpty) return null;

  if (path.startsWith('data:')) {
    final parts = path.split(',');
    if (parts.length < 2) return null;
    try {
      final bytes = base64Decode(parts[1]);
      if (bytes.isEmpty) return null;
      return MemoryImage(Uint8List.fromList(bytes));
    } catch (_) {
      return null;
    }
  }

  try {
    return NetworkImage(path);
  } catch (_) {
    return null;
  }
}
