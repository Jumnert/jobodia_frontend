import 'package:flutter/material.dart';
import 'package:jobodia_frontend/core/constants/app_colors.dart';

enum OnboardingVisualType { jobs, resume, interview }

class OnboardingVisuals extends StatelessWidget {
  const OnboardingVisuals({
    required this.type,
    required this.compact,
    super.key,
  });

  final OnboardingVisualType type;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return switch (type) {
      OnboardingVisualType.jobs => const JobCardsStackVisual(),
      OnboardingVisualType.resume => _ResumeVisual(compact: compact),
      OnboardingVisualType.interview => const AiInterviewVisualGroup(),
    };
  }
}

class JobCardsStackVisual extends StatelessWidget {
  const JobCardsStackVisual({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final visualWidth = screenWidth * 0.76;
    final visualHeight = visualWidth * 0.85;

    return SizedBox(
      width: visualWidth,
      height: visualHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: visualWidth * 0.03,
            top: visualHeight * 0.1,
            child: Container(
              width: visualWidth * 0.58,
              height: visualWidth * 0.72,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accentPurple.withValues(alpha: 0.45),
                    blurRadius: 45,
                    spreadRadius: 8,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            right: 0,
            top: visualHeight * 0.28,
            child: Opacity(
              opacity: 0.75,
              child: Transform.rotate(
                angle: 0.08,
                child: Image.asset(
                  'assets/images/onboarding/job_cards_3.png',
                  width: visualWidth * 0.58,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          Positioned(
            right: visualWidth * 0.12,
            top: visualHeight * 0.18,
            child: Opacity(
              opacity: 0.85,
              child: Transform.rotate(
                angle: 0.04,
                child: Image.asset(
                  'assets/images/onboarding/job_cards_2.png',
                  width: visualWidth * 0.62,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            top: visualHeight * 0.03,
            child: Opacity(
              opacity: 1,
              child: Transform.rotate(
                angle: -0.1,
                child: Image.asset(
                  'assets/images/onboarding/job_cards_1.png',
                  width: visualWidth * 0.65,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ResumeVisual extends StatelessWidget {
  const _ResumeVisual({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final width = screenWidth * 0.78;
    final height = width * 0.96;
    final resumeWidth = (screenWidth * 0.58).clamp(205.0, 248.0);

    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          const _PurpleGlow(size: 230),
          Image.asset(
            'assets/images/onboarding/resume_card.png',
            width: resumeWidth,
            fit: BoxFit.contain,
          ),
          Positioned(
            top: height * 0.14,
            right: width * 0.14,
            child: Image.asset(
              'assets/images/onboarding/ats_score.png',
              width: (screenWidth * 0.18).clamp(66.0, 82.0),
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }
}

class AiInterviewVisualGroup extends StatelessWidget {
  const AiInterviewVisualGroup({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final width = size.width;
    final height = size.height * 0.22;
    final robotWidth = (size.width * 0.34).clamp(110.0, 135.0);

    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          Image.asset(
            'assets/images/onboarding/ai_signal.png',
            width: size.width * 0.95,
            fit: BoxFit.contain,
          ),
          Container(
            width: robotWidth,
            height: robotWidth,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.accentPurple.withValues(alpha: 0.45),
                  blurRadius: 45,
                  spreadRadius: 8,
                ),
              ],
            ),
          ),
          Image.asset(
            'assets/images/onboarding/ai_interviewer.png',
            width: robotWidth,
            fit: BoxFit.contain,
          ),
        ],
      ),
    );
  }
}

class _PurpleGlow extends StatelessWidget {
  const _PurpleGlow({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.accentPurpleDark.withValues(alpha: 0.24),
            blurRadius: 70,
            spreadRadius: 18,
          ),
        ],
      ),
    );
  }
}
