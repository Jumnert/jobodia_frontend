import 'package:flutter/material.dart';
import 'package:jobodia_frontend/core/constants/app_colors.dart';

class OnboardingPageIndicator extends StatelessWidget {
  const OnboardingPageIndicator({
    required this.activeIndex,
    required this.totalPages,
    super.key,
  });

  final int activeIndex;
  final int totalPages;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(totalPages, (index) {
        final isActive = activeIndex == index;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.symmetric(horizontal: 5),
          width: isActive ? 18 : 6,
          height: 6,
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.accentPurple
                : Colors.white.withValues(alpha: 0.42),
            borderRadius: BorderRadius.circular(999),
          ),
        );
      }),
    );
  }
}
