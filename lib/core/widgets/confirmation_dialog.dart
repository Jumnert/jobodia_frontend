import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jobodia_frontend/core/constants/app_colors.dart';

/// Shows a confirmation dialog with a title, message, and confirm/cancel
/// buttons. Returns `true` if the user confirms, `false` otherwise.
///
/// ```dart
/// final confirmed = await showConfirmationDialog(
///   title: 'Delete session',
///   message: 'This action cannot be undone.',
///   confirmLabel: 'Delete',
///   isDestructive: true,
/// );
/// if (confirmed) { ... }
/// ```
Future<bool> showConfirmationDialog({
  required String title,
  required String message,
  String confirmLabel = 'Confirm',
  String cancelLabel = 'Cancel',
  bool isDestructive = false,
}) async {
  final result = await Get.dialog<bool>(
    _ConfirmationDialog(
      title: title,
      message: message,
      confirmLabel: confirmLabel,
      cancelLabel: cancelLabel,
      isDestructive: isDestructive,
    ),
  );
  return result ?? false;
}

class _ConfirmationDialog extends StatelessWidget {
  const _ConfirmationDialog({
    required this.title,
    required this.message,
    required this.confirmLabel,
    required this.cancelLabel,
    required this.isDestructive,
  });

  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final confirmColor = isDestructive ? palette.error : AppColors.brandTeal;

    return AlertDialog(
      backgroundColor: palette.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        title,
        style: TextStyle(
          color: palette.textPrimary,
          fontWeight: FontWeight.w700,
        ),
      ),
      content: Text(message, style: TextStyle(color: palette.textSecondary)),
      actions: [
        TextButton(
          onPressed: () => Get.back(result: false),
          child: Text(
            cancelLabel,
            style: TextStyle(color: palette.textSecondary),
          ),
        ),
        TextButton(
          onPressed: () => Get.back(result: true),
          child: Text(
            confirmLabel,
            style: TextStyle(color: confirmColor, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}
