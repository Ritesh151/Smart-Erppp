import 'package:flutter/material.dart';
import 'package:SmartERP/core/widgets/app_button.dart';

class AppDialog extends StatelessWidget {
  final String title;
  final String? message;
  final Widget? content;
  final String? confirmText;
  final String? cancelText;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final bool isDanger;

  const AppDialog({
    super.key,
    required this.title,
    this.message,
    this.content,
    this.confirmText,
    this.cancelText,
    this.onConfirm,
    this.onCancel,
    this.isDanger = false,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: content ??
          (message != null
              ? Text(message!)
              : null),
      actions: [
        if (cancelText != null || onCancel != null)
          AppButton(
            text: cancelText ?? 'Cancel',
            variant: AppButtonVariant.outline,
            onPressed: () {
              Navigator.of(context).pop(false);
              onCancel?.call();
            },
          ),
        if (confirmText != null || onConfirm != null)
          AppButton(
            text: confirmText ?? 'Confirm',
            variant: isDanger ? AppButtonVariant.danger : AppButtonVariant.primary,
            onPressed: () {
              Navigator.of(context).pop(true);
              onConfirm?.call();
            },
          ),
      ],
    );
  }

  static Future<bool?> show({
    required BuildContext context,
    required String title,
    String? message,
    Widget? content,
    String? confirmText,
    String? cancelText,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
    bool isDanger = false,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AppDialog(
        title: title,
        message: message,
        content: content,
        confirmText: confirmText,
        cancelText: cancelText,
        onConfirm: onConfirm,
        onCancel: onCancel,
        isDanger: isDanger,
      ),
    );
  }
}
