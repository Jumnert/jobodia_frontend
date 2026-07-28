import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:forui/forui.dart';
import 'package:get/get.dart';
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
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: _OnboardingColors.background,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: FTheme(data: lightTheme, child: const _OnboardingScaffold()),
    );
  }
}

abstract final class _OnboardingColors {
  static const background = Color(0xFFFAFBFC);
  static const ink = Color(0xFF23130D);
  static const muted = Color(0xFF62666B);
  static const inactiveProgress = Color(0xFFE5E6E8);
  static const buttonShadow = Color(0x45E58F56);
}

class _OnboardingScaffold extends GetView<OnboardingController> {
  const _OnboardingScaffold();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _OnboardingColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const _OnboardingHeader(),
            Expanded(
              child: PageView.builder(
                controller: controller.pageController,
                onPageChanged: controller.onPageChanged,
                itemCount: OnboardingView._pages.length,
                itemBuilder: (context, index) =>
                    _OnboardingPage(data: OnboardingView._pages[index]),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(42, 12, 42, 20),
              child: Obx(
                () => _PrimaryAction(
                  isLastPage: controller.isLastPage,
                  onPress: controller.goNext,
                ),
              ),
            ),
          ],
        ),
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

      return Padding(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 8),
        child: Row(
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              child: currentPage == 0
                  ? const SizedBox(key: ValueKey('no-back'), width: 42)
                  : SizedBox(
                      key: const ValueKey('back'),
                      width: 42,
                      height: 42,
                      child: FButton.icon(
                        variant: FButtonVariant.secondary,
                        onPress: controller.goBack,
                        child: const Icon(FLucideIcons.chevronLeft, size: 20),
                      ),
                    ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Row(
                children: List.generate(OnboardingController.totalPages, (
                  index,
                ) {
                  final active = index <= currentPage;
                  return Expanded(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 320),
                      curve: Curves.easeOutCubic,
                      height: 4,
                      margin: EdgeInsets.only(
                        right: index == OnboardingController.totalPages - 1
                            ? 0
                            : 8,
                      ),
                      decoration: BoxDecoration(
                        color: active
                            ? _OnboardingColors.ink
                            : _OnboardingColors.inactiveProgress,
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
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
                  color: _OnboardingColors.ink,
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
                  style: const TextStyle(
                    color: _OnboardingColors.muted,
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

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: _OnboardingColors.buttonShadow,
            blurRadius: 14,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 54,
        child: FButton(
          onPress: onPress,
          suffix: const Icon(FLucideIcons.arrowRight, size: 18),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            child: Text(label, key: ValueKey(label)),
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
