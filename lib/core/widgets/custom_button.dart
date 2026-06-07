import 'package:flutter/material.dart';
import 'package:jobodia_frontend/core/constants/app_colors.dart';

/// Reusable dark rounded button with loading state.
class CustomButton extends StatelessWidget {
  const CustomButton({
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: isLoading ? null : onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.primary,
        disabledBackgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(48),
        shape: const StadiumBorder(),
        textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        switchInCurve: Curves.easeInOutCubic,
        switchOutCurve: Curves.easeInOutCubic,
        child: isLoading
            ? const SizedBox.square(
                key: ValueKey('button_loading'),
                dimension: 21,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.2,
                ),
              )
            : Text(label, key: ValueKey(label)),
      ),
    );
  }
}
