import 'package:flutter/material.dart';

/// Shared colors derived from the shadcn OKLCH theme documented in README.
abstract final class AppColors {
  static const primary = Color(0xFF0A0A0A);
  static const primaryForeground = Color(0xFFFFFFFF);
  static const headerStart = Color(0xFF0A0A0A);
  static const headerEnd = Color(0xFF171717);

  // Legacy names retained for existing feature code; both now map into the
  // Jobodia blue scale.
  static const accentPurple = Color(0xFF378FE9);
  static const accentPurpleDark = Color(0xFF0A66C2);

  static const background = Color(0xFFFFFFFF);
  static const surface = Color(0xFFFFFFFF);
  static const textPrimary = Color(0xFF0A0A0A);
  static const textSecondary = Color(0xFF737373);
  static const hint = Color(0xFFA1A1A1);
  static const error = Color(0xFFDF2225);

  // ── Brand and semantic tokens ───────────────────────────────────
  /// Primary Jobodia brand color, inspired by LinkedIn blue.
  static const brandPrimary = Color(0xFF0A66C2);

  /// Lighter and darker brand steps for gradients and elevated states.
  static const brandLight = Color(0xFF70B5F9);
  static const brandDark = Color(0xFF004182);

  /// Backward-compatible alias used throughout existing feature widgets.
  static const brandTeal = brandPrimary;

  static const chart1 = Color(0xFFA8D4F5);
  static const chart2 = brandLight;
  static const chart3 = Color(0xFF378FE9);
  static const chart4 = brandPrimary;
  static const chart5 = brandDark;

  /// Success / positive state.
  static const success = Color(0xFF15803D);

  /// Warning / attention state.
  static const warning = Color(0xFFF59E0B);

  /// Informational state kept blue for conventional semantic recognition.
  static const info = chart3;

  /// High-contrast outgoing chat gradient drawn from the chart scale.
  static const chatOutgoingStart = chart4;
  static const chatOutgoingEnd = chart5;

  /// Deep action color used by the compact chat composer send control.
  static const chatComposerAction = brandDark;

  /// Onboarding CTA tokens mapped to the Jobodia blue scale.
  static const onboardingCtaLight = brandPrimary;
  static const onboardingCtaDark = brandDark;

  /// Gradient pairings derived from the supplied chart scale.
  static const cardGradients = <List<Color>>[
    [chart2, chart3],
    [chart3, chart4],
    [chart4, chart5],
    [chart5, Color(0xFF171717)],
  ];
}

/// Semantic, theme-aware color roles. Pick values by brightness so screens and
/// widgets can read one palette instead of hardcoding light-only colors.
///
/// Brand and chart colors live in [AppColors]. Neutral surfaces, text,
/// borders, icons, and destructive colors shift with the active brightness.
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.scaffold,
    required this.surface,
    required this.surfaceMuted,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.border,
    required this.divider,
    required this.iconPrimary,
    required this.iconMuted,
    required this.success,
    required this.warning,
    required this.info,
    required this.error,
  });

  /// Plain page background.
  final Color scaffold;

  /// Card / sheet / elevated container background.
  final Color surface;

  /// Subtle filled background (chips, icon wells, inset fields).
  /// In dark mode this also serves as the dark surface variant (surfaceDark).
  final Color surfaceMuted;

  /// Headings and high-emphasis body text.
  final Color textPrimary;

  /// Supporting copy.
  final Color textSecondary;

  /// Lowest-emphasis text (timestamps, captions).
  final Color textTertiary;

  /// Container outlines.
  final Color border;

  /// Hairline separators.
  final Color divider;

  /// High-emphasis icons matching primary text.
  final Color iconPrimary;

  /// Muted / inactive icons.
  final Color iconMuted;

  /// Success / positive state (green).
  final Color success;

  /// Warning / attention state (amber).
  final Color warning;

  /// Informational state (blue).
  final Color info;

  /// Error / destructive state (red).
  final Color error;

  static const light = AppPalette(
    scaffold: Color(0xFFFFFFFF),
    surface: Color(0xFFFFFFFF),
    surfaceMuted: Color(0xFFF5F5F5),
    textPrimary: Color(0xFF0A0A0A),
    textSecondary: Color(0xFF737373),
    textTertiary: Color(0xFFA1A1A1),
    border: Color(0xFFE5E5E5),
    divider: Color(0xFFE5E5E5),
    iconPrimary: Color(0xFF0A0A0A),
    iconMuted: Color(0xFF737373),
    success: Color(0xFF15803D),
    warning: Color(0xFFF59E0B),
    info: Color(0xFF378FE9),
    error: Color(0xFFDF2225),
  );

  static const dark = AppPalette(
    scaffold: Color(0xFF0A0A0A),
    surface: Color(0xFF171717),
    surfaceMuted: Color(0xFF262626),
    textPrimary: Color(0xFFFAFAFA),
    textSecondary: Color(0xFFA1A1A1),
    textTertiary: Color(0xFF737373),
    border: Color(0x1AFFFFFF),
    divider: Color(0x1AFFFFFF),
    iconPrimary: Color(0xFFFAFAFA),
    iconMuted: Color(0xFFA1A1A1),
    success: Color(0xFF4ADE80),
    warning: Color(0xFFFBBF24),
    info: Color(0xFF70B5F9),
    error: Color(0xFFFF6467),
  );

  static const goldenLight = AppPalette(
    scaffold: Color(0xFFFFF8E8),
    surface: Color(0xFFFFFDF7),
    surfaceMuted: Color(0xFFF8EBC9),
    textPrimary: Color(0xFF30230D),
    textSecondary: Color(0xFF74613B),
    textTertiary: Color(0xFFA18B60),
    border: Color(0xFFEAD6A2),
    divider: Color(0xFFEEDDB5),
    iconPrimary: Color(0xFF30230D),
    iconMuted: Color(0xFF91794A),
    success: Color(0xFF3D8D52),
    warning: Color(0xFFD89913),
    info: Color(0xFF3F73B9),
    error: Color(0xFFC74632),
  );

  static const goldenDark = AppPalette(
    scaffold: Color(0xFF18130B),
    surface: Color(0xFF231C10),
    surfaceMuted: Color(0xFF302614),
    textPrimary: Color(0xFFFFF5D9),
    textSecondary: Color(0xFFD3BF91),
    textTertiary: Color(0xFF97825B),
    border: Color(0xFF44361D),
    divider: Color(0xFF3B301C),
    iconPrimary: Color(0xFFFFF5D9),
    iconMuted: Color(0xFFBDA574),
    success: Color(0xFF58B56E),
    warning: Color(0xFFE4AD35),
    info: Color(0xFF70A0E2),
    error: Color(0xFFEE725D),
  );

  static const autumnLight = AppPalette(
    scaffold: Color(0xFFFFF5EC),
    surface: Color(0xFFFFFCF8),
    surfaceMuted: Color(0xFFF7E2D1),
    textPrimary: Color(0xFF352016),
    textSecondary: Color(0xFF775747),
    textTertiary: Color(0xFFA17F6C),
    border: Color(0xFFEACCB9),
    divider: Color(0xFFEFD9CA),
    iconPrimary: Color(0xFF352016),
    iconMuted: Color(0xFF936D58),
    success: Color(0xFF4C8951),
    warning: Color(0xFFD5872D),
    info: Color(0xFF4D78A5),
    error: Color(0xFFBD4935),
  );

  static const autumnDark = AppPalette(
    scaffold: Color(0xFF1B100C),
    surface: Color(0xFF281812),
    surfaceMuted: Color(0xFF382219),
    textPrimary: Color(0xFFFFEEE2),
    textSecondary: Color(0xFFD9B5A0),
    textTertiary: Color(0xFF9F7965),
    border: Color(0xFF4B2E22),
    divider: Color(0xFF42271D),
    iconPrimary: Color(0xFFFFEEE2),
    iconMuted: Color(0xFFC49A83),
    success: Color(0xFF69A66A),
    warning: Color(0xFFE09B48),
    info: Color(0xFF78A0C8),
    error: Color(0xFFE26B55),
  );

  static const winterLight = AppPalette(
    scaffold: Color(0xFFF1F7FC),
    surface: Color(0xFFFBFDFF),
    surfaceMuted: Color(0xFFE3EFF8),
    textPrimary: Color(0xFF14263A),
    textSecondary: Color(0xFF526B82),
    textTertiary: Color(0xFF8299AD),
    border: Color(0xFFCFE0ED),
    divider: Color(0xFFD9E7F1),
    iconPrimary: Color(0xFF173B5E),
    iconMuted: Color(0xFF6E8BA3),
    success: Color(0xFF2E8B73),
    warning: Color(0xFFC88A2D),
    info: Color(0xFF3E78C7),
    error: Color(0xFFC84D5D),
  );

  static const winterDark = AppPalette(
    scaffold: Color(0xFF081522),
    surface: Color(0xFF102235),
    surfaceMuted: Color(0xFF183149),
    textPrimary: Color(0xFFF2F8FD),
    textSecondary: Color(0xFFB7CBDB),
    textTertiary: Color(0xFF7995AA),
    border: Color(0xFF27445C),
    divider: Color(0xFF213A50),
    iconPrimary: Color(0xFFE8F5FF),
    iconMuted: Color(0xFF8EAAC0),
    success: Color(0xFF5AB69B),
    warning: Color(0xFFE0AA55),
    info: Color(0xFF72A7E8),
    error: Color(0xFFEF7884),
  );

  @override
  AppPalette copyWith({
    Color? scaffold,
    Color? surface,
    Color? surfaceMuted,
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? border,
    Color? divider,
    Color? iconPrimary,
    Color? iconMuted,
    Color? success,
    Color? warning,
    Color? info,
    Color? error,
  }) {
    return AppPalette(
      scaffold: scaffold ?? this.scaffold,
      surface: surface ?? this.surface,
      surfaceMuted: surfaceMuted ?? this.surfaceMuted,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
      border: border ?? this.border,
      divider: divider ?? this.divider,
      iconPrimary: iconPrimary ?? this.iconPrimary,
      iconMuted: iconMuted ?? this.iconMuted,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      info: info ?? this.info,
      error: error ?? this.error,
    );
  }

  @override
  AppPalette lerp(covariant AppPalette? other, double t) {
    if (other == null) return this;
    return AppPalette(
      scaffold: Color.lerp(scaffold, other.scaffold, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceMuted: Color.lerp(surfaceMuted, other.surfaceMuted, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textTertiary: Color.lerp(textTertiary, other.textTertiary, t)!,
      border: Color.lerp(border, other.border, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      iconPrimary: Color.lerp(iconPrimary, other.iconPrimary, t)!,
      iconMuted: Color.lerp(iconMuted, other.iconMuted, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      info: Color.lerp(info, other.info, t)!,
      error: Color.lerp(error, other.error, t)!,
    );
  }
}

/// Reads the active [AppPalette] from the nearest theme. Use `context.palette`
/// in any widget that should respond to light/dark switching.
extension PaletteX on BuildContext {
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  AppPalette get palette =>
      Theme.of(this).extension<AppPalette>() ??
      (isDark ? AppPalette.dark : AppPalette.light);
}
