import 'dart:async';

import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:jobodia_frontend/core/constants/app_colors.dart';
import 'package:jobodia_frontend/features/cv_builder/controller/cv_builder_controller.dart';
import 'package:jobodia_frontend/features/cv_builder/view/widgets/basic_info_step.dart';
import 'package:jobodia_frontend/features/cv_builder/view/widgets/template_step.dart';
import 'package:jobodia_frontend/features/cv_builder/view/widgets/work_info_step.dart';

/// Step-by-step CV builder wizard.
///
/// Layout: a progress header, the scrollable content for the current step, and
/// a pinned bottom action bar (Back / Continue / Generate). The actual data,
/// validation, persistence and navigation all live in [CvBuilderController];
/// this widget only drives the wizard chrome and switches step content.
class CvBuilderScreen extends GetView<CvBuilderController> {
  const CvBuilderScreen({super.key});

  /// Short label shown next to "Step N of 3" for each step.
  static const _stepTitles = ['Basic details', 'Your experience', 'Template'];

  bool _hasUnsavedChanges() {
    if (controller.stepIndex.value > 0) return true;
    return controller.fullNameController.text.trim().isNotEmpty ||
        controller.emailController.text.trim().isNotEmpty ||
        controller.phoneController.text.trim().isNotEmpty ||
        controller.titleController.text.trim().isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (!_hasUnsavedChanges()) {
          Navigator.of(context).pop();
          return;
        }
        final discard = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Discard draft?'),
            content: const Text('You have unsaved CV data. Leave anyway?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Stay'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text('Discard'),
              ),
            ],
          ),
        );
        if (discard == true && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: AdaptiveScaffold(
        useHeroBackButton: false,
        appBar: AdaptiveAppBar(title: 'Create CV', useNativeToolbar: true),
        body: Obx(
          () => Stack(
            children: [
              Padding(
                padding: EdgeInsets.only(
                  top: MediaQuery.paddingOf(context).top,
                ),
                child: Column(
                  children: [
                    _StepHeader(
                      step: controller.stepIndex.value,
                      title: _stepTitles[controller.stepIndex.value],
                    ),
                    Expanded(
                      child: _StepContent(
                        step: controller.stepIndex.value,
                        controller: controller,
                      ),
                    ),
                    _StepActionBar(controller: controller),
                  ],
                ),
              ),
              if (controller.isParsing.value) const _ParsingOverlay(),
            ],
          ),
        ),
      ),
    );
  }
}

/// Switches the scrollable content for the active step.
class _StepContent extends StatelessWidget {
  const _StepContent({required this.step, required this.controller});

  final int step;
  final CvBuilderController controller;

  @override
  Widget build(BuildContext context) {
    switch (step) {
      case 0:
        return BasicInfoStep(controller: controller);
      case 1:
        return WorkInfoStep(controller: controller);
      default:
        return TemplateStep(controller: controller);
    }
  }
}

/// Progress bar + "Step N of 3 · <title>" indicator.
class _StepHeader extends StatelessWidget {
  const _StepHeader({required this.step, required this.title});

  final int step;
  final String title;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: List.generate(
              3,
              (index) => Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  height: 6,
                  margin: EdgeInsets.only(right: index == 2 ? 0 : 8),
                  decoration: BoxDecoration(
                    color: index <= step ? AppColors.primary : palette.border,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Step ${step + 1} of 3 · $title',
            style: TextStyle(
              color: palette.textTertiary,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

/// Pinned Back / Continue (or Generate) bar at the bottom of every step.
class _StepActionBar extends StatelessWidget {
  const _StepActionBar({required this.controller});

  final CvBuilderController controller;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Obx(() {
      final step = controller.stepIndex.value;
      final isLast = step == 2;
      return Container(
        padding: EdgeInsets.fromLTRB(
          20,
          12,
          20,
          12 + MediaQuery.paddingOf(context).bottom,
        ),
        decoration: BoxDecoration(
          color: palette.scaffold,
          border: Border(top: BorderSide(color: palette.divider)),
        ),
        child: Row(
          children: [
            if (step > 0) ...[
              Expanded(
                child: OutlinedButton(
                  onPressed: controller.previousStep,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: palette.textPrimary,
                    side: BorderSide(color: palette.border),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Back',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              flex: 2,
              child: FilledButton(
                onPressed: () {
                  unawaited(HapticFeedback.mediumImpact());
                  controller.nextStep();
                },
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  isLast ? 'Generate CV' : 'Continue',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}

/// Full-screen blocking overlay shown while a resume is being parsed.
class _ParsingOverlay extends StatelessWidget {
  const _ParsingOverlay();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: ColoredBox(
        color: Colors.black.withAlpha(100),
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: context.palette.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Parsing Resume...'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
