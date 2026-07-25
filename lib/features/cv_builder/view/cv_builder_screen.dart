import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:jobodia_frontend/app/routes/app_routes.dart';
import 'package:jobodia_frontend/core/constants/app_colors.dart';
import 'package:jobodia_frontend/core/widgets/quiet_glass_button.dart';
import 'package:jobodia_frontend/features/cv_builder/controller/cv_builder_controller.dart';
import 'package:jobodia_frontend/features/cv_builder/view/widgets/basic_info_step.dart';
import 'package:jobodia_frontend/features/cv_builder/view/widgets/education_step.dart';
import 'package:jobodia_frontend/features/cv_builder/view/widgets/experience_step.dart';
import 'package:jobodia_frontend/features/cv_builder/view/widgets/professional_info_step.dart';
import 'package:jobodia_frontend/features/cv_builder/view/widgets/template_step.dart';
import 'package:jobodia_frontend/features/home/controller/main_nav_controller.dart';

class CvBuilderScreen extends GetView<CvBuilderController> {
  const CvBuilderScreen({super.key, this.embedded = false});

  final bool embedded;

  static const _steps = [
    ('Details', 'Contact'),
    ('Profile', 'Positioning'),
    ('Work', 'Experience'),
    ('Study', 'Education'),
    ('Finish', 'Design'),
  ];

  bool _hasUnsavedChanges() {
    if (controller.stepIndex.value > 0) return true;
    return controller.fullNameController.text.trim().isNotEmpty ||
        controller.emailController.text.trim().isNotEmpty ||
        controller.phoneController.text.trim().isNotEmpty ||
        controller.titleController.text.trim().isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final page = Scaffold(
      backgroundColor: palette.scaffold,
      body: SafeArea(
        bottom: false,
        child: Obx(
          () => Stack(
            children: [
              Column(
                children: [
                  _StudioHeader(
                    step: controller.stepIndex.value,
                    embedded: embedded,
                    onExit: () => _requestExit(context),
                  ),
                  _SectionRail(
                    currentStep: controller.stepIndex.value,
                    onSelected: controller.goToStep,
                  ),
                  if (controller.generateError.value.isNotEmpty)
                    _ValidationMessage(message: controller.generateError.value),
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 380),
                      switchInCurve: Curves.easeInOutCubic,
                      switchOutCurve: Curves.easeInOutCubic,
                      transitionBuilder: (child, animation) => FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0.035, 0),
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        ),
                      ),
                      child: _StepContent(
                        key: ValueKey(controller.stepIndex.value),
                        step: controller.stepIndex.value,
                        controller: controller,
                      ),
                    ),
                  ),
                  _StudioFooter(controller: controller, embedded: embedded),
                ],
              ),
              if (controller.isParsing.value) const _ParsingOverlay(),
            ],
          ),
        ),
      ),
    );

    if (embedded) return page;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (!didPop) await _requestExit(context);
      },
      child: page,
    );
  }

  Future<void> _requestExit(BuildContext context) async {
    if (_hasUnsavedChanges()) {
      final leave = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Leave resume studio?'),
          content: const Text(
            'Your current entries will remain available when you return.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Keep editing'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Leave'),
            ),
          ],
        ),
      );
      if (leave != true || !context.mounted) return;
    }

    if (embedded && Get.isRegistered<MainNavController>()) {
      Get.find<MainNavController>().goToTab(0);
    } else if (Get.currentRoute == AppRoutes.cvBuilder) {
      Get.back<void>();
    } else if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }
}

class _StudioHeader extends StatelessWidget {
  const _StudioHeader({
    required this.step,
    required this.embedded,
    required this.onExit,
  });

  final int step;
  final bool embedded;
  final VoidCallback onExit;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 16, 12),
      color: palette.surface,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.brandTeal.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.description_outlined,
              color: AppColors.brandTeal,
              size: 22,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Create CV',
                  style: TextStyle(
                    color: palette.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.35,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  CvBuilderScreen._steps[step].$2,
                  style: TextStyle(
                    color: palette.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
            decoration: BoxDecoration(
              border: Border.all(color: palette.border),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              '${step + 1}/5',
              style: TextStyle(
                color: palette.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          if (!embedded) ...[
            const SizedBox(width: 8),
            QuietGlassBackButton(onPressed: onExit),
          ],
        ],
      ),
    );
  }
}

class _SectionRail extends StatelessWidget {
  const _SectionRail({required this.currentStep, required this.onSelected});

  final int currentStep;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      height: 58,
      decoration: BoxDecoration(
        color: palette.surface,
        border: Border(bottom: BorderSide(color: palette.divider)),
      ),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
        scrollDirection: Axis.horizontal,
        itemCount: CvBuilderScreen._steps.length,
        separatorBuilder: (_, _) => const SizedBox(width: 7),
        itemBuilder: (context, index) {
          final selected = index == currentStep;
          return Material(
            color: selected ? palette.textPrimary : Colors.transparent,
            borderRadius: BorderRadius.circular(999),
            child: InkWell(
              onTap: () => onSelected(index),
              borderRadius: BorderRadius.circular(999),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    Text(
                      '${index + 1}'.padLeft(2, '0'),
                      style: TextStyle(
                        color: selected
                            ? AppColors.brandTeal
                            : palette.textTertiary,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      CvBuilderScreen._steps[index].$1,
                      style: TextStyle(
                        color: selected ? palette.surface : palette.textPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _StepContent extends StatelessWidget {
  const _StepContent({required this.step, required this.controller, super.key});

  final int step;
  final CvBuilderController controller;

  @override
  Widget build(BuildContext context) {
    return switch (step) {
      0 => BasicInfoStep(controller: controller),
      1 => ProfessionalInfoStep(controller: controller),
      2 => ExperienceStep(controller: controller),
      3 => EducationStep(controller: controller),
      4 => TemplateStep(controller: controller),
      _ => const SizedBox.shrink(),
    };
  }
}

class _StudioFooter extends StatelessWidget {
  const _StudioFooter({required this.controller, required this.embedded});

  final CvBuilderController controller;
  final bool embedded;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final step = controller.stepIndex.value;
    final nativeNavSpace =
        embedded && defaultTargetPlatform == TargetPlatform.iOS ? 78.0 : 0.0;
    final isLast = step == CvBuilderController.totalSteps - 1;
    final nextLabel = isLast
        ? 'Preview final CV'
        : 'Next: ${CvBuilderScreen._steps[step + 1].$2}';

    return Container(
      padding: EdgeInsets.fromLTRB(
        18,
        12,
        18,
        12 + MediaQuery.paddingOf(context).bottom + nativeNavSpace,
      ),
      decoration: BoxDecoration(
        color: palette.surface,
        border: Border(top: BorderSide(color: palette.divider)),
      ),
      child: Row(
        children: [
          if (step > 0) ...[
            SizedBox(
              width: 48,
              height: 48,
              child: OutlinedButton(
                onPressed: controller.previousStep,
                style: OutlinedButton.styleFrom(
                  foregroundColor: palette.textPrimary,
                  padding: EdgeInsets.zero,
                  side: BorderSide(color: palette.border),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Icon(Icons.arrow_back_rounded),
              ),
            ),
            const SizedBox(width: 10),
          ],
          Expanded(
            child: FilledButton(
              onPressed: () {
                unawaited(HapticFeedback.lightImpact());
                controller.nextStep();
              },
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.brandTeal,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(52),
                elevation: 1,
                shadowColor: AppColors.brandTeal.withValues(alpha: 0.32),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    nextLabel,
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward_rounded, size: 18),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ValidationMessage extends StatelessWidget {
  const _ValidationMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(18, 10, 18, 0),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.08),
        border: Border(left: BorderSide(color: AppColors.error, width: 3)),
      ),
      child: Text(
        message,
        style: const TextStyle(
          color: AppColors.error,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _ParsingOverlay extends StatelessWidget {
  const _ParsingOverlay();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: ColoredBox(
        color: Colors.black.withValues(alpha: 0.45),
        child: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      ),
    );
  }
}
