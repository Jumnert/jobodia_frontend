import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jobodia_frontend/core/constants/app_colors.dart';
import 'package:jobodia_frontend/core/widgets/custom_button.dart';
import 'package:jobodia_frontend/core/widgets/custom_text_field.dart';
import 'package:jobodia_frontend/features/cv_builder/controller/cv_builder_controller.dart';
import 'package:jobodia_frontend/features/home/view/widgets/app_bottom_navigation_bar.dart';
import 'package:jobodia_frontend/features/home/view/widgets/app_navigation.dart';
import 'package:jobodia_frontend/features/search/view/search_screen.dart';

class CvBuilderScreen extends GetView<CvBuilderController> {
  const CvBuilderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      extendBody: true,
      body: Padding(
        padding: EdgeInsets.only(top: MediaQuery.paddingOf(context).top),
        child: Column(
          children: [
            const _Header(),
            Expanded(
              child: Obx(() {
                switch (controller.stepIndex.value) {
                  case 0:
                    return _BasicInfoStep(controller: controller);
                  case 1:
                    return _WorkInfoStep(controller: controller);
                  default:
                    return _TemplateStep(controller: controller);
                }
              }),
            ),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNavigationBar(
        selectedIndex: 1,
        onDestinationSelected: (index) =>
            navigateMainDestination(context, index, currentIndex: 1),
        onSearchPressed: () => Navigator.of(
          context,
        ).push(MaterialPageRoute<void>(builder: (_) => const SearchScreen())),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: Get.back,
                icon: const Icon(Icons.chevron_left_rounded, size: 30),
              ),
              const Expanded(
                child: Text(
                  'Create CV',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
          const SizedBox(height: 8),
          Obx(() {
            final step = Get.find<CvBuilderController>().stepIndex.value;
            return Row(
              children: List.generate(
                3,
                (index) => Expanded(
                  child: Container(
                    height: 6,
                    margin: EdgeInsets.only(right: index == 2 ? 0 : 10),
                    decoration: BoxDecoration(
                      color: index <= step
                          ? Colors.black
                          : const Color(0xFFD9D9D9),
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: 10),
          Obx(() {
            final step = Get.find<CvBuilderController>().stepIndex.value;
            return Text(
              'Step ${step + 1}',
              style: const TextStyle(
                color: Color(0xFF9A9A9A),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _BasicInfoStep extends StatelessWidget {
  const _BasicInfoStep({required this.controller});

  final CvBuilderController controller;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 112),
      children: [
        const Text(
          'Ready to make a CV?',
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        const Text(
          'Start with the basic details so the CV can match your profile.',
          style: TextStyle(fontSize: 15, color: Color(0xFF777777), height: 1.4),
        ),
        const SizedBox(height: 20),
        const _InfoIconLine(
          icon: Icons.person_rounded,
          text: 'Headshot, full name, email, phone number, and location',
        ),
        const SizedBox(height: 18),
        _HeadshotUploadTile(controller: controller),
        const SizedBox(height: 18),
        CustomTextField(
          label: 'Full name',
          hintText: 'Your full name',
          controller: controller.fullNameController,
          prefixIcon: Icons.person_outline_rounded,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          label: 'Email',
          hintText: 'example@gmail.com',
          controller: controller.emailController,
          prefixIcon: Icons.mail_outline_rounded,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          label: 'Phone number',
          hintText: '+855 12 345 678',
          controller: controller.phoneController,
          prefixIcon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          label: 'Location',
          hintText: 'City, Country',
          controller: controller.locationController,
          prefixIcon: Icons.location_on_outlined,
        ),
        const SizedBox(height: 24),
        CustomButton(label: 'Continue', onPressed: controller.nextStep),
      ],
    );
  }
}

class _HeadshotUploadTile extends StatelessWidget {
  const _HeadshotUploadTile({required this.controller});

  final CvBuilderController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFF6F6F6),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE8E8E8)),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 34,
              backgroundColor: controller.hasHeadshot.value
                  ? Colors.black
                  : Colors.white,
              child: Icon(
                controller.hasHeadshot.value
                    ? Icons.person_rounded
                    : Icons.add_a_photo_outlined,
                color: controller.hasHeadshot.value
                    ? Colors.white
                    : const Color(0xFF777777),
                size: 28,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    controller.hasHeadshot.value
                        ? 'Headshot selected'
                        : 'Upload headshot',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Add a clear professional photo for templates that include a profile image.',
                    style: TextStyle(
                      color: Color(0xFF777777),
                      fontSize: 13,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            TextButton(
              onPressed: controller.hasHeadshot.value
                  ? controller.removeHeadshot
                  : controller.chooseHeadshot,
              child: Text(controller.hasHeadshot.value ? 'Remove' : 'Choose'),
            ),
          ],
        ),
      ),
    );
  }
}

class _WorkInfoStep extends StatelessWidget {
  const _WorkInfoStep({required this.controller});

  final CvBuilderController controller;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 112),
      children: [
        const Text(
          'Tell us about your work',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        const Text(
          'Build this like a LinkedIn profile. Add clear roles, schools, dates, skills, and achievements so AI can shape a strong CV.',
          style: TextStyle(fontSize: 15, color: Color(0xFF777777), height: 1.4),
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
          () => _ProfileSectionCard(
            title: 'Work experience',
            subtitle:
                'Add up to 3 roles with company, dates, responsibilities, and measurable wins.',
            icon: Icons.work_outline_rounded,
            children: [
              ...controller.workExperiences.map(
                (entry) => _WorkExperienceEntry(
                  controller: controller,
                  entry: entry,
                  index: controller.workExperiences.indexOf(entry),
                ),
              ),
              const SizedBox(height: 12),
              _AddEntryButton(
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
          () => _ProfileSectionCard(
            title: 'Education',
            subtitle:
                'Add up to 3 schools or universities with degree, dates, and useful notes.',
            icon: Icons.school_outlined,
            children: [
              ...controller.educations.map(
                (entry) => _EducationEntry(
                  controller: controller,
                  entry: entry,
                  index: controller.educations.indexOf(entry),
                ),
              ),
              const SizedBox(height: 12),
              _AddEntryButton(
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
        _ProfileSectionCard(
          title: 'Skills',
          subtitle:
              'Add one skill at a time. Keep them specific and searchable.',
          icon: Icons.auto_awesome_outlined,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: _CompactInput(
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
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
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
                  ? const Text(
                      'No skills added yet.',
                      style: TextStyle(color: Color(0xFF8A8A8A), fontSize: 13),
                    )
                  : Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: controller.skills
                          .map(
                            (skill) => InputChip(
                              label: Text(skill),
                              onDeleted: () => controller.removeSkill(skill),
                              backgroundColor: const Color(0xFFF2F2F2),
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
        const _FieldLabel('Summary'),
        const SizedBox(height: 8),
        _MultiLineField(
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

class _TemplateStep extends StatelessWidget {
  const _TemplateStep({required this.controller});

  final CvBuilderController controller;

  @override
  Widget build(BuildContext context) {
    final templates = [
      const _TemplateMeta(
        title: 'Classic',
        subtitle: 'Clean and simple layout',
      ),
      const _TemplateMeta(
        title: 'Balanced',
        subtitle: 'Split sections and modern spacing',
      ),
      const _TemplateMeta(
        title: 'Modern',
        subtitle: 'Compact with strong heading focus',
      ),
    ];

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 112),
      children: [
        const Text(
          'Choose a template you like',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        const Text(
          'You can change it later anytime.',
          style: TextStyle(fontSize: 15, color: Color(0xFF777777), height: 1.4),
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
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: controller.selectedTemplateIndex.value == index
                          ? Colors.black
                          : const Color(0xFFD8D8D8),
                      width: controller.selectedTemplateIndex.value == index
                          ? 1.8
                          : 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _TemplatePreviewCard(
                          title: templates[index].title,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        templates[index].title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        templates[index].subtitle,
                        style: const TextStyle(
                          color: Color(0xFF777777),
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
        CustomButton(label: 'Generate CV', onPressed: controller.nextStep),
        const SizedBox(height: 10),
        Text(
          'AI will create your professional CV',
          textAlign: TextAlign.center,
          style: const TextStyle(color: Color(0xFF9A9A9A), fontSize: 14),
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

class _InfoIconLine extends StatelessWidget {
  const _InfoIconLine({required this.icon, required this.text});

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
            style: const TextStyle(
              color: Color(0xFF777777),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
    );
  }
}

class _ProfileSectionCard extends StatelessWidget {
  const _ProfileSectionCard({
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE8E8E8)),
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
                decoration: const BoxDecoration(
                  color: Colors.black,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Color(0xFF7A7A7A),
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

class _WorkExperienceEntry extends StatelessWidget {
  const _WorkExperienceEntry({
    required this.controller,
    required this.entry,
    required this.index,
  });

  final CvBuilderController controller;
  final CvWorkExperienceForm entry;
  final int index;

  @override
  Widget build(BuildContext context) {
    return _RepeatableEntryCard(
      title: 'Experience ${index + 1}',
      canRemove: controller.workExperiences.length > 1,
      onRemove: () => controller.removeWorkExperience(entry),
      children: [
        _CompactInput(
          label: 'Role',
          hintText: 'UX Designer',
          controller: entry.roleController,
        ),
        const SizedBox(height: 12),
        _CompactInput(
          label: 'Company',
          hintText: 'NovaTech Labs',
          controller: entry.companyController,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _DatePickerField(
                label: 'Start date',
                hintText: 'Jan 2023',
                controller: entry.startController,
                initialDate: entry.startDate,
                onChanged: (date) => controller.setWorkStartDate(entry, date),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _DatePickerField(
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
        _MultiLineField(
          controller: entry.descriptionController,
          hintText:
              'Describe responsibilities, achievements, tools, and impact...',
        ),
      ],
    );
  }
}

class _EducationEntry extends StatelessWidget {
  const _EducationEntry({
    required this.controller,
    required this.entry,
    required this.index,
  });

  final CvBuilderController controller;
  final CvEducationForm entry;
  final int index;

  @override
  Widget build(BuildContext context) {
    return _RepeatableEntryCard(
      title: 'Education ${index + 1}',
      canRemove: controller.educations.length > 1,
      onRemove: () => controller.removeEducation(entry),
      children: [
        _CompactInput(
          label: 'School / University',
          hintText: 'Royal University of Phnom Penh',
          controller: entry.schoolController,
        ),
        const SizedBox(height: 12),
        _CompactInput(
          label: 'Degree / Program',
          hintText: 'Bachelor of Computer Science',
          controller: entry.degreeController,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _DatePickerField(
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
              child: _DatePickerField(
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
        _MultiLineField(
          controller: entry.descriptionController,
          hintText:
              'Add awards, coursework, thesis, clubs, or relevant projects...',
        ),
      ],
    );
  }
}

class _RepeatableEntryCard extends StatelessWidget {
  const _RepeatableEntryCard({
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
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFBFBFB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEDEDED)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
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

class _AddEntryButton extends StatelessWidget {
  const _AddEntryButton({
    required this.label,
    required this.note,
    required this.onPressed,
  });

  final String label;
  final String note;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onPressed,
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.black,
              side: const BorderSide(color: Colors.black),
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
          style: const TextStyle(color: Color(0xFF8A8A8A), fontSize: 12),
        ),
      ],
    );
  }
}

class _DatePickerField extends StatelessWidget {
  const _DatePickerField({
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
        child: _CompactInput(
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

class _CompactInput extends StatelessWidget {
  const _CompactInput({
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Color(0xFF3A3A3A),
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          onSubmitted: onSubmitted,
          decoration: InputDecoration(
            hintText: hintText,
            filled: true,
            fillColor: const Color(0xFFF6F6F6),
            hintStyle: const TextStyle(color: Color(0xFF9A9A9A), fontSize: 13),
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

class _MultiLineField extends StatelessWidget {
  const _MultiLineField({required this.controller, required this.hintText});

  final TextEditingController controller;
  final String hintText;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      minLines: 3,
      maxLines: 5,
      decoration: InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: const Color(0xFFF6F6F6),
        hintStyle: const TextStyle(color: Color(0xFF9A9A9A), fontSize: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class _TemplatePreviewCard extends StatelessWidget {
  const _TemplatePreviewCard({required this.title});

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
                const _LineBlock(widthFactor: 0.92),
                const SizedBox(height: 6),
                const _LineBlock(widthFactor: 0.82),
                const SizedBox(height: 6),
                const _LineBlock(widthFactor: 0.66),
                const SizedBox(height: 12),
                const _SectionRow(label: 'PROFILE'),
                const SizedBox(height: 8),
                const _LineBlock(widthFactor: 1),
                const SizedBox(height: 6),
                const _LineBlock(widthFactor: 0.88),
                const SizedBox(height: 12),
                const _SectionRow(label: 'SKILLS'),
                const SizedBox(height: 8),
                const _DotLine(),
                const SizedBox(height: 4),
                const _DotLine(),
                const SizedBox(height: 4),
                const _DotLine(widthFactor: 0.75),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LineBlock extends StatelessWidget {
  const _LineBlock({required this.widthFactor});

  final double widthFactor;

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: widthFactor,
      child: Container(height: 4, decoration: _lineDecoration),
    );
  }
}

class _DotLine extends StatelessWidget {
  const _DotLine({this.widthFactor = 0.9});

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

class _SectionRow extends StatelessWidget {
  const _SectionRow({required this.label});

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

class _TemplateMeta {
  const _TemplateMeta({required this.title, required this.subtitle});

  final String title;
  final String subtitle;
}

const _lineDecoration = BoxDecoration(
  color: Color(0xFFD8D8D8),
  borderRadius: BorderRadius.all(Radius.circular(99)),
);
