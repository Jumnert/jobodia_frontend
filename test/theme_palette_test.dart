import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jobodia_frontend/app/theme/app_theme.dart';
import 'package:jobodia_frontend/core/constants/app_colors.dart';
import 'package:jobodia_frontend/theme/theme.dart' as forui_theme;

void main() {
  test('shared tokens use the Jobodia blue palette', () {
    expect(AppColors.brandPrimary, const Color(0xFF0A66C2));
    expect(AppColors.brandTeal, AppColors.brandPrimary);
    expect(AppColors.primaryForeground, const Color(0xFFFFFFFF));
    expect(AppColors.chart1, const Color(0xFFA8D4F5));
    expect(AppColors.chart5, const Color(0xFF004182));

    expect(AppPalette.light.scaffold, const Color(0xFFFFFFFF));
    expect(AppPalette.light.textPrimary, const Color(0xFF0A0A0A));
    expect(AppPalette.light.border, const Color(0xFFE5E5E5));
    expect(AppPalette.dark.scaffold, const Color(0xFF0A0A0A));
    expect(AppPalette.dark.surface, const Color(0xFF171717));
    expect(AppPalette.dark.border, const Color(0x1AFFFFFF));
  });

  test('forui themes expose the supplied light and dark tokens', () {
    final light = forui_theme.lightTheme.colors;
    final dark = forui_theme.darkTheme.colors;

    expect(light.background, const Color(0xFFFFFFFF));
    expect(light.foreground, const Color(0xFF0A0A0A));
    expect(light.primary, const Color(0xFF0A66C2));
    expect(light.secondary, const Color(0xFFF4F4F5));
    expect(light.destructive, const Color(0xFFDF2225));

    expect(dark.background, const Color(0xFF0A0A0A));
    expect(dark.foreground, const Color(0xFFFAFAFA));
    expect(dark.card, const Color(0xFF171717));
    expect(dark.secondary, const Color(0xFF27272A));
    expect(dark.destructive, const Color(0xFFFF6467));
    expect(dark.border, const Color(0x1AFFFFFF));
  });

  test('default Material themes use the same color system', () {
    final light = AppTheme.light.colorScheme;
    final dark = AppTheme.dark.colorScheme;

    expect(light.primary, const Color(0xFF0A66C2));
    expect(light.onPrimary, const Color(0xFFFFFFFF));
    expect(light.surface, const Color(0xFFFFFFFF));
    expect(light.onSurface, const Color(0xFF0A0A0A));
    expect(light.secondary, const Color(0xFFF4F4F5));
    expect(light.error, const Color(0xFFDF2225));

    expect(dark.primary, const Color(0xFF0A66C2));
    expect(dark.onPrimary, const Color(0xFFFFFFFF));
    expect(dark.surface, const Color(0xFF171717));
    expect(dark.onSurface, const Color(0xFFFAFAFA));
    expect(dark.secondary, const Color(0xFF27272A));
    expect(dark.error, const Color(0xFFFF6467));
  });
}
