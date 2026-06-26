import 'package:jobodia_frontend/features/cv_builder/model/cv_form_classes.dart';
import 'package:jobodia_frontend/core/extensions/context_extensions.dart';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:jobodia_frontend/core/widgets/custom_button.dart';
import 'package:jobodia_frontend/core/widgets/custom_text_field.dart';
import 'package:jobodia_frontend/features/cv_builder/controller/cv_builder_controller.dart';
import 'package:jobodia_frontend/features/cv_builder/view/widgets/cv_builder_helpers.dart';

class WorkInfoStep extends StatelessWidget {
  const WorkInfoStep({super.key, required this.controller});

  final CvBuilderController controller;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return ListView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 112),
      children: [
        Text(
          'Tell us about your work',
          style: TextStyle(
            color: palette.textPrimary,
            fontSize: 28,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Build this like a LinkedIn profile. Add clear roles, schools, dates, skills, and achievements so AI can shape a strong CV.',
          style: TextStyle(
            fontSize: 15,
            color: palette.textSecondary,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 20),
        CustomTextField(
          label: 'Professional title',
          hintText: 'Product Designer',
          controller: controller.titleController,
          prefixIcon: Icons.badge_outlined,
        ),
        const SizedBox(height: 16),
        Obx(
          () => ProfileSectionCard(
            title: 'Work experience',
            subtitle:
                'Add up to 3 roles with company, dates, responsibilities, and measurable wins.',
            icon: Icons.work_outline_rounded,
            children: [
              ...controller.workExperiences.map(
                (entry) => WorkExperienceEntry(
                  controller: controller,
                  entry: entry,
                  index: controller.workExperiences.indexOf(entry),
                ),
              ),
              const SizedBox(height: 12),
              AddEntryButton(
                label: 'Add work experience',
                note:
                    '${controller.workExperiences.length}/${CvBuilderController.maxEntries} added',
                onPressed: controller.canAddWorkExperience
                    ? controller.addWorkExperience
                    : null,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Obx(
          () => ProfileSectionCard(
            title: 'Education',
            subtitle:
                'Add up to 3 schools or universities with degree, dates, and useful notes.',
            icon: Icons.school_outlined,
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
        ),
        const SizedBox(height: 16),
        ProfileSectionCard(
          title: 'Skills',
          subtitle:
              'Add one skill at a time. Keep them specific and searchable.',
          icon: Icons.auto_awesome_outlined,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: CompactInput(
                    label: 'Skill',
                    hintText: 'Figma',
                    controller: controller.skillController,
                    onSubmitted: (_) => controller.addSkill(),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 48,
                  height: 48,
                  child: FilledButton(
                    onPressed: controller.addSkill,
                    style: FilledButton.styleFrom(
                      backgroundColor: palette.textPrimary,
                      foregroundColor: palette.scaffold,
                      padding: EdgeInsets.zero,
                      shape: const CircleBorder(),
                    ),
                    child: const Icon(Icons.add_rounded),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Obx(
              () => controller.skills.isEmpty
                  ? Text(
                      'No skills added yet.',
                      style: TextStyle(
                        color: palette.textSecondary,
                        fontSize: 13,
                      ),
                    )
                  : Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: controller.skills
                          .map(
                            (skill) => InputChip(
                              label: Text(skill),
                              onDeleted: () {
                                unawaited(HapticFeedback.heavyImpact());
                                controller.removeSkill(skill);
                              },
                              backgroundColor: palette.surfaceMuted,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(999),
                                side: BorderSide.none,
                              ),
                            ),
                          )
                          .toList(),
                    ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const FieldLabel('Summary'),
        const SizedBox(height: 8),
        MultiLineField(
          controller: controller.summaryController,
          hintText: 'Write a short professional summary...',
        ),
        const SizedBox(height: 24),
        CustomButton(label: 'Continue', onPressed: controller.nextStep),
        const SizedBox(height: 10),
        TextButton(
          onPressed: controller.previousStep,
          child: const Text('Back'),
        ),
      ],
    );
  }
}
