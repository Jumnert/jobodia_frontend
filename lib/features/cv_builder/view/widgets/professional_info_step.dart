import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:forui/forui.dart';
import 'package:get/get.dart';
import 'package:jobodia_frontend/core/constants/app_colors.dart';
import 'package:jobodia_frontend/features/cv_builder/controller/cv_builder_controller.dart';
import 'package:jobodia_frontend/features/cv_builder/view/widgets/cv_builder_helpers.dart';

class ProfessionalInfoStep extends StatelessWidget {
  const ProfessionalInfoStep({required this.controller, super.key});

  final CvBuilderController controller;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return ListView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      children: [
        const ResumeSectionIntro(
          title: 'Professional positioning',
          description:
              'Write a precise headline and summary for the role you want next.',
        ),
        const SizedBox(height: 24),
        ProfileSectionCard(
          title: 'Professional profile',
          subtitle: 'This appears at the top of your CV.',
          icon: FLucideIcons.userRoundSearch,
          children: [
            CompactInput(
              label: 'Professional title',
              hintText: 'Senior Flutter Developer',
              controller: controller.titleController,
            ),
            const SizedBox(height: 16),
            const FieldLabel('Professional summary'),
            const SizedBox(height: 8),
            MultiLineField(
              controller: controller.summaryController,
              hintText:
                  'Example: Flutter developer with 4 years of experience building reliable mobile products for fintech and ecommerce teams.',
              maxLength: 600,
            ),
            const SizedBox(height: 10),
            Text(
              'Keep it to 2–4 sentences. Lead with experience, specialty, and measurable impact.',
              style: TextStyle(
                color: palette.textTertiary,
                fontSize: 12,
                height: 1.4,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ProfileSectionCard(
          title: 'Core skills',
          subtitle: 'Add focused skills recruiters can search for.',
          icon: FLucideIcons.bolt,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: CompactInput(
                    label: 'Skill',
                    hintText: 'Flutter',
                    controller: controller.skillController,
                    onSubmitted: (_) => controller.addSkill(),
                  ),
                ),
                const SizedBox(width: 10),
                FButton.icon(
                  onPress: () {
                    HapticFeedback.selectionClick();
                    controller.addSkill();
                  },
                  child: const Icon(FLucideIcons.plus),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Obx(
              () => controller.skills.isEmpty
                  ? Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: palette.surfaceMuted,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        'Try 6–10 role-specific skills.',
                        style: TextStyle(
                          color: palette.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    )
                  : Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: controller.skills
                          .map(
                            (skill) => FButton(
                              variant: FButtonVariant.secondary,
                              onPress: () => controller.removeSkill(skill),
                              suffix: const Icon(FLucideIcons.x, size: 15),
                              child: Text(skill),
                            ),
                          )
                          .toList(),
                    ),
            ),
          ],
        ),
      ],
    );
  }
}
