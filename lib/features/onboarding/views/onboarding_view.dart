import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:jobodia_frontend/core/constants/app_colors.dart';
import 'package:jobodia_frontend/features/onboarding/controllers/onboarding_controller.dart';
import 'package:jobodia_frontend/features/onboarding/widgets/onboarding_background.dart';
import 'package:jobodia_frontend/features/onboarding/widgets/onboarding_button.dart';
import 'package:jobodia_frontend/features/onboarding/widgets/onboarding_content.dart';
import 'package:jobodia_frontend/features/onboarding/widgets/onboarding_page_indicator.dart';
import 'package:jobodia_frontend/features/onboarding/widgets/onboarding_visuals.dart';

class OnboardingView extends GetView<OnboardingController> {
  const OnboardingView({super.key});

  static const _pages = [
    _OnboardingPageData(
      titleLines: [
        OnboardingTitleLine('Unlock'),
        OnboardingTitleLine('Opportunities', isHighlighted: true),
        OnboardingTitleLine('That Match You'),
      ],
      subtitle:
          'Discover the right jobs tailored to your skills, experience, and goals.',
      visualType: OnboardingVisualType.jobs,
    ),
    _OnboardingPageData(
      titleLines: [
        OnboardingTitleLine('Build'),
        OnboardingTitleLine('Smarter', isHighlighted: true),
        OnboardingTitleLine('Resumes'),
      ],
      subtitle:
          'Create ATS-friendly resumes that highlight your strengths and get you noticed.',
      visualType: OnboardingVisualType.resume,
    ),
    _OnboardingPageData(
      titleLines: [
        OnboardingTitleLine('Practice.'),
        OnboardingTitleLine('Improve.'),
        OnboardingTitleLine('Succeed.', isHighlighted: true),
      ],
      subtitle:
          'Get AI-powered mock interviews and real-time feedback to boost your confidence.',
      visualType: OnboardingVisualType.interview,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.black,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: Colors.black,
        body: OnboardingBackground(
          child: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isCompact = constraints.maxHeight < 720;

                    return _OnboardingStage(
                      pages: _pages,
                      compact: isCompact,
                      stageHeight: constraints.maxHeight,
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _OnboardingStage extends GetView<OnboardingController> {
  const _OnboardingStage({
    required this.pages,
    required this.compact,
    required this.stageHeight,
  });

  final List<_OnboardingPageData> pages;
  final bool compact;
  final double stageHeight;

  @override
  Widget build(BuildContext context) {
    final height = stageHeight;

    return Stack(
      children: [
        PageView.builder(
          controller: controller.pageController,
          onPageChanged: controller.onPageChanged,
          itemCount: pages.length,
          itemBuilder: (context, index) {
            return _OnboardingPage(
              data: pages[index],
              index: index,
              compact: compact,
              stageHeight: stageHeight,
            );
          },
        ),
        Positioned(top: 6, right: 16, child: _SkipButton()),
        Obx(() {
          final isLastPage = controller.currentPage.value == pages.length - 1;
          final buttonTop = isLastPage
              ? height * 0.78
              : height - _bottomButtonOffset(height) - 56;

          return Positioned(
            top: buttonTop,
            left: 24,
            right: 24,
            child: OnboardingButton(
              isLastPage: isLastPage,
              onPressed: controller.goNext,
            ),
          );
        }),
        Obx(() {
          final isLastPage = controller.currentPage.value == pages.length - 1;

          return Positioned(
            top: height * 0.87,
            left: 24,
            right: 24,
            child: IgnorePointer(
              ignoring: !isLastPage,
              child: AnimatedOpacity(
                opacity: isLastPage ? 1 : 0,
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                child: const _LoginPrompt(),
              ),
            ),
          );
        }),
        Obx(() {
          final isLastPage = controller.currentPage.value == pages.length - 1;

          return Positioned(
            left: 0,
            right: 0,
            bottom: isLastPage ? height * 0.045 : height * 0.055,
            child: Center(
              child: OnboardingPageIndicator(
                activeIndex: controller.currentPage.value,
                totalPages: pages.length,
              ),
            ),
          );
        }),
      ],
    );
  }

  double _bottomButtonOffset(double height) {
    final responsiveOffset = height * 0.11;
    return responsiveOffset < 88 ? 88 : responsiveOffset;
  }
}

class _OnboardingPage extends StatelessWidget {
  const _OnboardingPage({
    required this.data,
    required this.index,
    required this.compact,
    required this.stageHeight,
  });

  final _OnboardingPageData data;
  final int index;
  final bool compact;
  final double stageHeight;

  @override
  Widget build(BuildContext context) {
    final height = stageHeight;
    final isThirdPage = index == 2;
    final visualTop = switch (index) {
      0 => height * 0.4,
      1 => height * 0.4,
      _ => height * 0.36,
    };

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          top: isThirdPage ? height * 0.1 : height * 0.11,
          left: isThirdPage ? 28 : 32,
          right: isThirdPage ? 28 : 32,
          child: _AnimatedPagePiece(
            index: index,
            child: OnboardingContent(
              titleLines: data.titleLines,
              subtitle: data.subtitle,
              compact: compact,
            ),
          ),
        ),
        Positioned(
          top: visualTop,
          left: 0,
          right: 0,
          child: _AnimatedPagePiece(
            index: index,
            isVisual: true,
            child: Center(
              child: OnboardingVisuals(type: data.visualType, compact: compact),
            ),
          ),
        ),
        if (isThirdPage)
          Positioned(
            top: height * 0.66,
            left: 24,
            right: 24,
            child: _AnimatedPagePiece(
              index: index,
              child: _AiInfoCard(compact: compact),
            ),
          ),
      ],
    );
  }
}

class _AnimatedPagePiece extends GetView<OnboardingController> {
  const _AnimatedPagePiece({
    required this.index,
    required this.child,
    this.isVisual = false,
  });

  final int index;
  final Widget child;
  final bool isVisual;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isActive = controller.currentPage.value == index;

      return AnimatedOpacity(
        opacity: isActive ? 1 : 0.58,
        duration: const Duration(milliseconds: 360),
        curve: Curves.easeOutCubic,
        child: AnimatedScale(
          scale: isActive ? 1 : (isVisual ? 0.95 : 1),
          duration: const Duration(milliseconds: 420),
          curve: Curves.easeOutCubic,
          child: AnimatedSlide(
            offset: isActive ? Offset.zero : const Offset(0, 0.05),
            duration: const Duration(milliseconds: 420),
            curve: Curves.easeOutCubic,
            child: child,
          ),
        ),
      );
    });
  }
}

class _SkipButton extends GetView<OnboardingController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final shouldShow = controller.currentPage.value < 2;

      return AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        child: shouldShow
            ? TextButton(
                key: const ValueKey('skip_button'),
                onPressed: controller.completeOnboarding,
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white.withValues(alpha: 0.72),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  textStyle: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                child: const Text('Skip'),
              )
            : const SizedBox.shrink(key: ValueKey('skip_hidden')),
      );
    });
  }
}

class _AiInfoCard extends StatelessWidget {
  const _AiInfoCard({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: compact ? 64 : 72,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF080809).withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.accentPurple, AppColors.accentPurpleDark],
              ),
            ),
            child: const Icon(
              Icons.graphic_eq_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'AI Interviewer',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Great answer! You showed strong problem-solving skills.',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.68),
                    fontSize: compact ? 10 : 11,
                    height: 1.2,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LoginPrompt extends GetView<OnboardingController> {
  const _LoginPrompt();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(
            'Already have an account? ',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.56),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
          GestureDetector(
            onTap: controller.completeOnboarding,
            child: const Text(
              'Log in',
              style: TextStyle(
                color: AppColors.accentPurple,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingPageData {
  const _OnboardingPageData({
    required this.titleLines,
    required this.subtitle,
    required this.visualType,
  });

  final List<OnboardingTitleLine> titleLines;
  final String subtitle;
  final OnboardingVisualType visualType;
}
