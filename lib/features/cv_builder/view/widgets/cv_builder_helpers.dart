import 'package:jobodia_frontend/features/cv_builder/model/cv_form_classes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jobodia_frontend/core/constants/app_colors.dart';
import 'package:jobodia_frontend/features/cv_builder/controller/cv_builder_controller.dart';

/// Icon + text helper used in step forms.
class InfoIconLine extends StatelessWidget {
  const InfoIconLine({super.key, required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: context.palette.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

/// Headshot upload tile used in the basic info step.
class HeadshotUploadTile extends StatelessWidget {
  const HeadshotUploadTile({super.key, required this.controller});

  final CvBuilderController controller;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Obx(
      () => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: palette.surfaceMuted,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: palette.border),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 34,
              backgroundColor: controller.hasHeadshot
                  ? palette.textPrimary
                  : palette.surface,
              backgroundImage: controller.hasHeadshot
                  ? MemoryImage(controller.headshotBytes.value!)
                  : null,
              child: controller.hasHeadshot
                  ? null
                  : Icon(
                      Icons.add_a_photo_outlined,
                      color: palette.iconMuted,
                      size: 28,
                    ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    controller.hasHeadshot
                        ? 'Headshot selected'
                        : 'Upload headshot',
                    style: TextStyle(
                      color: palette.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Add a clear professional photo for templates that include a profile image.',
                    style: TextStyle(
                      color: palette.textSecondary,
                      fontSize: 13,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            TextButton(
              onPressed: controller.hasHeadshot
                  ? controller.removeHeadshot
                  : controller.chooseHeadshot,
              child: Text(controller.hasHeadshot ? 'Remove' : 'Choose'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Section label used in work/education steps.
class FieldLabel extends StatelessWidget {
  const FieldLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: context.palette.textPrimary,
        fontSize: 15,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

/// Card wrapper for profile sections (work experience, education, skills).
class ProfileSectionCard extends StatelessWidget {
  const ProfileSectionCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.children,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: palette.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: palette.textPrimary,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: palette.surface, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: palette.textPrimary,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: palette.textSecondary,
                        fontSize: 13,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }
}

/// A single work experience entry card.
class WorkExperienceEntry extends StatelessWidget {
  const WorkExperienceEntry({
    super.key,
    required this.controller,
    required this.entry,
    required this.index,
  });

  final CvBuilderController controller;
  final CvWorkExperienceForm entry;
  final int index;

  @override
  Widget build(BuildContext context) {
    return RepeatableEntryCard(
      title: 'Experience ${index + 1}',
      canRemove: controller.workExperiences.length > 1,
      onRemove: () => controller.removeWorkExperience(entry),
      children: [
        CompactInput(
          label: 'Role',
          hintText: 'UX Designer',
          controller: entry.roleController,
        ),
        const SizedBox(height: 12),
        CompactInput(
          label: 'Company',
          hintText: 'NovaTech Labs',
          controller: entry.companyController,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: DatePickerField(
                label: 'Start date',
                hintText: 'Jan 2023',
                controller: entry.startController,
                initialDate: entry.startDate,
                onChanged: (date) => controller.setWorkStartDate(entry, date),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DatePickerField(
                label: 'End date',
                hintText: 'Present',
                controller: entry.endController,
                initialDate: entry.endDate,
                onChanged: (date) => controller.setWorkEndDate(entry, date),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        MultiLineField(
          controller: entry.descriptionController,
          hintText:
              'Describe responsibilities, achievements, tools, and impact...',
        ),
      ],
    );
  }
}

/// A single education entry card.
class EducationEntry extends StatelessWidget {
  const EducationEntry({
    super.key,
    required this.controller,
    required this.entry,
    required this.index,
  });

  final CvBuilderController controller;
  final CvEducationForm entry;
  final int index;

  @override
  Widget build(BuildContext context) {
    return RepeatableEntryCard(
      title: 'Education ${index + 1}',
      canRemove: controller.educations.length > 1,
      onRemove: () => controller.removeEducation(entry),
      children: [
        CompactInput(
          label: 'School / University',
          hintText: 'Royal University of Phnom Penh',
          controller: entry.schoolController,
        ),
        const SizedBox(height: 12),
        CompactInput(
          label: 'Degree / Program',
          hintText: 'Bachelor of Computer Science',
          controller: entry.degreeController,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: DatePickerField(
                label: 'Start date',
                hintText: 'Sep 2020',
                controller: entry.startController,
                initialDate: entry.startDate,
                onChanged: (date) =>
                    controller.setEducationStartDate(entry, date),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DatePickerField(
                label: 'End date',
                hintText: 'Jun 2024',
                controller: entry.endController,
                initialDate: entry.endDate,
                onChanged: (date) =>
                    controller.setEducationEndDate(entry, date),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        MultiLineField(
          controller: entry.descriptionController,
          hintText:
              'Add awards, coursework, thesis, clubs, or relevant projects...',
        ),
      ],
    );
  }
}

/// Reusable card for repeatable entries (work experience, education).
class RepeatableEntryCard extends StatelessWidget {
  const RepeatableEntryCard({
    super.key,
    required this.title,
    required this.canRemove,
    required this.onRemove,
    required this.children,
  });

  final String title;
  final bool canRemove;
  final VoidCallback onRemove;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: palette.surfaceMuted,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: palette.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: palette.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (canRemove)
                IconButton(
                  onPressed: onRemove,
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.close_rounded, size: 20),
                ),
            ],
          ),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }
}

/// Button to add a new repeatable entry.
class AddEntryButton extends StatelessWidget {
  const AddEntryButton({
    super.key,
    required this.label,
    required this.note,
    required this.onPressed,
  });

  final String label;
  final String note;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onPressed,
            style: OutlinedButton.styleFrom(
              foregroundColor: palette.textPrimary,
              side: BorderSide(color: palette.textPrimary),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            icon: const Icon(Icons.add_rounded),
            label: Text(label),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          note,
          style: TextStyle(color: palette.textSecondary, fontSize: 12),
        ),
      ],
    );
  }
}

/// A date picker field using a Cupertino modal popup.
class DatePickerField extends StatelessWidget {
  const DatePickerField({
    super.key,
    required this.label,
    required this.hintText,
    required this.controller,
    required this.initialDate,
    required this.onChanged,
  });

  final String label;
  final String hintText;
  final TextEditingController controller;
  final DateTime? initialDate;
  final ValueChanged<DateTime> onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _showPicker(context),
      child: AbsorbPointer(
        child: CompactInput(
          label: label,
          hintText: hintText,
          controller: controller,
        ),
      ),
    );
  }

  void _showPicker(BuildContext context) {
    var selectedDate = initialDate ?? DateTime.now();
    showCupertinoModalPopup<void>(
      context: context,
      builder: (context) => Container(
        height: 320,
        color: CupertinoColors.systemBackground.resolveFrom(context),
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              SizedBox(
                height: 46,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CupertinoButton(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    CupertinoButton(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      onPressed: () {
                        onChanged(selectedDate);
                        Navigator.of(context).pop();
                      },
                      child: const Text('Done'),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  initialDateTime: selectedDate,
                  minimumYear: 1970,
                  maximumYear: DateTime.now().year + 10,
                  onDateTimeChanged: (date) => selectedDate = date,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A compact text input field.
class CompactInput extends StatelessWidget {
  const CompactInput({
    super.key,
    required this.label,
    required this.hintText,
    required this.controller,
    this.onSubmitted,
  });

  final String label;
  final String hintText;
  final TextEditingController controller;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: palette.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          onSubmitted: onSubmitted,
          style: TextStyle(color: palette.textPrimary),
          decoration: InputDecoration(
            hintText: hintText,
            filled: true,
            fillColor: palette.surfaceMuted,
            hintStyle: TextStyle(color: palette.textTertiary, fontSize: 13),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 13,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}

/// A multi-line text field.
class MultiLineField extends StatelessWidget {
  const MultiLineField({
    super.key,
    required this.controller,
    required this.hintText,
  });

  final TextEditingController controller;
  final String hintText;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return TextField(
      controller: controller,
      minLines: 3,
      maxLines: 5,
      style: TextStyle(color: palette.textPrimary),
      decoration: InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: palette.surfaceMuted,
        hintStyle: TextStyle(color: palette.textTertiary, fontSize: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

/// A preview card shown in the template step.
class TemplatePreviewCard extends StatelessWidget {
  const TemplatePreviewCard({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE9E9E9)),
      ),
      child: FittedBox(
        fit: BoxFit.contain,
        alignment: Alignment.topCenter,
        child: SizedBox(
          width: 150,
          height: 225,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 14,
                      backgroundColor: Color(0xFFE0E0E0),
                      child: Icon(Icons.person, size: 16, color: Colors.white),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'YOUR NAME',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            title.toUpperCase(),
                            style: const TextStyle(
                              color: Color(0xFF777777),
                              fontSize: 8.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Container(height: 1, color: const Color(0xFFE2E2E2)),
                const SizedBox(height: 12),
                const LineBlock(widthFactor: 0.92),
                const SizedBox(height: 6),
                const LineBlock(widthFactor: 0.82),
                const SizedBox(height: 6),
                const LineBlock(widthFactor: 0.66),
                const SizedBox(height: 12),
                const SectionRow(label: 'PROFILE'),
                const SizedBox(height: 8),
                const LineBlock(widthFactor: 1),
                const SizedBox(height: 6),
                const LineBlock(widthFactor: 0.88),
                const SizedBox(height: 12),
                const SectionRow(label: 'SKILLS'),
                const SizedBox(height: 8),
                const DotLine(),
                const SizedBox(height: 4),
                const DotLine(),
                const SizedBox(height: 4),
                const DotLine(widthFactor: 0.75),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A horizontal line block for the template preview.
class LineBlock extends StatelessWidget {
  const LineBlock({super.key, required this.widthFactor});

  final double widthFactor;

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: widthFactor,
      child: Container(height: 4, decoration: _lineDecoration),
    );
  }
}

/// A dot + line block for the template preview.
class DotLine extends StatelessWidget {
  const DotLine({super.key, this.widthFactor = 0.9});

  final double widthFactor;

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: widthFactor,
      child: Row(
        children: [
          const Icon(Icons.circle, size: 4, color: Color(0xFFCFCFCF)),
          const SizedBox(width: 6),
          Expanded(child: Container(height: 4, decoration: _lineDecoration)),
        ],
      ),
    );
  }
}

/// A section row with a circle label for the template preview.
class SectionRow extends StatelessWidget {
  const SectionRow({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.black,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800),
        ),
      ],
    );
  }
}

/// Metadata for a CV template.
class TemplateMeta {
  const TemplateMeta({required this.title, required this.subtitle});

  final String title;
  final String subtitle;
}

const _lineDecoration = BoxDecoration(
  color: Color(0xFFD8D8D8),
  borderRadius: BorderRadius.all(Radius.circular(99)),
);
