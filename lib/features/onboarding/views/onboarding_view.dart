import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:jobodia_frontend/core/constants/app_colors.dart';
import 'package:jobodia_frontend/features/onboarding/controllers/onboarding_controller.dart';
import 'package:jobodia_frontend/features/onboarding/widgets/onboarding_button.dart';
import 'package:jobodia_frontend/features/onboarding/widgets/onboarding_page_indicator.dart';
import 'package:jobodia_frontend/features/onboarding/widgets/onboarding_visuals.dart';

/// First-run introduction shown before the login flow.
class OnboardingView extends GetView<OnboardingController> {
  const OnboardingView({super.key, this.previewMode = false});

  final bool previewMode;

  static const _pages = <_OnboardingPageData>[
    _OnboardingPageData(
      title: 'Discover jobs\nyou’ll love',
      subtitle:
          'Browse roles that fit your skills, track the details, and move toward your next opportunity.',
      visualType: OnboardingVisualType.jobs,
    ),
    _OnboardingPageData(
      title: 'Build a CV\nthat gets noticed',
      subtitle:
          'Create a focused, ATS-friendly CV and highlight the experience that makes you stand out.',
      visualType: OnboardingVisualType.resume,
    ),
    _OnboardingPageData(
      title: 'Grow with\nyour career AI',
      subtitle:
          'Prepare for interviews, explore roles, and get clear guidance whenever you need it.',
      visualType: OnboardingVisualType.interview,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    controller.configurePreview(previewMode);
    return const AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: AppColors.surface,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: _OnboardingScaffold(),
    );
  }
}

class _OnboardingScaffold extends GetView<OnboardingController> {
  const _OnboardingScaffold();

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final compact = MediaQuery.sizeOf(context).height < 700;

    return Scaffold(
      backgroundColor: palette.surface,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: PageView.builder(
                controller: controller.pageController,
                onPageChanged: controller.onPageChanged,
                itemCount: OnboardingView._pages.length,
                itemBuilder: (context, index) => _OnboardingPage(
                  data: OnboardingView._pages[index],
                  compact: compact,
                ),
              ),
            ),
            Positioned(
              left: 24,
              right: 24,
              bottom: 8,
              child: Obx(
                () => OnboardingButton(
                  isLastPage: controller.isLastPage,
                  onPressed: controller.goNext,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  const _OnboardingPage({required this.data, required this.compact});

  final _OnboardingPageData data;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final visualHeight = compact ? 235.0 : 290.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 28),
          const _Wordmark(),
          SizedBox(height: compact ? 26 : 40),
          SizedBox(
            height: visualHeight,
            child: Center(
              child: OnboardingVisuals(type: data.visualType, compact: compact),
            ),
          ),
          SizedBox(height: compact ? 18 : 30),
          Text(
            data.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: palette.textPrimary,
              fontSize: compact ? 27 : 31,
              height: 1.06,
              fontWeight: FontWeight.w800,
              letterSpacing: -1.1,
            ),
          ),
          const SizedBox(height: 14),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 315),
            child: Text(
              data.subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: palette.textSecondary,
                fontSize: compact ? 12 : 13,
                height: 1.42,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const Spacer(),
          Obx(
            () => OnboardingPageIndicator(
              activeIndex: Get.find<OnboardingController>().currentPage.value,
              totalPages: OnboardingView._pages.length,
            ),
          ),
          const SizedBox(height: 82),
        ],
      ),
    );
  }
}

class _Wordmark extends StatelessWidget {
  const _Wordmark();

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.workspaces_rounded, color: palette.textPrimary, size: 28),
        const SizedBox(width: 7),
        Text(
          'jobodia',
          style: TextStyle(
            color: palette.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.6,
          ),
        ),
      ],
    );
  }
}

class _OnboardingPageData {
  const _OnboardingPageData({
    required this.title,
    required this.subtitle,
    required this.visualType,
  });

  final String title;
  final String subtitle;
  final OnboardingVisualType visualType;
}
