import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:jobodia_frontend/core/constants/app_colors.dart';
import 'package:jobodia_frontend/features/preferences/controller/preferences_controller.dart';

class PreferencesWizardScreen extends GetView<PreferencesController> {
  const PreferencesWizardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: palette.scaffold,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: palette.scaffold,
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: Obx(
                  () => _WizardBody(step: controller.currentStep.value),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _WizardBody extends GetView<PreferencesController> {
  const _WizardBody({required this.step});

  final int step;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header row: back + step counter
        Row(
          children: [
            if (step > 0)
              IconButton(
                onPressed: controller.goBack,
                icon: Icon(
                  Icons.arrow_back_rounded,
                  color: palette.iconPrimary,
                ),
                tooltip: 'Back',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              )
            else
              const SizedBox(width: 24),
            const Spacer(),
            Text(
              'Step ${step + 1} of 3',
              style: TextStyle(
                color: palette.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Progress bar
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: (step + 1) / 3,
            minHeight: 3,
            backgroundColor: palette.border,
            valueColor: const AlwaysStoppedAnimation(AppColors.accentPurple),
          ),
        ),
        const SizedBox(height: 28),
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 280),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.06, 0),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            ),
            child: KeyedSubtree(
              key: ValueKey(step),
              child: switch (step) {
                0 => const _RoleStep(),
                1 => const _LevelStep(),
                _ => const _LocationStep(),
              },
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Step 1 — Desired role
// ---------------------------------------------------------------------------

class _RoleStep extends GetView<PreferencesController> {
  const _RoleStep();

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return _StepCard(
      title: "What role are\nyou looking for?",
      subtitle: 'Type it in or pick one below.',
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Free-text field
          TextField(
            onChanged: controller.selectRole,
            style: TextStyle(color: palette.textPrimary),
            decoration: InputDecoration(
              hintText: 'e.g. Flutter Developer',
              hintStyle: TextStyle(color: palette.textTertiary, fontSize: 14),
              filled: true,
              fillColor: palette.surfaceMuted,
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
                borderSide: const BorderSide(color: AppColors.accentPurple),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 10,
            children: PreferencesController.roles
                .map(
                  (role) => Obx(
                    () => _SelectChip(
                      label: role,
                      selected: controller.desiredRole.value == role,
                      onTap: () => controller.selectRole(role),
                    ),
                  ),
                )
                .toList(),
          ),
          const Spacer(),
          _NextButton(
            label: 'Next',
            enabled: true,
            onPressed: controller.goNext,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Step 2 — Experience level
// ---------------------------------------------------------------------------

class _LevelStep extends GetView<PreferencesController> {
  const _LevelStep();

  @override
  Widget build(BuildContext context) {
    return _StepCard(
      title: 'Your experience\nlevel?',
      subtitle: 'We\'ll filter jobs that fit you best.',
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 10,
            children: PreferencesController.levels
                .map(
                  (level) => Obx(
                    () => _SelectChip(
                      label: level,
                      selected: controller.experienceLevel.value == level,
                      onTap: () => controller.selectLevel(level),
                    ),
                  ),
                )
                .toList(),
          ),
          const Spacer(),
          Obx(
            () => _NextButton(
              label: 'Next',
              enabled: controller.experienceLevel.value.isNotEmpty,
              onPressed: controller.goNext,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Step 3 — Preferred location
// ---------------------------------------------------------------------------

class _LocationStep extends GetView<PreferencesController> {
  const _LocationStep();

  @override
  Widget build(BuildContext context) {
    return _StepCard(
      title: 'Where do you\nwant to work?',
      subtitle: 'Pick your preferred work location.',
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 10,
            children: PreferencesController.locations
                .map(
                  (loc) => Obx(
                    () => _SelectChip(
                      label: loc,
                      selected: controller.preferredLocation.value == loc,
                      onTap: () => controller.selectLocation(loc),
                    ),
                  ),
                )
                .toList(),
          ),
          const Spacer(),
          Obx(
            () => _NextButton(
              label: 'Done',
              enabled: controller.preferredLocation.value.isNotEmpty,
              onPressed: controller.complete,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared card wrapper
// ---------------------------------------------------------------------------

class _StepCard extends StatelessWidget {
  const _StepCard({
    required this.title,
    required this.subtitle,
    required this.content,
  });

  final String title;
  final String subtitle;
  final Widget content;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 26, 22, 22),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: palette.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.accentPurple.withValues(alpha: 0.08),
            blurRadius: 40,
            spreadRadius: 4,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: palette.textPrimary,
              fontSize: 26,
              fontWeight: FontWeight.w800,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: TextStyle(
              color: palette.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 18),
          Expanded(child: content),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Chip
// ---------------------------------------------------------------------------

class _SelectChip extends StatelessWidget {
  const _SelectChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return GestureDetector(
      onTap: () {
        unawaited(HapticFeedback.lightImpact());
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.accentPurple.withValues(alpha: 0.22)
              : palette.surfaceMuted,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: selected ? AppColors.accentPurple : palette.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? palette.textPrimary : palette.textSecondary,
            fontSize: 13.5,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Next / Done button
// ---------------------------------------------------------------------------

class _NextButton extends StatelessWidget {
  const _NextButton({
    required this.label,
    required this.enabled,
    required this.onPressed,
  });

  final String label;
  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: enabled ? 1 : 0.45,
      duration: const Duration(milliseconds: 180),
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(26),
          gradient: const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [AppColors.accentPurpleDark, AppColors.accentPurple],
          ),
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: AppColors.accentPurple.withValues(alpha: 0.28),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(26),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: enabled ? onPressed : null,
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    color: Colors.white,
                    size: 18,
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
