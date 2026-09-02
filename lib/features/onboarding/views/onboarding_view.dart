import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:forui/forui.dart';
import 'package:get/get.dart';
import 'package:jobodia_frontend/core/constants/app_colors.dart';
import 'package:jobodia_frontend/core/widgets/safe_content_padding.dart';
import 'package:jobodia_frontend/features/onboarding/controllers/onboarding_controller.dart';
import 'package:jobodia_frontend/features/onboarding/widgets/onboarding_button.dart';
import 'package:jobodia_frontend/features/onboarding/widgets/onboarding_visuals.dart';
import 'package:jobodia_frontend/theme/theme.dart';

/// First-run introduction shown before the login flow.
class OnboardingView extends GetView<OnboardingController> {
  const OnboardingView({super.key, this.previewMode = false});

  final bool previewMode;

  static const _pages = <_OnboardingPageData>[
    _OnboardingPageData(
      title: 'Find Work That\nFits Your Life',
      subtitle:
          'Discover roles matched to your skills, goals, and the way you want to work.',
      visualType: OnboardingVisualType.jobs,
    ),
    _OnboardingPageData(
      title: 'Build A CV That\nGets You Noticed',
      subtitle:
          'Create an ATS-ready resume, showcase your strengths, and apply with confidence.',
      visualType: OnboardingVisualType.resume,
    ),
    _OnboardingPageData(
      title: 'Your Career Coach,\nAlways With You',
      subtitle:
          'Prepare for interviews, plan your next move, and get clear AI-powered guidance.',
      visualType: OnboardingVisualType.interview,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    controller.configurePreview(previewMode);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: (isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark)
          .copyWith(
            statusBarColor: Colors.transparent,
            systemNavigationBarColor: _OnboardingColors.background(context),
            systemNavigationBarIconBrightness: isDark
                ? Brightness.light
                : Brightness.dark,
          ),
      child: FTheme(
        data: isDark ? darkTheme : lightTheme,
        child: const _OnboardingScaffold(),
      ),
    );
  }
}

abstract final class _OnboardingColors {
  static bool _isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  static Color background(BuildContext context) =>
      _isDark(context) ? const Color(0xFF0B0E0C) : const Color(0xFFFAFBFC);

  static Color ink(BuildContext context) =>
      _isDark(context) ? const Color(0xFFF4F8F3) : const Color(0xFF23130D);

  static Color muted(BuildContext context) =>
      _isDark(context) ? const Color(0xFFB9C3B6) : const Color(0xFF62666B);
}

class _OnboardingScaffold extends GetView<OnboardingController> {
  const _OnboardingScaffold();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _OnboardingColors.background(context),
      body: Column(
        children: [
          const SafeContentPadding(
            safeBottom: false,
            child: _OnboardingHeader(),
          ),
          Expanded(
            child: PageView.builder(
              controller: controller.pageController,
              onPageChanged: controller.onPageChanged,
              itemCount: OnboardingView._pages.length,
              itemBuilder: (context, index) =>
                  _OnboardingPage(data: OnboardingView._pages[index]),
            ),
          ),
          SafeContentPadding(
            safeTop: false,
            child: Obx(
              () => OnboardingButton(
                isLastPage: controller.isLastPage,
                onPressed: controller.goNext,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingHeader extends GetView<OnboardingController> {
  const _OnboardingHeader();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final currentPage = controller.currentPage.value;
      final progress = controller.autoProgress.value.clamp(0.0, 1.0);

      return Semantics(
        label:
            'Onboarding step ${currentPage + 1} of '
            '${OnboardingController.totalPages}',
        child: ClipRRect(
          borderRadius: BorderRadius.circular(99),
          child: SizedBox(
            height: 5,
            child: Stack(
              children: [
                Positioned.fill(
                  child: ColoredBox(
                    color: AppColors.brandTeal.withValues(
                      alpha: context.isDark ? 0.28 : 0.16,
                    ),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: progress,
                  alignment: Alignment.centerLeft,
                  child: const ColoredBox(color: AppColors.brandTeal),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}

class _OnboardingPage extends StatelessWidget {
  const _OnboardingPage({required this.data});

  final _OnboardingPageData data;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxHeight < 560;
        final visualHeight = compact
            ? math.min(225.0, constraints.maxHeight * 0.45)
            : math.min(330.0, constraints.maxHeight * 0.52);

        return SafeContentPadding(
          safeTop: false,
          safeBottom: false,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: visualHeight,
                child: OnboardingVisuals(
                  type: data.visualType,
                  compact: compact,
                ),
              ),
              SizedBox(height: compact ? 8 : 18),
              Text(
                data.title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _OnboardingColors.ink(context),
                  fontSize: compact ? 28 : 32,
                  height: 1.12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1.15,
                ),
              ),
              const SizedBox(height: 14),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 340),
                child: Text(
                  data.subtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _OnboardingColors.muted(context),
                    fontSize: 14,
                    height: 1.48,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        );
      },
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
