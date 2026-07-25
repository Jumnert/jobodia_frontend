import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jobodia_frontend/core/constants/app_colors.dart';

class OnboardingButton extends StatefulWidget {
  const OnboardingButton({
    required this.isLastPage,
    required this.onPressed,
    super.key,
  });

  final bool isLastPage;
  final VoidCallback onPressed;

  @override
  State<OnboardingButton> createState() => _OnboardingButtonState();
}

class _OnboardingButtonState extends State<OnboardingButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final label = widget.isLastPage ? 'Get started' : 'Next';

    return AnimatedScale(
      scale: _isPressed ? 0.98 : 1,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: AppColors.onboardingCtaDark.withValues(alpha: 0.25),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(18),
          clipBehavior: Clip.antiAlias,
          child: Ink(
            decoration: BoxDecoration(
              color: AppColors.onboardingCtaDark,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
            ),
            child: InkWell(
              onTap: () {
                HapticFeedback.lightImpact();
                widget.onPressed();
              },
              onTapDown: (_) => setState(() => _isPressed = true),
              onTapCancel: () => setState(() => _isPressed = false),
              onTapUp: (_) => setState(() => _isPressed = false),
              borderRadius: BorderRadius.circular(18),
              splashColor: Colors.white.withValues(alpha: 0.14),
              highlightColor: Colors.white.withValues(alpha: 0.06),
              child: Center(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  child: Text(
                    label,
                    key: ValueKey(label),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.1,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
