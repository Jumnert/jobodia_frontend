import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:jobodia_frontend/core/constants/app_colors.dart';
import 'package:jobodia_frontend/core/widgets/custom_button.dart';
import 'package:jobodia_frontend/features/cv_builder/controller/cv_builder_controller.dart';
import 'package:jobodia_frontend/features/cv_builder/view/widgets/cv_builder_helpers.dart';

class TemplateStep extends StatelessWidget {
  const TemplateStep({super.key, required this.controller});

  final CvBuilderController controller;

  @override
  Widget build(BuildContext context) {
    final templates = [
      const TemplateMeta(title: 'Classic', subtitle: 'Clean and simple layout'),
      const TemplateMeta(
        title: 'Balanced',
        subtitle: 'Split sections and modern spacing',
      ),
      const TemplateMeta(
        title: 'Modern',
        subtitle: 'Compact with strong heading focus',
      ),
    ];

    return ListView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 112),
      children: [
        Text(
          'Choose a template you like',
          style: TextStyle(
            color: context.palette.textPrimary,
            fontSize: 28,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'You can change it later anytime.',
          style: TextStyle(
            fontSize: 15,
            color: context.palette.textSecondary,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 22),
        SizedBox(
          height: 250,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: templates.length,
            separatorBuilder: (context, index) => const SizedBox(width: 18),
            itemBuilder: (context, index) => Obx(
              () => GestureDetector(
                onTap: () => controller.selectTemplate(index),
                child: Container(
                  width: 180,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: context.palette.surface,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: controller.selectedTemplateIndex.value == index
                          ? context.palette.textPrimary
                          : context.palette.border,
                      width: controller.selectedTemplateIndex.value == index
                          ? 1.8
                          : 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: TemplatePreviewCard(
                          title: templates[index].title,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        templates[index].title,
                        style: TextStyle(
                          color: context.palette.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        templates[index].subtitle,
                        style: TextStyle(
                          color: context.palette.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Obx(
          () => controller.generateError.value.isEmpty
              ? const SizedBox.shrink()
              : Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.error.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.error_outline_rounded,
                          color: AppColors.error,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            controller.generateError.value,
                            style: const TextStyle(
                              color: AppColors.error,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        ),
        CustomButton(
          label: 'Generate CV',
          onPressed: () {
            unawaited(HapticFeedback.mediumImpact());
            controller.nextStep();
          },
        ),
        const SizedBox(height: 10),
        Text(
          'AI will create your professional CV',
          textAlign: TextAlign.center,
          style: TextStyle(color: context.palette.textTertiary, fontSize: 14),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: controller.previousStep,
          child: const Text('Back'),
        ),
      ],
    );
  }
}
