import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

/// Reusable rounded brand button with loading state.
class CustomButton extends StatelessWidget {
  const CustomButton({
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.backgroundColor,
    this.foregroundColor,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    final isDisabled = isLoading || onPressed == null;
    final fg = foregroundColor ?? Colors.white;
    return SizedBox(
      height: 44,
      child: FButton(
        onPress: isDisabled ? null : onPressed,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          switchInCurve: Curves.easeInOutCubic,
          switchOutCurve: Curves.easeInOutCubic,
          child: isLoading
              ? SizedBox.square(
                  key: const ValueKey('button_loading'),
                  dimension: 21,
                  child: CircularProgressIndicator(color: fg, strokeWidth: 2.2),
                )
              : Text(
                  label,
                  key: ValueKey(label),
                  style: TextStyle(
                    color: fg,
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                  ),
                ),
        ),
      ),
    );
  }
}
