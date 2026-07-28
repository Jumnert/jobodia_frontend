import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:get/get.dart';
import 'package:jobodia_frontend/app/theme/app_theme.dart';
import 'package:jobodia_frontend/core/constants/app_colors.dart';
import 'package:jobodia_frontend/core/constants/app_spacing.dart';
import 'package:jobodia_frontend/features/settings/controller/theme_controller.dart';

class ThemePicker extends StatelessWidget {
  const ThemePicker({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ThemeController>();

    return Obx(() {
      final selectedPreset = controller.preset.value;
      return SizedBox(
        height: 174,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
          itemCount: AppThemePreset.values.length,
          separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.md),
          itemBuilder: (context, index) {
            final preset = AppThemePreset.values[index];
            return _ThemeCard(
              preset: preset,
              isSelected: preset == selectedPreset,
              onTap: () => controller.selectPreset(preset),
            );
          },
        ),
      );
    });
  }
}

class _ThemeCard extends StatelessWidget {
  const _ThemeCard({
    required this.preset,
    required this.isSelected,
    required this.onTap,
  });

  final AppThemePreset preset;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Semantics(
      button: true,
      selected: isSelected,
      label: '${preset.label} theme. ${preset.description}',
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          width: 226,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: isSelected ? preset.accent : palette.border,
              width: isSelected ? 2.5 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: isSelected
                    ? preset.accent.withValues(alpha: 0.24)
                    : Colors.black.withValues(alpha: 0.07),
                blurRadius: isSelected ? 18 : 10,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(isSelected ? 18.5 : 21),
            child: Stack(
              fit: StackFit.expand,
              children: [
                _ThemeArtwork(preset: preset),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Color(0xE6141B24)],
                      stops: [0.25, 1],
                    ),
                  ),
                ),
                Positioned(
                  top: AppSpacing.md,
                  right: AppSpacing.md,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? preset.accent
                          : Colors.black.withValues(alpha: 0.28),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                    child: Icon(
                      isSelected ? FLucideIcons.check : FLucideIcons.circle,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
                Positioned(
                  left: AppSpacing.lg,
                  right: AppSpacing.lg,
                  bottom: AppSpacing.lg,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        preset.label,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        preset.description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white.withValues(alpha: 0.86),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        children: _swatches
                            .map(
                              (color) => Container(
                                width: 18,
                                height: 5,
                                margin: const EdgeInsets.only(right: 5),
                                decoration: BoxDecoration(
                                  color: color,
                                  borderRadius: BorderRadius.circular(99),
                                ),
                              ),
                            )
                            .toList(),
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
  }

  List<Color> get _swatches => switch (preset) {
    AppThemePreset.defaultTheme => const [
      AppColors.brandPrimary,
      AppColors.chart2,
      Color(0xFFFFFFFF),
    ],
    AppThemePreset.golden => const [
      Color(0xFFC38A16),
      Color(0xFFF2D383),
      Color(0xFFFFF8E8),
    ],
    AppThemePreset.midnight => const [
      Color(0xFF4D7CFE),
      Color(0xFF172554),
      Color(0xFF080D1B),
    ],
    AppThemePreset.rose => const [
      Color(0xFFD65A82),
      Color(0xFFF2B4C7),
      Color(0xFFFFF5F8),
    ],
    AppThemePreset.forest => const [
      Color(0xFF2E8B67),
      Color(0xFF9DD6B9),
      Color(0xFF0B1712),
    ],
    AppThemePreset.lavender => const [
      Color(0xFF8B6FD6),
      Color(0xFFC8B5F0),
      Color(0xFFF8F5FF),
    ],
  };
}

class _ThemeArtwork extends StatelessWidget {
  const _ThemeArtwork({required this.preset});

  final AppThemePreset preset;

  @override
  Widget build(BuildContext context) {
    final colors = switch (preset) {
      AppThemePreset.defaultTheme => const [
        AppColors.chart5,
        AppColors.brandPrimary,
        AppColors.chart1,
      ],
      AppThemePreset.golden => const [
        Color(0xFF6D4610),
        Color(0xFFC38A16),
        Color(0xFFF4D68B),
      ],
      AppThemePreset.midnight => const [
        Color(0xFF080D1B),
        Color(0xFF172554),
        Color(0xFF4D7CFE),
      ],
      AppThemePreset.rose => const [
        Color(0xFF6E263E),
        Color(0xFFD65A82),
        Color(0xFFF2B4C7),
      ],
      AppThemePreset.forest => const [
        Color(0xFF0B281C),
        Color(0xFF2E8B67),
        Color(0xFF9DD6B9),
      ],
      AppThemePreset.lavender => const [
        Color(0xFF38235F),
        Color(0xFF8B6FD6),
        Color(0xFFC8B5F0),
      ],
    };

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
      ),
      child: Align(
        alignment: Alignment.topLeft,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Icon(
            preset == AppThemePreset.golden
                ? FLucideIcons.sparkles
                : FLucideIcons.palette,
            color: Colors.white.withValues(alpha: 0.7),
            size: 34,
          ),
        ),
      ),
    );
  }
}
