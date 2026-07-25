import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:jobodia_frontend/core/constants/app_colors.dart';
import 'package:jobodia_frontend/features/cv_builder/controller/cv_builder_controller.dart';
import 'package:jobodia_frontend/features/cv_builder/service/cv_pdf_builder.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

class TemplateStep extends StatelessWidget {
  const TemplateStep({required this.controller, super.key});

  final CvBuilderController controller;

  static const _templates = [
    _TemplateOption(
      name: 'Classic',
      description: 'Single column · ATS-first',
      icon: Icons.notes_rounded,
    ),
    _TemplateOption(
      name: 'Editorial',
      description: 'Two column · Polished',
      icon: Icons.view_sidebar_outlined,
    ),
    _TemplateOption(
      name: 'Impact',
      description: 'Strong header · Modern',
      icon: Icons.space_dashboard_outlined,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Choose your layout',
                    style: TextStyle(
                      color: palette.textPrimary,
                      fontSize: 25,
                      height: 1.1,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.6,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    'This is your real A4 document—not a placeholder mockup.',
                    style: TextStyle(
                      color: palette.textSecondary,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(99),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.check_circle_rounded,
                    color: AppColors.success,
                    size: 14,
                  ),
                  SizedBox(width: 5),
                  Text(
                    'ATS SAFE',
                    style: TextStyle(
                      color: AppColors.success,
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.7,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        SizedBox(
          height: 94,
          child: Obx(
            () => ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _templates.length,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final selected =
                    controller.selectedTemplateIndex.value == index;
                return _TemplateCard(
                  option: _templates[index],
                  selected: selected,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    controller.selectTemplate(index);
                  },
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 18),
        Obx(() {
          final template = controller.selectedTemplateIndex.value;
          final cv = controller.buildDraftCv();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Document preview',
                    style: TextStyle(
                      color: palette.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'A4 · ${_templates[template].name}',
                    style: TextStyle(
                      color: palette.textTertiary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                height: 470,
                decoration: BoxDecoration(
                  color: palette.surfaceMuted,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: palette.border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.07),
                      blurRadius: 26,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: PdfPreview(
                  key: ValueKey('cv-template-$template'),
                  build: (_) => buildCvPdf(cv),
                  initialPageFormat: PdfPageFormat.a4,
                  canChangeOrientation: false,
                  canChangePageFormat: false,
                  allowPrinting: false,
                  allowSharing: false,
                  useActions: false,
                  maxPageWidth: 520,
                  loadingWidget: const Center(
                    child: CircularProgressIndicator(strokeWidth: 2.5),
                  ),
                ),
              ),
            ],
          );
        }),
        const SizedBox(height: 18),
        _ReadinessCard(controller: controller),
      ],
    );
  }
}

class _TemplateOption {
  const _TemplateOption({
    required this.name,
    required this.description,
    required this.icon,
  });

  final String name;
  final String description;
  final IconData icon;
}

class _TemplateCard extends StatelessWidget {
  const _TemplateCard({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  final _TemplateOption option;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Material(
      color: selected
          ? AppColors.brandTeal.withValues(alpha: 0.09)
          : palette.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: 154,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? AppColors.brandTeal : palette.border,
              width: selected ? 1.8 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 50,
                decoration: BoxDecoration(
                  color: selected ? AppColors.brandTeal : palette.surfaceMuted,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  option.icon,
                  size: 19,
                  color: selected ? Colors.white : palette.iconMuted,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      option.name,
                      maxLines: 1,
                      style: TextStyle(
                        color: palette.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      option.description,
                      maxLines: 2,
                      style: TextStyle(
                        color: palette.textTertiary,
                        fontSize: 9.5,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReadinessCard extends StatelessWidget {
  const _ReadinessCard({required this.controller});

  final CvBuilderController controller;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final checks = <(bool, String)>[
      (controller.fullNameController.text.trim().isNotEmpty, 'Contact details'),
      (controller.titleController.text.trim().isNotEmpty, 'Target title'),
      (controller.summaryController.text.trim().isNotEmpty, 'Summary'),
      (
        controller.workExperiences.any((entry) => entry.hasContent) ||
            controller.educations.any((entry) => entry.hasContent),
        'Career history',
      ),
      (controller.skills.length >= 5, '5+ relevant skills'),
    ];
    final completed = checks.where((check) => check.$1).length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: palette.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Content check',
                style: TextStyle(
                  color: palette.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const Spacer(),
              Text(
                '$completed/${checks.length} complete',
                style: const TextStyle(
                  color: AppColors.brandTeal,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: checks
                .map(
                  (check) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: check.$1
                          ? AppColors.success.withValues(alpha: 0.09)
                          : palette.surfaceMuted,
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          check.$1 ? Icons.check_rounded : Icons.remove_rounded,
                          color: check.$1
                              ? AppColors.success
                              : palette.iconMuted,
                          size: 14,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          check.$2,
                          style: TextStyle(
                            color: check.$1
                                ? palette.textPrimary
                                : palette.textSecondary,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}
