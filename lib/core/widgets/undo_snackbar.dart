import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jobodia_frontend/core/constants/app_colors.dart';

/// Shows a snackbar with an "Undo" action button.
///
/// ```dart
/// showUndoSnackbar(
///   message: 'Job removed',
///   onUndo: () => savedJobs.toggleSave(job),
/// );
/// ```
void showUndoSnackbar({
  required String message,
  required VoidCallback onUndo,
  Duration duration = const Duration(seconds: 4),
}) {
  Get.snackbar(
    '',
    '',
    titleText: const SizedBox.shrink(),
    messageText: Row(
      children: [
        Expanded(
          child: Text(
            message,
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
        ),
        GestureDetector(
          onTap: () {
            onUndo();
            Get.closeCurrentSnackbar();
          },
          child: const Text(
            'Undo',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w700,
              decoration: TextDecoration.underline,
              decorationColor: Colors.white,
            ),
          ),
        ),
      ],
    ),
    snackPosition: SnackPosition.BOTTOM,
    backgroundColor: AppColors.primary.withValues(alpha: 0.92),
    margin: const EdgeInsets.all(16),
    duration: duration,
  );
}
