import 'package:flutter/material.dart';
import 'package:jobodia_frontend/core/constants/app_colors.dart';

class OnboardingTitleLine {
  const OnboardingTitleLine(this.text, {this.isHighlighted = false});

  final String text;
  final bool isHighlighted;
}

class OnboardingContent extends StatelessWidget {
  const OnboardingContent({
    required this.titleLines,
    required this.subtitle,
    required this.compact,
    super.key,
  });

  final List<OnboardingTitleLine> titleLines;
  final String subtitle;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final line in titleLines)
          Text(
            line.text,
            style: TextStyle(
              color: line.isHighlighted ? AppColors.accentPurple : Colors.white,
              fontSize: compact ? 27 : 30,
              height: 1.08,
              fontWeight: FontWeight.w900,
            ),
          ),
        SizedBox(height: compact ? 12 : 15),
        Container(
          width: compact ? 180 : 210,
          height: 4,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            gradient: LinearGradient(
              colors: [
                AppColors.accentPurple.withValues(alpha: 0.95),
                AppColors.accentPurple.withValues(alpha: 0.28),
                Colors.transparent,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.accentPurple.withValues(alpha: 0.45),
                blurRadius: 20,
              ),
            ],
          ),
        ),
        SizedBox(height: compact ? 12 : 15),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 300),
          child: Text(
            subtitle,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.86),
              fontSize: compact ? 12.5 : 13.5,
              height: 1.45,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
