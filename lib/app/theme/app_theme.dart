import 'package:flutter/material.dart';
import 'package:jobodia_frontend/core/constants/app_colors.dart';

enum AppThemePreset { defaultTheme, golden, midnight, rose, forest, lavender }

extension AppThemePresetX on AppThemePreset {
  String get storageValue => name;

  String get label => switch (this) {
    AppThemePreset.defaultTheme => 'Default',
    AppThemePreset.golden => 'Golden',
    AppThemePreset.midnight => 'Midnight',
    AppThemePreset.rose => 'Rose',
    AppThemePreset.forest => 'Forest',
    AppThemePreset.lavender => 'Lavender',
  };

  String get description => switch (this) {
    AppThemePreset.defaultTheme => 'Clean and calm',
    AppThemePreset.golden => 'Warm and polished',
    AppThemePreset.midnight => 'Deep blue and focused',
    AppThemePreset.rose => 'Soft, warm and expressive',
    AppThemePreset.forest => 'Natural and grounded',
    AppThemePreset.lavender => 'Calm with a creative edge',
  };

  Color get accent => switch (this) {
    AppThemePreset.defaultTheme => AppColors.brandTeal,
    AppThemePreset.golden => const Color(0xFFC38A16),
    AppThemePreset.midnight => const Color(0xFF4D7CFE),
    AppThemePreset.rose => const Color(0xFFD65A82),
    AppThemePreset.forest => const Color(0xFF2E8B67),
    AppThemePreset.lavender => const Color(0xFF8B6FD6),
  };
}

/// Central app theme.
abstract final class AppTheme {
  static ThemeData get light => forPreset(AppThemePreset.defaultTheme);

  static ThemeData get dark =>
      forPreset(AppThemePreset.defaultTheme, brightness: Brightness.dark);

  static ThemeData forPreset(
    AppThemePreset preset, {
    Brightness brightness = Brightness.light,
  }) {
    final palette = _paletteFor(preset, brightness);
    final colorScheme = preset == AppThemePreset.defaultTheme
        ? _defaultColorScheme(brightness)
        : ColorScheme.fromSeed(
            seedColor: preset.accent,
            brightness: brightness,
          ).copyWith(
            primary: preset.accent,
            surface: palette.surface,
            onSurface: palette.textPrimary,
            outline: palette.border,
            error: palette.error,
          );
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: palette.scaffold,
      canvasColor: palette.surface,
      dividerColor: palette.divider,
      primaryColor: preset.accent,
      colorScheme: colorScheme,
      fontFamily: 'Arial',
      iconTheme: IconThemeData(color: palette.iconPrimary),
      appBarTheme: AppBarTheme(
        backgroundColor: palette.scaffold,
        foregroundColor: palette.textPrimary,
        surfaceTintColor: Colors.transparent,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: palette.surfaceMuted,
        hintStyle: TextStyle(color: palette.textTertiary),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: palette.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: preset == AppThemePreset.defaultTheme
                ? (brightness == Brightness.dark
                      ? const Color(0xFF737373)
                      : const Color(0xFFA1A1A1))
                : preset.accent,
            width: 1.5,
          ),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: palette.surface,
        indicatorColor: preset.accent.withValues(alpha: 0.18),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected)
                ? preset.accent
                : palette.iconMuted,
          ),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: palette.surface,
        selectedItemColor: preset.accent,
        unselectedItemColor: palette.iconMuted,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: preset.accent,
          foregroundColor: colorScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: preset.accent,
        foregroundColor: colorScheme.onPrimary,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: palette.surfaceMuted,
        selectedColor: preset.accent.withValues(alpha: 0.2),
        side: BorderSide(color: palette.border),
        labelStyle: TextStyle(color: palette.textPrimary),
      ),
      extensions: <ThemeExtension<dynamic>>[palette],
    );
  }

  static ColorScheme _defaultColorScheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final background = isDark
        ? const Color(0xFF0A0A0A)
        : const Color(0xFFFFFFFF);
    final foreground = isDark
        ? const Color(0xFFFAFAFA)
        : const Color(0xFF0A0A0A);
    final card = isDark ? const Color(0xFF171717) : const Color(0xFFFFFFFF);
    final secondary = isDark
        ? const Color(0xFF27272A)
        : const Color(0xFFF4F4F5);
    final muted = isDark ? const Color(0xFF262626) : const Color(0xFFF5F5F5);
    final accent = isDark ? const Color(0xFF404040) : const Color(0xFFF5F5F5);
    final border = isDark ? const Color(0x1AFFFFFF) : const Color(0xFFE5E5E5);

    return ColorScheme.fromSeed(
      seedColor: AppColors.brandPrimary,
      brightness: brightness,
    ).copyWith(
      primary: AppColors.brandPrimary,
      onPrimary: AppColors.primaryForeground,
      primaryContainer: AppColors.brandPrimary,
      onPrimaryContainer: const Color(0xFF0A0A0A),
      secondary: secondary,
      onSecondary: isDark ? const Color(0xFFFAFAFA) : const Color(0xFF18181B),
      secondaryContainer: muted,
      onSecondaryContainer: foreground,
      tertiary: AppColors.chart2,
      onTertiary: Colors.white,
      error: isDark ? const Color(0xFFFF6467) : const Color(0xFFDF2225),
      onError: Colors.white,
      surface: card,
      onSurface: foreground,
      surfaceContainerLowest: background,
      surfaceContainerLow: card,
      surfaceContainer: muted,
      surfaceContainerHigh: accent,
      surfaceContainerHighest: secondary,
      outline: border,
      outlineVariant: border,
      inverseSurface: isDark
          ? const Color(0xFFFAFAFA)
          : const Color(0xFF171717),
      onInverseSurface: isDark
          ? const Color(0xFF171717)
          : const Color(0xFFFAFAFA),
      surfaceTint: Colors.transparent,
    );
  }

  static AppPalette _paletteFor(AppThemePreset preset, Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    return switch (preset) {
      AppThemePreset.defaultTheme =>
        isDark ? AppPalette.dark : AppPalette.light,
      AppThemePreset.golden =>
        isDark ? AppPalette.goldenDark : AppPalette.goldenLight,
      AppThemePreset.midnight =>
        isDark
            ? AppPalette.winterDark.copyWith(scaffold: const Color(0xFF080D1B))
            : AppPalette.winterLight.copyWith(
                scaffold: const Color(0xFFF3F6FF),
              ),
      AppThemePreset.rose =>
        isDark
            ? AppPalette.autumnDark.copyWith(
                scaffold: const Color(0xFF1C1016),
                surface: const Color(0xFF291720),
              )
            : AppPalette.autumnLight.copyWith(
                scaffold: const Color(0xFFFFF5F8),
                surfaceMuted: const Color(0xFFF9E4EB),
              ),
      AppThemePreset.forest =>
        isDark
            ? AppPalette.dark.copyWith(
                scaffold: const Color(0xFF0B1712),
                surface: const Color(0xFF12231B),
                surfaceMuted: const Color(0xFF1A3025),
              )
            : AppPalette.light.copyWith(
                scaffold: const Color(0xFFF3FAF6),
                surfaceMuted: const Color(0xFFE3F2E9),
              ),
      AppThemePreset.lavender =>
        isDark
            ? AppPalette.dark.copyWith(
                scaffold: const Color(0xFF151020),
                surface: const Color(0xFF20182E),
                surfaceMuted: const Color(0xFF2C2140),
              )
            : AppPalette.light.copyWith(
                scaffold: const Color(0xFFF8F5FF),
                surfaceMuted: const Color(0xFFEDE6FA),
              ),
    };
  }
}
