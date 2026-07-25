import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jobodia_frontend/core/constants/app_colors.dart';
import 'package:jobodia_frontend/features/cv_builder/controller/cv_builder_controller.dart';
import 'package:jobodia_frontend/features/cv_builder/view/widgets/cv_builder_helpers.dart';

class ExperienceStep extends StatelessWidget {
  const ExperienceStep({required this.controller, super.key});

  final CvBuilderController controller;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return ListView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      children: [
        const ResumeSectionIntro(
          title: 'Employment history',
          description:
              'List recent roles first and prove impact with outcomes, scope, and numbers.',
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.info.withValues(alpha: 0.08),
            border: const Border(
              left: BorderSide(color: AppColors.info, width: 3),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.tips_and_updates_outlined,
                color: AppColors.info,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Write achievements, not only duties. “Reduced load time by 35%” is stronger than “worked on performance.”',
                  style: TextStyle(
                    color: palette.textSecondary,
                    fontSize: 13,
                    height: 1.42,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Obx(
          () => Column(
            children: [
              ...controller.workExperiences.map(
                (entry) => WorkExperienceEntry(
                  key: ValueKey(entry),
                  controller: controller,
                  entry: entry,
                  index: controller.workExperiences.indexOf(entry),
                ),
              ),
              AddEntryButton(
                label: 'Add another role',
                note:
                    '${controller.workExperiences.length}/${CvBuilderController.maxEntries}',
                onPressed: controller.canAddWorkExperience
                    ? controller.addWorkExperience
                    : null,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'No work history yet? Leave this page empty and add your education on the next step.',
          style: TextStyle(
            color: palette.textTertiary,
            fontSize: 12,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}
