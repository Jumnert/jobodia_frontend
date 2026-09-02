import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:forui/forui.dart';
import 'package:get/get.dart';
import 'package:jobodia_frontend/core/constants/app_colors.dart';
import 'package:jobodia_frontend/core/widgets/auto_scroll_on_focus.dart';
import 'package:jobodia_frontend/core/widgets/confirmation_dialog.dart';
import 'package:jobodia_frontend/features/profile/controller/profile_controller.dart';
import 'package:jobodia_frontend/features/profile/model/profile_model.dart';

import 'widgets/edit_profile_form_sections.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final ProfileController _ctrl;

  late final TextEditingController _name;
  late final TextEditingController _role;
  late final TextEditingController _about;

  // Each experience entry has its own set of controllers.
  late final List<_ExpControllers> _expControllers;

  // Skills
  late List<String> _skills;
  final TextEditingController _skillInput = TextEditingController();

  // Portfolio links
  late List<PortfolioControllers> _portfolioControllers;

  // Original values for dirty tracking
  late final String _origName;
  late final String _origRole;
  late final String _origAbout;
  late final List<String> _origSkills;
  final ScrollController _scrollController = ScrollController(
    keepScrollOffset: false,
  );
  final ValueNotifier<double> _headerCollapseProgress = ValueNotifier(0);

  @override
  void initState() {
    super.initState();
    _ctrl = Get.find<ProfileController>();
    final p = _ctrl.profile;
    _name = TextEditingController(text: p.name);
    _role = TextEditingController(text: p.role);
    _about = TextEditingController(text: p.about);
    _expControllers = p.experiences.map(_ExpControllers.fromModel).toList();
    _skills = List<String>.from(p.skills);
    _portfolioControllers = p.portfolioLinks
        .map(PortfolioControllers.fromModel)
        .toList();
    _origName = p.name;
    _origRole = p.role;
    _origAbout = p.about;
    _origSkills = List<String>.from(p.skills);
    _scrollController.addListener(_updateHeaderCollapse);
  }

  void _updateHeaderCollapse() {
    final next = (_scrollController.offset / 56).clamp(0.0, 1.0);
    if ((next - _headerCollapseProgress.value).abs() < 0.002) return;
    _headerCollapseProgress.value = next;
  }

  bool get _isDirty =>
      _name.text.trim() != _origName ||
      _role.text.trim() != _origRole ||
      _about.text.trim() != _origAbout ||
      _skills.length != _origSkills.length ||
      !_skills.every(_origSkills.contains);

  @override
  void dispose() {
    _scrollController.dispose();
    _headerCollapseProgress.dispose();
    _name.dispose();
    _role.dispose();
    _about.dispose();
    _skillInput.dispose();
    for (final c in _expControllers) {
      c.dispose();
    }
    for (final c in _portfolioControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _addSkill() {
    final skill = _skillInput.text.trim();
    if (skill.isNotEmpty && !_skills.contains(skill)) {
      setState(() {
        _skills.add(skill);
        _skillInput.clear();
      });
    }
  }

  void _removeSkill(int index) {
    unawaited(HapticFeedback.lightImpact());
    setState(() => _skills.removeAt(index));
  }

  void _addPortfolioLink() {
    setState(() => _portfolioControllers.add(PortfolioControllers.empty()));
  }

  void _removePortfolioLink(int index) {
    unawaited(HapticFeedback.lightImpact());
    setState(() {
      _portfolioControllers[index].dispose();
      _portfolioControllers.removeAt(index);
    });
  }

  void _addExperience() {
    setState(() => _expControllers.add(_ExpControllers.empty()));
  }

  void _removeExperience(int index) {
    unawaited(HapticFeedback.lightImpact());
    setState(() {
      _expControllers[index].dispose();
      _expControllers.removeAt(index);
    });
  }

  void _save() {
    if (_name.text.trim().isEmpty) {
      Get.snackbar(
        'Name required',
        'Please enter your name before saving.',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
      return;
    }
    final updated = _ctrl.profile.copyWith(
      name: _name.text.trim(),
      role: _role.text.trim(),
      about: _about.text.trim(),
      experiences: _expControllers.map((c) => c.toModel()).toList(),
      skills: _skills,
      portfolioLinks: _portfolioControllers.map((c) => c.toModel()).toList(),
    );
    _ctrl.updateProfile(updated);
    Get.back<void>();
    Get.snackbar(
      'Saved',
      'Profile updated successfully.',
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
    );
  }

  Future<void> _showAvatarPhotoDialog() async {
    final action = await showFDialog<_AvatarPhotoAction>(
      context: context,
      builder: (context, _, animation) => FDialog(
        animation: animation,
        clipBehavior: Clip.antiAlias,
        semanticsLabel: 'Profile photo options',
        builder: (context, _) => Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Profile photo',
                style: FTheme.of(context).typography.display.lg,
              ),
              const SizedBox(height: 8),
              Text(
                'Choose a photo. It will be cropped to a circle for your profile.',
                style: FTheme.of(context).typography.body.sm,
              ),
              const SizedBox(height: 20),
              FButton(
                onPress: () =>
                    Navigator.of(context).pop(_AvatarPhotoAction.choose),
                child: const Text('Choose photo'),
              ),
              if (_ctrl.profile.hasAvatarBytes) ...[
                const SizedBox(height: 10),
                FButton(
                  variant: FButtonVariant.destructive,
                  onPress: () =>
                      Navigator.of(context).pop(_AvatarPhotoAction.remove),
                  child: const Text('Remove custom photo'),
                ),
              ],
              const SizedBox(height: 10),
              FButton(
                variant: FButtonVariant.secondary,
                onPress: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
            ],
          ),
        ),
      ),
    );

    switch (action) {
      case _AvatarPhotoAction.choose:
        await _ctrl.pickAvatar();
      case _AvatarPhotoAction.remove:
        _ctrl.removeAvatar();
      case null:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final safeArea = MediaQuery.paddingOf(context);
    final header = _CollapsingEditProfileHeader(
      progress: _headerCollapseProgress,
      onBack: () => Navigator.of(context).maybePop(),
      onSave: _save,
    );

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (!_isDirty) {
          Navigator.of(context).pop();
          return;
        }
        final discard = await showConfirmationDialog(
          title: 'Discard changes?',
          message: 'You have unsaved changes. Are you sure you want to leave?',
          confirmLabel: 'Discard',
          cancelLabel: 'Stay',
          isDestructive: true,
        );
        if (discard == true && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor: palette.scaffold,
        body: Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.brandPrimary.withValues(
                        alpha: isDark ? 0.26 : 0.2,
                      ),
                      AppColors.brandPrimary.withValues(
                        alpha: isDark ? 0.08 : 0.055,
                      ),
                      palette.scaffold,
                    ],
                  ),
                ),
              ),
            ),
            ValueListenableBuilder<double>(
              valueListenable: _headerCollapseProgress,
              builder: (context, progress, _) {
                final eased = Curves.easeOutCubic.transform(progress);
                return Positioned(
                  top: safeArea.top + 150 - (76 * eased),
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(26),
                    ),
                    child: ColoredBox(
                      color: palette.surface,
                      child: SingleChildScrollView(
                        controller: _scrollController,
                        physics: const BouncingScrollPhysics(
                          parent: AlwaysScrollableScrollPhysics(),
                        ),
                        padding: EdgeInsets.fromLTRB(
                          20,
                          24,
                          20,
                          safeArea.bottom + 32,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // --- Avatar + Cover image pickers ---
                            Obx(() {
                              final p = _ctrl.profile;
                              return Row(
                                children: [
                                  // Avatar
                                  GestureDetector(
                                    onTap: _showAvatarPhotoDialog,
                                    child: Stack(
                                      children: [
                                        CircleAvatar(
                                          radius: 38,
                                          backgroundColor: AppColors.background,
                                          backgroundImage: p.hasAvatarBytes
                                              ? MemoryImage(p.avatarBytes!)
                                              : (p.avatarImageUrl.isNotEmpty
                                                        ? NetworkImage(
                                                            p.avatarImageUrl,
                                                          )
                                                        : null)
                                                    as ImageProvider?,
                                          child:
                                              (p.avatarImageUrl.isEmpty &&
                                                  !p.hasAvatarBytes)
                                              ? const Icon(
                                                  FLucideIcons.user,
                                                  size: 32,
                                                  color:
                                                      AppColors.textSecondary,
                                                )
                                              : null,
                                        ),
                                        Positioned(
                                          bottom: 0,
                                          right: 0,
                                          child: Container(
                                            width: 26,
                                            height: 26,
                                            decoration: BoxDecoration(
                                              color: AppColors.primary,
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: Colors.white,
                                                width: 2,
                                              ),
                                            ),
                                            child: const Icon(
                                              FLucideIcons.camera,
                                              size: 13,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  // Cover
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: _ctrl.pickCover,
                                      child: Container(
                                        height: 76,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          color: AppColors.background,
                                          image: p.hasCoverBytes
                                              ? DecorationImage(
                                                  image: MemoryImage(
                                                    p.coverBytes!,
                                                  ),
                                                  fit: BoxFit.cover,
                                                )
                                              : (p.coverImageUrl.isNotEmpty
                                                    ? DecorationImage(
                                                        image: NetworkImage(
                                                          p.coverImageUrl,
                                                        ),
                                                        fit: BoxFit.cover,
                                                      )
                                                    : null),
                                        ),
                                        child: Center(
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 5,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.black.withValues(
                                                alpha: 0.45,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: const Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  FLucideIcons.camera,
                                                  size: 14,
                                                  color: Colors.white,
                                                ),
                                                SizedBox(width: 5),
                                                Text(
                                                  'Change cover',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }),
                            const SizedBox(height: 20),
                            BasicInfoSection(
                              nameCtrl: _name,
                              roleCtrl: _role,
                              aboutCtrl: _about,
                            ),
                            const SizedBox(height: 24),
                            SectionLabel('Experience'),
                            const SizedBox(height: 12),
                            ...List.generate(_expControllers.length, (i) {
                              return _ExperienceCard(
                                index: i,
                                controllers: _expControllers[i],
                                onRemove: () => _removeExperience(i),
                              );
                            }),
                            const SizedBox(height: 8),
                            OutlinedButton.icon(
                              onPressed: _addExperience,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.primary,
                                side: const BorderSide(
                                  color: AppColors.primary,
                                ),
                                shape: const StadiumBorder(),
                                minimumSize: const Size.fromHeight(44),
                              ),
                              icon: const Icon(FLucideIcons.plus, size: 18),
                              label: const Text('Add Experience'),
                            ),
                            const SizedBox(height: 24),
                            SectionLabel('Skills'),
                            const SizedBox(height: 12),
                            _SkillsEditor(
                              skills: _skills,
                              controller: _skillInput,
                              onAdd: _addSkill,
                              onRemove: _removeSkill,
                            ),
                            const SizedBox(height: 24),
                            LinksSection(
                              portfolioControllers: _portfolioControllers,
                              onAdd: _addPortfolioLink,
                              onRemove: _removePortfolioLink,
                            ),
                            const SizedBox(height: 24),
                            SaveProfileButton(onSave: _save),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            Positioned(top: 0, left: 0, right: 0, child: header),
          ],
        ),
      ),
    );
  }
}

enum _AvatarPhotoAction { choose, remove }

class _CollapsingEditProfileHeader extends StatelessWidget {
  const _CollapsingEditProfileHeader({
    required this.progress,
    required this.onBack,
    required this.onSave,
  });

  final ValueListenable<double> progress;
  final VoidCallback onBack;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<double>(
      valueListenable: progress,
      builder: (context, value, _) {
        final theme = FTheme.of(context);
        final safeTop = MediaQuery.paddingOf(context).top;
        final eased = Curves.easeOutCubic.transform(value);
        final height = safeTop + 150 - (76 * eased);

        return RepaintBoundary(
          child: SizedBox(
            height: height,
            child: ClipRect(
              child: Padding(
                padding: EdgeInsets.only(top: safeTop),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      height: 64,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Align(
                            alignment: Alignment(-eased, 0),
                            child: Transform.translate(
                              offset: Offset(62 * eased, 0),
                              child: Text(
                                'Edit Profile',
                                maxLines: 1,
                                style: theme.typography.body.xl.copyWith(
                                  color: theme.colors.foreground,
                                  fontSize: 31 - (7 * eased),
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.5 + (0.2 * eased),
                                ),
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: _EditProfileHeaderAction(
                              tooltip: 'Back',
                              icon: FLucideIcons.chevronLeft,
                              onPressed: onBack,
                              progress: eased,
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: _EditProfileHeaderAction(
                              tooltip: 'Save profile',
                              icon: FLucideIcons.check,
                              label: 'Save',
                              onPressed: onSave,
                              progress: eased,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _EditProfileHeaderAction extends StatelessWidget {
  const _EditProfileHeaderAction({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
    required this.progress,
    this.label,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;
  final double progress;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final colors = FTheme.of(context).colors;
    final expand = label == null
        ? 0.0
        : Curves.easeOutCubic.transform(progress);
    final textOpacity = Curves.easeIn.transform(
      ((expand - 0.2) / 0.8).clamp(0.0, 1.0),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Tooltip(
        message: tooltip,
        child: SizedBox(
          width: lerpDouble(44, label == null ? 44 : 100, expand)!,
          height: 44,
          child: Material(
            color: colors.background.withValues(
              alpha: 0.58 + (0.32 * progress),
            ),
            borderRadius: BorderRadius.circular(22),
            child: InkWell(
              onTap: onPressed,
              borderRadius: BorderRadius.circular(22),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 44,
                    child: Center(
                      child: Icon(icon, size: 20, color: colors.foreground),
                    ),
                  ),
                  if (label != null)
                    ClipRect(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        widthFactor: expand,
                        child: Opacity(
                          opacity: textOpacity,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 15),
                            child: Text(
                              label!,
                              maxLines: 1,
                              style: TextStyle(
                                color: colors.foreground,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Experience card (one per entry in the list)
// ---------------------------------------------------------------------------

class _ExperienceCard extends StatelessWidget {
  const _ExperienceCard({
    required this.index,
    required this.controllers,
    required this.onRemove,
  });

  final int index;
  final _ExpControllers controllers;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: palette.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(
                'Experience ${index + 1}',
                style: TextStyle(
                  color: palette.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(FLucideIcons.trash2, size: 20),
                color: AppColors.error,
                tooltip: 'Remove',
                onPressed: onRemove,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 12),
          EditField(
            label: 'Company',
            controller: controllers.company,
            hint: 'Company name',
            icon: FLucideIcons.building2,
          ),
          const SizedBox(height: 10),
          EditField(
            label: 'Title',
            controller: controllers.title,
            hint: 'Job title',
            icon: FLucideIcons.idCard,
          ),
          const SizedBox(height: 10),
          EditField(
            label: 'Duration',
            controller: controllers.duration,
            hint: 'e.g. 2 Years',
            icon: FLucideIcons.clock,
          ),
          const SizedBox(height: 10),
          EditField(
            label: 'Description',
            controller: controllers.description,
            hint: 'What did you do?',
            icon: FLucideIcons.fileText,
            minLines: 3,
            maxLines: 6,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Reusable inline field
// ---------------------------------------------------------------------------

class EditField extends StatelessWidget {
  const EditField({
    super.key,
    required this.label,
    required this.controller,
    required this.hint,
    required this.icon,
    this.minLines = 1,
    this.maxLines = 1,
    this.maxLength,
  });

  final String label;
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final int minLines;
  final int maxLines;
  final int? maxLength;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: palette.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 5),
        AutoScrollOnFocus(
          child: TextField(
            controller: controller,
            minLines: minLines,
            maxLines: maxLines,
            maxLength: maxLength,
            keyboardType: maxLines > 1
                ? TextInputType.multiline
                : TextInputType.text,
            textInputAction: maxLines > 1
                ? TextInputAction.newline
                : TextInputAction.next,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: AppColors.hint, fontSize: 14),
              filled: true,
              fillColor: palette.surfaceMuted,
              prefixIcon: Icon(icon, color: palette.iconMuted, size: 20),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 1.4,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Section label
// ---------------------------------------------------------------------------

class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Text(
      text,
      style: TextStyle(
        color: palette.textPrimary,
        fontSize: 15,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Experience controller bundle — one per experience entry
// ---------------------------------------------------------------------------

class _ExpControllers {
  _ExpControllers({
    required this.company,
    required this.title,
    required this.duration,
    required this.description,
  });

  factory _ExpControllers.fromModel(ExperienceModel m) => _ExpControllers(
    company: TextEditingController(text: m.company),
    title: TextEditingController(text: m.title),
    duration: TextEditingController(text: m.duration),
    description: TextEditingController(text: m.description),
  );

  factory _ExpControllers.empty() => _ExpControllers(
    company: TextEditingController(),
    title: TextEditingController(),
    duration: TextEditingController(),
    description: TextEditingController(),
  );

  final TextEditingController company;
  final TextEditingController title;
  final TextEditingController duration;
  final TextEditingController description;

  ExperienceModel toModel() => ExperienceModel(
    company: company.text.trim(),
    title: title.text.trim(),
    duration: duration.text.trim(),
    description: description.text.trim(),
  );

  void dispose() {
    company.dispose();
    title.dispose();
    duration.dispose();
    description.dispose();
  }
}

// ---------------------------------------------------------------------------
// Skills editor
// ---------------------------------------------------------------------------

class _SkillsEditor extends StatelessWidget {
  const _SkillsEditor({
    required this.skills,
    required this.controller,
    required this.onAdd,
    required this.onRemove,
  });

  final List<String> skills;
  final TextEditingController controller;
  final VoidCallback onAdd;
  final void Function(int index) onRemove;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Input row
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                onSubmitted: (_) => onAdd(),
                decoration: InputDecoration(
                  hintText: 'e.g. Flutter, Python…',
                  hintStyle: const TextStyle(
                    color: AppColors.hint,
                    fontSize: 14,
                  ),
                  filled: true,
                  fillColor: palette.surfaceMuted,
                  prefixIcon: Icon(
                    FLucideIcons.brain,
                    color: palette.iconMuted,
                    size: 20,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: AppColors.primary,
                      width: 1.4,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: onAdd,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                child: const Text('Add'),
              ),
            ),
          ],
        ),
        // Displayed skills
        if (skills.isNotEmpty) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(skills.length, (i) {
              return Chip(
                label: Text(
                  skills[i],
                  style: TextStyle(color: palette.textPrimary, fontSize: 13),
                ),
                backgroundColor: palette.surfaceMuted,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide.none,
                ),
                deleteIcon: Icon(
                  FLucideIcons.x,
                  size: 16,
                  color: palette.textSecondary,
                ),
                onDeleted: () => onRemove(i),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
              );
            }),
          ),
        ],
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Portfolio link card (one per entry)
// ---------------------------------------------------------------------------

class PortfolioCard extends StatelessWidget {
  const PortfolioCard({
    super.key,
    required this.index,
    required this.controllers,
    required this.onRemove,
  });

  final int index;
  final PortfolioControllers controllers;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: palette.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(
                'Link ${index + 1}',
                style: TextStyle(
                  color: palette.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(FLucideIcons.trash2, size: 20),
                color: AppColors.error,
                tooltip: 'Remove',
                onPressed: onRemove,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 12),
          EditField(
            label: 'Title',
            controller: controllers.title,
            hint: 'e.g. GitHub, Portfolio',
            icon: FLucideIcons.tag,
          ),
          const SizedBox(height: 10),
          EditField(
            label: 'URL',
            controller: controllers.url,
            hint: 'https://…',
            icon: FLucideIcons.link,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Portfolio controller bundle — one per portfolio entry
// ---------------------------------------------------------------------------

class PortfolioControllers {
  PortfolioControllers({required this.title, required this.url});

  factory PortfolioControllers.fromModel(PortfolioLink m) =>
      PortfolioControllers(
        title: TextEditingController(text: m.title),
        url: TextEditingController(text: m.url),
      );

  factory PortfolioControllers.empty() => PortfolioControllers(
    title: TextEditingController(),
    url: TextEditingController(),
  );

  final TextEditingController title;
  final TextEditingController url;

  PortfolioLink toModel() =>
      PortfolioLink(title: title.text.trim(), url: url.text.trim());

  void dispose() {
    title.dispose();
    url.dispose();
  }
}
