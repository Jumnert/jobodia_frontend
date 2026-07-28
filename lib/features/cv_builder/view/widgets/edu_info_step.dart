import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:get/get.dart';
import 'package:jobodia_frontend/features/cv_builder/controller/cv_builder_controller.dart';
import 'package:jobodia_frontend/features/cv_builder/view/widgets/cv_builder_helpers.dart';

/// Education section that can be used standalone or embedded in other steps.
/// Extracted from the CV Builder screen for reuse.
class EduInfoStep extends StatelessWidget {
  const EduInfoStep({super.key, required this.controller});

  final CvBuilderController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => ProfileSectionCard(
        title: 'Education',
        subtitle:
            'Add up to 3 schools or universities with degree, dates, and useful notes.',
        icon: FLucideIcons.graduationCap,
        children: [
          ...controller.educations.map(
            (entry) => EducationEntry(
              controller: controller,
              entry: entry,
              index: controller.educations.indexOf(entry),
            ),
          ),
          const SizedBox(height: 12),
          AddEntryButton(
            label: 'Add education',
            note:
                '${controller.educations.length}/${CvBuilderController.maxEntries} added',
            onPressed: controller.canAddEducation
                ? controller.addEducation
                : null,
          ),
        ],
      ),
    );
  }
}
