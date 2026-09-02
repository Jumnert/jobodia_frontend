import 'package:flutter/material.dart';
import 'package:jobodia_frontend/core/constants/app_colors.dart';

/// Shows an adaptive dialog with actions.
/// This is a replacement for FDialog.show and AdaptiveAlertDialog.
class AdaptiveDialog {
  /// Shows a dialog with the given parameters.
  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    String? message,
    IconData? icon,
    List<DialogAction>? actions,
    bool barrierDismissible = true,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => _AdaptiveDialogContent(
        title: title,
        message: message,
        icon: icon,
        actions: actions ?? [],
      ),
    );
  }

  /// Shows an input dialog and returns the entered text.
  static Future<String?> inputShow({
    required BuildContext context,
    required String title,
    String? message,
    IconData? icon,
    AdaptiveDialogInput? input,
    List<DialogAction>? actions,
  }) {
    return showDialog<String>(
      context: context,
      barrierDismissible: true,
      builder: (context) => _InputDialogContent(
        title: title,
        message: message,
        icon: icon,
        input: input,
        actions: actions ?? [],
      ),
    );
  }
}

/// An action for a dialog.
class DialogAction {
  const DialogAction({
    required this.title,
    this.style = DialogActionStyle.defaultStyle,
    this.onPressed,
  });

  final String title;
  final DialogActionStyle style;
  final VoidCallback? onPressed;
}

/// The style of a dialog action.
enum DialogActionStyle { defaultStyle, primary, cancel, destructive }

/// Input configuration for an input dialog.
class AdaptiveDialogInput {
  const AdaptiveDialogInput({
    this.placeholder,
    this.keyboardType,
    this.obscureText = false,
    this.maxLength,
  });

  final String? placeholder;
  final TextInputType? keyboardType;
  final bool obscureText;
  final int? maxLength;
}

class _AdaptiveDialogContent extends StatelessWidget {
  const _AdaptiveDialogContent({
    required this.title,
    this.message,
    this.icon,
    required this.actions,
  });

  final String title;
  final String? message;
  final IconData? icon;
  final List<DialogAction> actions;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fg = isDark ? Colors.white : Colors.black;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, color: fg, size: 24),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: fg,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
      content: message != null
          ? Text(
              message!,
              style: TextStyle(color: fg.withValues(alpha: 0.7), fontSize: 14),
            )
          : null,
      actions: actions.map((action) {
        return TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            action.onPressed?.call();
          },
          child: Text(
            action.title,
            style: TextStyle(
              color: switch (action.style) {
                DialogActionStyle.destructive => Colors.red,
                DialogActionStyle.primary => AppColors.brandPrimary,
                DialogActionStyle.cancel => fg.withValues(alpha: 0.6),
                DialogActionStyle.defaultStyle => fg,
              },
              fontWeight: action.style == DialogActionStyle.primary
                  ? FontWeight.w700
                  : FontWeight.w500,
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _InputDialogContent extends StatefulWidget {
  const _InputDialogContent({
    required this.title,
    this.message,
    this.icon,
    this.input,
    required this.actions,
  });

  final String title;
  final String? message;
  final IconData? icon;
  final AdaptiveDialogInput? input;
  final List<DialogAction> actions;

  @override
  State<_InputDialogContent> createState() => _InputDialogContentState();
}

class _InputDialogContentState extends State<_InputDialogContent> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fg = isDark ? Colors.white : Colors.black;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          if (widget.icon != null) ...[
            Icon(widget.icon, color: fg, size: 24),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Text(
              widget.title,
              style: TextStyle(
                color: fg,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.message != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                widget.message!,
                style: TextStyle(
                  color: fg.withValues(alpha: 0.7),
                  fontSize: 14,
                ),
              ),
            ),
          TextField(
            controller: _controller,
            keyboardType: widget.input?.keyboardType,
            obscureText: widget.input?.obscureText ?? false,
            maxLength: widget.input?.maxLength,
            decoration: InputDecoration(
              hintText: widget.input?.placeholder,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: isDark
                  ? const Color(0xFF22262B)
                  : const Color(0xFFF3F5F7),
            ),
          ),
        ],
      ),
      actions: widget.actions.map((action) {
        return TextButton(
          onPressed: () {
            if (action.style == DialogActionStyle.primary) {
              Navigator.of(context).pop(_controller.text);
            } else {
              Navigator.of(context).pop();
            }
            action.onPressed?.call();
          },
          child: Text(
            action.title,
            style: TextStyle(
              color: switch (action.style) {
                DialogActionStyle.destructive => Colors.red,
                DialogActionStyle.primary => AppColors.brandPrimary,
                DialogActionStyle.cancel => fg.withValues(alpha: 0.6),
                DialogActionStyle.defaultStyle => fg,
              },
              fontWeight: action.style == DialogActionStyle.primary
                  ? FontWeight.w700
                  : FontWeight.w500,
            ),
          ),
        );
      }).toList(),
    );
  }
}

// Type aliases for backwards compatibility with existing code
typedef AlertAction = DialogAction;
typedef AlertActionStyle = DialogActionStyle;
typedef FDialog = AdaptiveDialog;
