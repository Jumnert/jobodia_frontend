import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Shows a confirmation dialog with a title, message, and confirm/cancel
/// buttons. Returns `true` if the user confirms, `false` otherwise.
Future<bool> showConfirmationDialog({
  required String title,
  required String message,
  String confirmLabel = 'Confirm',
  String cancelLabel = 'Cancel',
  bool isDestructive = false,
}) async {
  final context = Get.context;
  if (context == null) return false;

  var confirmed = false;
  await showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () {
            confirmed = false;
            Navigator.of(context).pop();
          },
          child: Text(cancelLabel),
        ),
        TextButton(
          onPressed: () {
            confirmed = true;
            Navigator.of(context).pop();
          },
          style: isDestructive
              ? TextButton.styleFrom(foregroundColor: Colors.red)
              : null,
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return confirmed;
}
