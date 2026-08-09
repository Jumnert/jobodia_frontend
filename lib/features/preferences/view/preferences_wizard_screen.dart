import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:forui/forui.dart';
import 'package:get/get.dart';
import 'package:jobodia_frontend/core/constants/app_colors.dart';
import 'package:jobodia_frontend/features/preferences/controller/preferences_controller.dart';

class PreferencesWizardScreen extends GetView<PreferencesController> {
  const PreferencesWizardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final overlayBrightness = context.isDark
        ? Brightness.light
        : Brightness.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: overlayBrightness,
        systemNavigationBarColor: palette.scaffold,
        systemNavigationBarIconBrightness: overlayBrightness,
      ),
      child: FScaffold(
        childPad: false,
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Obx(() => _WizardBody(step: controller.currentStep.value)),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _WizardHeader(step: step),
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 320),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (child, animation) {
              final offset = Tween<Offset>(
                begin: const Offset(0.04, 0),
                end: Offset.zero,
              ).animate(animation);
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(position: offset, child: child),
              );
            },
            child: KeyedSubtree(
              key: ValueKey(step),
              child: switch (step) {
                0 => const _InterestsStep(),
                1 => const _RoleStep(),
                2 => const _LevelStep(),
                _ => const _LocationStep(),
              },
            ),
          ),
        ),
        _WizardFooter(step: step),
      ],
    );
  }
}

class _WizardHeader extends GetView<PreferencesController> {
  const _WizardHeader({required this.step});

  final int step;

  @override
  Widget build(BuildContext context) {
    final theme = FTheme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Column(
        children: [
          SizedBox(
            height: 44,
            child: Row(
              children: [
                SizedBox(
                  width: 44,
                  child: step == 0
                      ? null
                      : FButton.icon(
                          variant: FButtonVariant.ghost,
                          onPress: controller.goBack,
                          child: const Icon(FLucideIcons.arrowLeft),
                        ),
                ),
                Expanded(
                  child: Text(
                    'personalize_title'.tr,
                    textAlign: TextAlign.center,
                    style: theme.typography.body.lg.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                SizedBox(
                  width: 44,
                  child: Center(
                    child: Text(
                      '${step + 1}/4',
                      style: theme.typography.body.xs.copyWith(
                        color: theme.colors.mutedForeground,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: List.generate(
              4,
              (index) => Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 240),
                  height: 4,
                  margin: EdgeInsets.only(right: index == 3 ? 0 : 7),
                  decoration: BoxDecoration(
                    color: index <= step
                        ? theme.colors.primary
                        : theme.colors.secondary,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InterestsStep extends GetView<PreferencesController> {
  const _InterestsStep();

  @override
  Widget build(BuildContext context) {
    return _StepLayout(
      icon: FLucideIcons.sparkles,
      title: 'interests_title'.tr,
      subtitle: 'interests_subtitle'.tr,
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          for (final interest in PreferencesController.interests)
            Obx(
              () => _ChoiceButton(
                label: _preferenceLabel(interest),
                selected: controller.selectedInterests.contains(interest),
                onPress: () => controller.toggleInterest(interest),
              ),
            ),
        ],
      ),
    );
  }
}

class _RoleStep extends GetView<PreferencesController> {
  const _RoleStep();

  @override
  Widget build(BuildContext context) {
    final theme = FTheme.of(context);
    return _StepLayout(
      icon: FLucideIcons.searchCheck,
      title: 'desired_role_title'.tr,
      subtitle: 'desired_role_subtitle'.tr,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FTextField(
            control: FTextFieldControl.managed(
              controller: controller.desiredRoleController,
              onChange: (value) => controller.selectRole(value.text),
            ),
            label: Text('role_or_job_title'.tr),
            hint: 'role_hint'.tr,
            textInputAction: TextInputAction.done,
            prefixBuilder: (context, style, variants) =>
                FTextField.prefixIconBuilder(
                  context,
                  style,
                  variants,
                  const Icon(FLucideIcons.briefcaseBusiness),
                ),
          ),
          const SizedBox(height: 22),
          Text(
            'popular_roles'.tr,
            style: theme.typography.body.sm.copyWith(
              color: theme.colors.mutedForeground,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final role in PreferencesController.roles)
                Obx(
                  () => _ChoiceButton(
                    label: _preferenceLabel(role),
                    selected: controller.desiredRole.value == role,
                    onPress: () => controller.selectRole(
                      role,
                      displayLabel: _preferenceLabel(role),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LevelStep extends GetView<PreferencesController> {
  const _LevelStep();

  static const _details = {
    'Mid-level': 'level_mid_detail',
    'Intermediate': 'level_intermediate_detail',
    'Senior': 'level_senior_detail',
    'Expert': 'level_expert_detail',
    'Internship': 'level_internship_detail',
  };

  @override
  Widget build(BuildContext context) {
    return _StepLayout(
      icon: FLucideIcons.chartNoAxesColumnIncreasing,
      title: 'experience_title'.tr,
      subtitle: 'experience_subtitle'.tr,
      child: Obx(
        () => FTileGroup(
          children: [
            for (final level in PreferencesController.levels)
              FTile(
                prefix: const Icon(FLucideIcons.badgeCheck),
                title: Text(_preferenceLabel(level)),
                subtitle: Text(_details[level]!.tr),
                suffix: Icon(
                  controller.experienceLevel.value == level
                      ? FLucideIcons.circleCheckBig
                      : FLucideIcons.circle,
                ),
                onPress: () => controller.selectLevel(level),
              ),
          ],
        ),
      ),
    );
  }
}

class _LocationStep extends GetView<PreferencesController> {
  const _LocationStep();

  static const _details = {
    'Remote': 'location_remote_detail',
    'Singapore': 'location_singapore_detail',
    'Washington, DC': 'location_washington_dc_detail',
    'Any': 'location_any_detail',
  };

  @override
  Widget build(BuildContext context) {
    return _StepLayout(
      icon: FLucideIcons.mapPinned,
      title: 'location_title'.tr,
      subtitle: 'location_subtitle'.tr,
      child: Obx(
        () => FTileGroup(
          children: [
            for (final location in PreferencesController.locations)
              FTile(
                prefix: Icon(
                  location == 'Remote'
                      ? FLucideIcons.houseWifi
                      : location == 'Any'
                      ? FLucideIcons.globe2
                      : FLucideIcons.mapPin,
                ),
                title: Text(_preferenceLabel(location)),
                subtitle: Text(_details[location]!.tr),
                suffix: Icon(
                  controller.preferredLocation.value == location
                      ? FLucideIcons.circleCheckBig
                      : FLucideIcons.circle,
                ),
                onPress: () => controller.selectLocation(location),
              ),
          ],
        ),
      ),
    );
  }
}

class _StepLayout extends StatelessWidget {
  const _StepLayout({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = FTheme.of(context);
    return SingleChildScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.fromLTRB(20, 30, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: theme.colors.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 24, color: theme.colors.primary),
          ),
          const SizedBox(height: 20),
          Text(
            title.replaceAll('\n', ' '),
            style: theme.typography.display.lg.copyWith(
              fontWeight: FontWeight.w800,
              height: 1.12,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: theme.typography.body.sm.copyWith(
              color: theme.colors.mutedForeground,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 26),
          child,
        ],
      ),
    );
  }
}

class _ChoiceButton extends StatelessWidget {
  const _ChoiceButton({
    required this.label,
    required this.selected,
    required this.onPress,
  });

  final String label;
  final bool selected;
  final VoidCallback onPress;

  @override
  Widget build(BuildContext context) {
    return FButton(
      variant: selected ? FButtonVariant.primary : FButtonVariant.outline,
      onPress: () {
        unawaited(HapticFeedback.selectionClick());
        onPress();
      },
      prefix: selected ? const Icon(FLucideIcons.check, size: 16) : null,
      child: Text(label),
    );
  }
}

class _WizardFooter extends GetView<PreferencesController> {
  const _WizardFooter({required this.step});

  final int step;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.scaffold,
        border: Border(top: BorderSide(color: palette.divider)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
        child: Obx(() {
          final enabled = switch (step) {
            0 => controller.selectedInterests.isNotEmpty,
            1 => controller.desiredRole.value.isNotEmpty,
            2 => controller.experienceLevel.value.isNotEmpty,
            _ => controller.preferredLocation.value.isNotEmpty,
          };

          return Row(
            children: [
              if (step > 0) ...[
                Expanded(
                  child: FButton(
                    variant: FButtonVariant.outline,
                    onPress: controller.goBack,
                    child: Text('back'.tr),
                  ),
                ),
                const SizedBox(width: 10),
              ],
              Expanded(
                flex: step > 0 ? 1 : 2,
                child: FButton(
                  onPress: enabled
                      ? step == 3
                            ? controller.complete
                            : controller.goNext
                      : null,
                  suffix: Icon(
                    step == 3 ? FLucideIcons.check : FLucideIcons.arrowRight,
                  ),
                  child: Text(step == 3 ? 'done'.tr : 'next'.tr),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

String _preferenceLabel(String value) => switch (value) {
  'Technology' => 'interest_technology'.tr,
  'Design' => 'interest_design'.tr,
  'Business' => 'interest_business'.tr,
  'Marketing' => 'interest_marketing'.tr,
  'Finance' => 'interest_finance'.tr,
  'Education' => 'interest_education'.tr,
  'Healthcare' => 'interest_healthcare'.tr,
  'Remote work' => 'interest_remote_work'.tr,
  'Designer' => 'role_designer'.tr,
  'Developer' => 'role_developer'.tr,
  'Product Manager' => 'role_product_manager'.tr,
  'Other' => 'other'.tr,
  'Mid-level' => 'level_mid'.tr,
  'Intermediate' => 'level_intermediate'.tr,
  'Senior' => 'level_senior'.tr,
  'Expert' => 'level_expert'.tr,
  'Internship' => 'level_internship'.tr,
  'Remote' => 'location_remote'.tr,
  'Singapore' => 'location_singapore'.tr,
  'Washington, DC' => 'location_washington_dc'.tr,
  'Any' => 'location_any'.tr,
  _ => value,
};
