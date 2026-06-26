import 'package:flutter/material.dart';
import 'package:jobodia_frontend/core/constants/app_colors.dart';

/// Animated error message that slides in from below and fades.
///
/// Used by login, signup, OTP, and reset-password screens to show
/// server-side or validation errors.
class AnimatedErrorMessage extends StatelessWidget {
  const AnimatedErrorMessage({
    super.key,
    required this.message,
    this.visible = true,
  });

  final String message;
  final bool visible;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 280),
      switchInCurve: Curves.easeInOutCubic,
      switchOutCurve: Curves.easeInOutCubic,
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: SizeTransition(
            sizeFactor: animation,
            alignment: Alignment.topCenter,
            child: child,
          ),
        );
      },
      child: visible && message.isNotEmpty
          ? Padding(
              key: ValueKey(message),
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.error,
                  fontWeight: FontWeight.w500,
                ),
              ),
            )
          : const SizedBox.shrink(),
    );
  }
}
