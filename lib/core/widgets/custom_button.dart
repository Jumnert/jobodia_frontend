import 'package:jobodia_frontend/core/widgets/platform_ui.dart';
import 'package:flutter/material.dart';
import 'package:jobodia_frontend/core/constants/app_colors.dart';

/// Reusable rounded brand button with loading state.
///
/// Uses [AdaptiveButton] so it renders with platform-native styling (and
/// iOS 26 Liquid Glass where available) while keeping the Jobodia teal fill
/// and pill shape. [AdaptiveButton] supplies its own press feedback, so no
/// extra scale-animation wrapper is needed.
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
    return AdaptiveButton.child(
      onPressed: isDisabled ? null : onPressed,
      enabled: !isDisabled,
      color: backgroundColor ?? AppColors.primary,
      borderRadius: BorderRadius.circular(48),
      size: AdaptiveButtonSize.large,
      minSize: const Size.fromHeight(44),
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
    );
  }
}
