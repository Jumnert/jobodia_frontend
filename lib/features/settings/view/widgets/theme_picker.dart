import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:get/get.dart';
import 'package:jobodia_frontend/app/theme/app_theme.dart';
import 'package:jobodia_frontend/core/constants/app_colors.dart';
import 'package:jobodia_frontend/features/settings/controller/theme_controller.dart';

class ThemePicker extends StatelessWidget {
  const ThemePicker({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ThemeController>();

    return Obx(
      () => Row(
        children: [
          for (
            var index = 0;
            index < ThemeController.supportedPresets.length;
            index++
          ) ...[
            if (index > 0) const SizedBox(width: 12),
            Expanded(
              child: _ThemeOption(
                preset: ThemeController.supportedPresets[index],
                selected:
                    controller.preset.value ==
                    ThemeController.supportedPresets[index],
                onPress: () => controller.selectPreset(
                  ThemeController.supportedPresets[index],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  const _ThemeOption({
    required this.preset,
    required this.selected,
    required this.onPress,
  });

  final AppThemePreset preset;
  final bool selected;
  final VoidCallback onPress;

  @override
  Widget build(BuildContext context) {
    final theme = FTheme.of(context);
    final palette = context.palette;

    return Semantics(
      button: true,
      selected: selected,
      label: '${preset.label} theme',
      child: GestureDetector(
        onTap: onPress,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: selected
                ? preset.accent.withValues(alpha: 0.07)
                : palette.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected ? preset.accent : palette.border,
              width: selected ? 2 : 1,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: preset.accent.withValues(alpha: 0.12),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : const [],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ThemePreview(preset: preset),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          preset.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.typography.body.sm.copyWith(
                            color: palette.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 1),
                        Text(
                          preset.description,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.typography.body.xs.copyWith(
                            color: palette.textTertiary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: selected ? preset.accent : Colors.transparent,
                      border: Border.all(
                        color: selected ? preset.accent : palette.border,
                      ),
                    ),
                    child: selected
                        ? const Icon(
                            FLucideIcons.check,
                            color: Colors.white,
                            size: 14,
                          )
                        : null,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ThemePreview extends StatelessWidget {
  const _ThemePreview({required this.preset});

  final AppThemePreset preset;

  @override
  Widget build(BuildContext context) {
    final midnight = preset == AppThemePreset.midnight;
    final background = midnight
        ? const Color(0xFF080D1B)
        : const Color(0xFFF5FAF8);
    final surface = midnight ? const Color(0xFF172554) : Colors.white;
    final muted = midnight
        ? Colors.white.withValues(alpha: 0.42)
        : const Color(0xFFCBD8D3);

    return Container(
      height: 84,
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(13),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 22,
                height: 5,
                decoration: BoxDecoration(
                  color: preset.accent,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              const Spacer(),
              _PreviewDot(color: muted),
              const SizedBox(width: 4),
              _PreviewDot(color: muted),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Container(
                    decoration: BoxDecoration(
                      color: surface,
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: Align(
                      alignment: Alignment.bottomLeft,
                      child: Container(
                        width: 28,
                        height: 4,
                        margin: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: preset.accent,
                          borderRadius: BorderRadius.circular(99),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: preset.accent.withValues(alpha: 0.28),
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: surface,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PreviewDot extends StatelessWidget {
  const _PreviewDot({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    width: 5,
    height: 5,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
  );
}
