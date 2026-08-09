import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:get/get.dart';

/// Shows the app's standard rounded ForUI confirmation dialog.
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
  await showFDialog<void>(
    context: context,
    builder: (dialogContext, _, animation) => FDialog(
      animation: animation,
      clipBehavior: Clip.antiAlias,
      semanticsLabel: title,
      style: const FDialogStyleDelta.delta(
        decoration: DecorationDelta.boxDelta(
          borderRadius: BorderRadius.all(Radius.circular(22)),
        ),
      ),
      builder: (dialogContext, _) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              style: FTheme.of(
                dialogContext,
              ).typography.display.sm.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: FTheme.of(dialogContext).typography.body.sm.copyWith(
                color: FTheme.of(dialogContext).colors.mutedForeground,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 20),
            FButton(
              variant: isDestructive
                  ? FButtonVariant.destructive
                  : FButtonVariant.primary,
              onPress: () {
                confirmed = true;
                Navigator.of(dialogContext).pop();
              },
              child: Text(confirmLabel),
            ),
            const SizedBox(height: 10),
            FButton(
              variant: FButtonVariant.secondary,
              onPress: () => Navigator.of(dialogContext).pop(),
              child: Text(cancelLabel),
            ),
          ],
        ),
      ),
    ),
  );
  return confirmed;
}
