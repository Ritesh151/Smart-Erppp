import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

class ExportSuccessDialog extends StatelessWidget {
  final String filePath;
  final String fileType;

  const ExportSuccessDialog({
    super.key,
    required this.filePath,
    this.fileType = 'Invoice',
  });

  Future<void> _openFolder() async {
    final dir = File(filePath).parent;
    try {
      if (Platform.isWindows) {
        await Process.run('explorer', [dir.path]);
      } else if (Platform.isLinux) {
        await Process.run('xdg-open', [dir.path]);
      } else if (Platform.isMacOS) {
        await Process.run('open', [dir.path]);
      }
    } catch (_) {
      // Silently fail - the dialog is already shown
    }
  }

  @override
  Widget build(BuildContext context) {
    final fileName = filePath.split(Platform.pathSeparator).last;
    final dirPath = File(filePath).parent.path;

    return AlertDialog(
      backgroundColor: const Color(0xFFF5F7FA),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      title: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.check_circle_rounded,
                color: Color(0xFF10B981), size: 20),
          ),
          const SizedBox(width: 12),
          const Text(
            'Exported Successfully',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Color(0xFF111827),
            ),
          ),
        ],
      ),
      content: Container(
        constraints: const BoxConstraints(maxWidth: 440),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Divider(height: 1, color: Color(0xFFE5E7EB)),
            const SizedBox(height: 16),
            Text(
              '$fileType exported successfully.',
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF374151),
              ),
            ),
            const SizedBox(height: 16),
            _infoRow('File Name', fileName),
            const SizedBox(height: 6),
            _infoRow('Saved To', dirPath),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFF6B7280),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
          child: const Text('Close',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
        ),
        if (!kIsWeb)
          TextButton(
            onPressed: () {
              _openFolder();
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF4F6EF7),
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: const Text('Open Folder',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
          ),
      ],
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 72,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF9CA3AF),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF111827),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
