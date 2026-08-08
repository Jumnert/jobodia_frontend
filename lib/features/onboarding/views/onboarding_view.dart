import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:forui/forui.dart';
import 'package:get/get.dart';
import 'package:jobodia_frontend/core/constants/app_colors.dart';
import 'package:jobodia_frontend/features/onboarding/controllers/onboarding_controller.dart';
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
        systemNavigationBarIconBrightness:
            isDark ? Brightness.light : Brightness.dark,
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
          const SafeArea(bottom: false, child: _OnboardingHeader()),
          Expanded(
            child: PageView.builder(
              controller: controller.pageController,
              onPageChanged: controller.onPageChanged,
              itemCount: OnboardingView._pages.length,
              itemBuilder: (context, index) =>
                  _OnboardingPage(data: OnboardingView._pages[index]),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(42, 12, 42, 8),
              child: Obx(
                () => _PrimaryAction(
                  isLastPage: controller.isLastPage,
                  onPress: controller.goNext,
                ),
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

      return Padding(
        padding: const EdgeInsets.fromLTRB(28, 18, 28, 8),
        child: Semantics(
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

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22),
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

class _PrimaryAction extends StatelessWidget {
  const _PrimaryAction({required this.isLastPage, required this.onPress});

  final bool isLastPage;
  final VoidCallback onPress;

  @override
  Widget build(BuildContext context) {
    final label = isLastPage ? 'Get Started' : 'Next';
    final colorScheme = Theme.of(context).colorScheme;
    final primary = colorScheme.primary;
    final highlightColor = Color.lerp(primary, Colors.white, 0.18)!;
    final pressedBaseColor = Color.lerp(primary, Colors.black, 0.28)!;

    return SizedBox(
      width: double.infinity,
      height: 58,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [highlightColor, primary, pressedBaseColor],
              stops: const [0, 0.64, 1],
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withValues(alpha: 0.30)),
            boxShadow: [
              BoxShadow(
                color: pressedBaseColor,
                blurRadius: 0,
                offset: const Offset(0, 3),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.16),
                blurRadius: 5,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                top: 2,
                left: 3,
                right: 3,
                height: 10,
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(14),
                      ),
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withValues(alpha: 0.18),
                          Colors.white.withValues(alpha: 0),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  HapticFeedback.lightImpact();
                  onPress();
                },
                borderRadius: BorderRadius.circular(18),
                splashColor: Colors.white.withValues(alpha: 0.16),
                highlightColor: Colors.black.withValues(alpha: 0.12),
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 180),
                        child: Text(
                          label,
                          key: ValueKey(label),
                          style: TextStyle(
                            color: colorScheme.onPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        FLucideIcons.arrowRight,
                        size: 18,
                        color: colorScheme.onPrimary,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
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
