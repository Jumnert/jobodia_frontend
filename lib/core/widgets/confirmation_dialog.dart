import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:get/get.dart';

/// Shows a confirmation dialog with a title, message, and confirm/cancel
/// buttons. Returns `true` if the user confirms, `false` otherwise.
///
/// Renders via [AdaptiveAlertDialog] so it adopts platform-native styling
/// (and iOS 26 Liquid Glass where available). The adaptive dialog pops itself
/// when an action is tapped, so the confirm/cancel choice is captured through
/// a local flag rather than a dialog result.
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
  final context = Get.context;
  if (context == null) return false;

  var confirmed = false;
  await AdaptiveAlertDialog.show(
    context: context,
    title: title,
    message: message,
    actions: [
      AlertAction(
        title: cancelLabel,
        style: AlertActionStyle.cancel,
        onPressed: () => confirmed = false,
      ),
      AlertAction(
        title: confirmLabel,
        style: isDestructive
            ? AlertActionStyle.destructive
            : AlertActionStyle.primary,
        onPressed: () => confirmed = true,
      ),
    ],
  );
  return confirmed;
}
