import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
          icon: Icons.person_search_outlined,
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
          icon: Icons.bolt_outlined,
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
                SizedBox(
                  width: 48,
                  height: 48,
                  child: FilledButton(
                    onPressed: () {
                      HapticFeedback.selectionClick();
                      controller.addSkill();
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.brandTeal,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Icon(Icons.add_rounded),
                  ),
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
                            (skill) => InputChip(
                              label: Text(skill),
                              onDeleted: () => controller.removeSkill(skill),
                              deleteIcon: const Icon(
                                Icons.close_rounded,
                                size: 16,
                              ),
                              backgroundColor: AppColors.brandTeal.withValues(
                                alpha: 0.10,
                              ),
                              side: BorderSide(
                                color: AppColors.brandTeal.withValues(
                                  alpha: 0.2,
                                ),
                              ),
                              shape: const StadiumBorder(),
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
