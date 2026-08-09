import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:forui/forui.dart';
import 'package:get/get.dart';
import 'package:jobodia_frontend/app/routes/app_routes.dart';
import 'package:jobodia_frontend/core/constants/app_colors.dart';
import 'package:jobodia_frontend/core/widgets/confirmation_dialog.dart';
import 'package:jobodia_frontend/features/cv_builder/controller/cv_builder_controller.dart';
import 'package:jobodia_frontend/features/cv_builder/view/widgets/basic_info_step.dart';
import 'package:jobodia_frontend/features/cv_builder/view/widgets/education_step.dart';
import 'package:jobodia_frontend/features/cv_builder/view/widgets/experience_step.dart';
import 'package:jobodia_frontend/features/cv_builder/view/widgets/professional_info_step.dart';
import 'package:jobodia_frontend/features/cv_builder/view/widgets/template_step.dart';

class CvBuilderScreen extends GetView<CvBuilderController> {
  const CvBuilderScreen({super.key, this.embedded = false});

  final bool embedded;

  static const _steps = [
    ('Your details', 'Contact information', FLucideIcons.contact),
    ('Professional profile', 'Your positioning', FLucideIcons.userRoundSearch),
    ('Work experience', 'Your impact', FLucideIcons.briefcaseBusiness),
    ('Education', 'Your credentials', FLucideIcons.graduationCap),
    ('Design', 'Choose a template', FLucideIcons.layoutTemplate),
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
    if (embedded) return _ResumeLanding(controller: controller);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (!didPop) await _requestExit();
      },
      child: ColoredBox(
        color: context.palette.scaffold,
        child: SafeArea(
          bottom: false,
          child: Obx(
            () => Stack(
              children: [
                Column(
                  children: [
                    _CreationHeader(
                      step: controller.stepIndex.value,
                      onBack: _requestExit,
                    ),
                    if (controller.generateError.value.isNotEmpty)
                      _ValidationMessage(
                        message: controller.generateError.value,
                      ),
                    Expanded(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        switchInCurve: Curves.easeOutCubic,
                        switchOutCurve: Curves.easeInCubic,
                        transitionBuilder: (child, animation) => FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0.04, 0),
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
                    _CreationFooter(controller: controller),
                  ],
                ),
                if (controller.isParsing.value) const _ParsingOverlay(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _requestExit() async {
    if (_hasUnsavedChanges()) {
      final leave = await showConfirmationDialog(
        title: 'Leave resume builder?',
        message:
            'Your current entries will stay here so you can continue later.',
        confirmLabel: 'Leave builder',
        cancelLabel: 'Keep editing',
      );
      if (!leave) return;
    }
    Get.back<void>();
  }
}

class _ResumeLanding extends StatelessWidget {
  const _ResumeLanding({required this.controller});

  final CvBuilderController controller;

  @override
  Widget build(BuildContext context) {
    final theme = FTheme.of(context);
    final palette = context.palette;

    return SafeArea(
      bottom: false,
      child: Obx(() {
        if (controller.isLoadingSavedCv.value) {
          return const Center(child: FCircularProgress());
        }

        final cv = controller.generatedCv.value;
        return Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            MediaQuery.paddingOf(context).bottom + 118,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'My resumes',
                style: theme.typography.display.sm.copyWith(
                  color: palette.textPrimary,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                cv == null
                    ? 'Create and manage your professional resume.'
                    : 'Your latest resume is ready to use.',
                style: theme.typography.body.sm.copyWith(
                  color: palette.textSecondary,
                ),
              ),
              if (cv == null)
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 28),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Container(
                                width: 112,
                                height: 112,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: theme.colors.primary.withValues(
                                    alpha: 0.1,
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  FLucideIcons.files,
                                  size: 48,
                                  color: theme.colors.primary,
                                ),
                              ),
                              Positioned(
                                right: -2,
                                bottom: 3,
                                child: Container(
                                  width: 38,
                                  height: 38,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: palette.surface,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: palette.border,
                                      width: 2,
                                    ),
                                  ),
                                  child: Icon(
                                    FLucideIcons.plus,
                                    size: 19,
                                    color: theme.colors.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Text(
                            "You don't have a resume yet",
                            textAlign: TextAlign.center,
                            style: theme.typography.body.lg.copyWith(
                              color: palette.textPrimary,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Build one step by step and preview it before you save.',
                            textAlign: TextAlign.center,
                            style: theme.typography.body.sm.copyWith(
                              color: palette.textSecondary,
                              height: 1.45,
                            ),
                          ),
                          const SizedBox(height: 24),
                          FButton(
                            onPress: () {
                              controller.startCreation();
                              Get.toNamed<void>(AppRoutes.cvBuilder);
                            },
                            prefix: const Icon(FLucideIcons.plus),
                            child: const Text('Create now'),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else ...[
                const SizedBox(height: 24),
                FTileGroup(
                  label: const Text('Your resume'),
                  children: [
                    FTile(
                      prefix: const Icon(FLucideIcons.fileText),
                      title: Text(cv.fullName),
                      subtitle: Text(
                        cv.title.isEmpty ? 'Professional resume' : cv.title,
                      ),
                      details: const Text('Ready'),
                      suffix: const Icon(FLucideIcons.chevronRight),
                      onPress: () => Get.toNamed<void>(AppRoutes.cvPreview),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: FButton(
                        variant: FButtonVariant.outline,
                        onPress: () => Get.toNamed<void>(AppRoutes.cvPreview),
                        child: const Text('Preview'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: FButton(
                        onPress: () {
                          controller.startCreation();
                          Get.toNamed<void>(AppRoutes.cvBuilder);
                        },
                        child: const Text('Edit resume'),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      }),
    );
  }
}

class _CreationHeader extends StatelessWidget {
  const _CreationHeader({required this.step, required this.onBack});

  final int step;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final theme = FTheme.of(context);
    final palette = context.palette;
    final current = CvBuilderScreen._steps[step];
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 16, 14),
      decoration: BoxDecoration(
        color: palette.scaffold,
        border: Border(bottom: BorderSide(color: palette.divider)),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 46,
            child: Row(
              children: [
                FButton.icon(
                  variant: FButtonVariant.ghost,
                  onPress: onBack,
                  child: const Icon(FLucideIcons.arrowLeft),
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Create resume',
                        style: theme.typography.body.md.copyWith(
                          color: palette.textPrimary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Step ${step + 1} of ${CvBuilderController.totalSteps}',
                        style: theme.typography.body.xs.copyWith(
                          color: palette.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 44),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: List.generate(
              CvBuilderController.totalSteps,
              (index) => Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 240),
                  height: 4,
                  margin: EdgeInsets.only(
                    right: index == CvBuilderController.totalSteps - 1 ? 0 : 6,
                  ),
                  decoration: BoxDecoration(
                    color: index <= step
                        ? theme.colors.primary
                        : theme.colors.secondary,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 13),
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: theme.colors.primary.withValues(alpha: 0.11),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(current.$3, size: 17, color: theme.colors.primary),
              ),
              const SizedBox(width: 11),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    current.$1,
                    style: theme.typography.body.sm.copyWith(
                      color: palette.textPrimary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    current.$2,
                    style: theme.typography.body.xs.copyWith(
                      color: palette.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StepContent extends StatelessWidget {
  const _StepContent({required this.step, required this.controller, super.key});

  final int step;
  final CvBuilderController controller;

  @override
  Widget build(BuildContext context) => switch (step) {
    0 => BasicInfoStep(controller: controller),
    1 => ProfessionalInfoStep(controller: controller),
    2 => ExperienceStep(controller: controller),
    3 => EducationStep(controller: controller),
    4 => TemplateStep(controller: controller),
    _ => const SizedBox.shrink(),
  };
}

class _CreationFooter extends StatelessWidget {
  const _CreationFooter({required this.controller});

  final CvBuilderController controller;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final step = controller.stepIndex.value;
    final isLast = step == CvBuilderController.totalSteps - 1;
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        13,
        20,
        13 + MediaQuery.paddingOf(context).bottom,
      ),
      decoration: BoxDecoration(
        color: palette.scaffold,
        border: Border(top: BorderSide(color: palette.divider)),
      ),
      child: Row(
        children: [
          if (step > 0) ...[
            Expanded(
              child: FButton(
                variant: FButtonVariant.outline,
                onPress: controller.previousStep,
                child: const Text('Back'),
              ),
            ),
            const SizedBox(width: 10),
          ],
          Expanded(
            flex: step > 0 ? 1 : 2,
            child: FButton(
              onPress: () {
                unawaited(HapticFeedback.lightImpact());
                controller.nextStep();
              },
              suffix: Icon(isLast ? FLucideIcons.eye : FLucideIcons.arrowRight),
              child: Text(isLast ? 'Preview resume' : 'Continue'),
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
    final theme = FTheme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: FTileGroup(
        children: [
          FTile(
            prefix: Icon(FLucideIcons.circleAlert, color: theme.colors.error),
            title: Text(message, style: TextStyle(color: theme.colors.error)),
          ),
        ],
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
        color: FTheme.of(context).colors.barrier,
        child: const Center(child: FCircularProgress()),
      ),
    );
  }
}
