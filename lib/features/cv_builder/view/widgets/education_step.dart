import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jobodia_frontend/features/cv_builder/controller/cv_builder_controller.dart';
import 'package:jobodia_frontend/features/cv_builder/view/widgets/cv_builder_helpers.dart';

class EducationStep extends StatelessWidget {
  const EducationStep({required this.controller, super.key});

  final CvBuilderController controller;

  @override
  Widget build(BuildContext context) {
    return ListView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      children: [
        const ResumeSectionIntro(
          title: 'Education and credentials',
          description:
              'Add degrees, certifications, training, and relevant academic work.',
        ),
        const SizedBox(height: 20),
        Obx(
          () => Column(
            children: [
              ...controller.educations.map(
                (entry) => EducationEntry(
                  key: ValueKey(entry),
                  controller: controller,
                  entry: entry,
                  index: controller.educations.indexOf(entry),
                ),
              ),
              AddEntryButton(
                label: 'Add another education',
                note:
                    '${controller.educations.length}/${CvBuilderController.maxEntries}',
                onPressed: controller.canAddEducation
                    ? controller.addEducation
                    : null,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
