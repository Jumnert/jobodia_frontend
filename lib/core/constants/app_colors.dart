import 'package:flutter/material.dart';

/// App color palette. Change these values to match final Figma colors.
abstract final class AppColors {
  /// Near-black text/heading color (not the brand teal — see [brandTeal]).
  static const primary = Color(0xFF202428);
  static const headerStart = Color(0xFF090A0B);
  static const headerEnd = Color(0xFF292B2D);
  static const accentPurple = Color(0xFF8B5CF6);
  static const accentPurpleDark = Color(0xFF7C3AED);
  static const background = Color(0xFFF7F8F9);
  static const surface = Colors.white;
  static const textPrimary = Color(0xFF202428);
  static const textSecondary = Color(0xFF68717A);
  static const hint = Color(0xFFB9BEC3);
  static const error = Color(0xFFD93B3B);

  // ── Semantic tokens ──────────────────────────────────────────────
  /// Aqua brand accent used across the default Jobodia theme.
  static const brandTeal = Color(0xFF27B8BB);

  /// Success / positive state (green).
  static const success = Color(0xFF22C55E);

  /// Warning / attention state (amber).
  static const warning = Color(0xFFFFC857);

  /// Informational state (blue).
  static const info = Color(0xFF3B82F6);

  /// Opaque high-contrast blue used for outgoing chat bubbles.
  static const chatOutgoingStart = Color(0xFF237BE8);
  static const chatOutgoingEnd = Color(0xFF075BC7);

  /// Aqua highlight and lower edge used by the onboarding call-to-action.
  static const onboardingCtaLight = Color(0xFF62DAD7);
  static const onboardingCtaDark = Color(0xFF138A92);

  /// Gradient pairings for job feed cards. Cards cycle through these by index
  /// so each card gets a distinct, high-contrast background for white text.
  static const cardGradients = <List<Color>>[
    [Color(0xFF2B5DF0), Color(0xFF7C3AED)], // Deep Blue → Purple
    [Color(0xFF0EA5A4), Color(0xFF10B981)], // Teal → Emerald
    [Color(0xFFFF7E45), Color(0xFFFF5A6E)], // Sunset Orange → Coral
    [Color(0xFF6D5BF8), Color(0xFFB14CF0)], // Indigo → Violet
  ];
}

/// Semantic, theme-aware color roles. Pick values by brightness so screens and
/// widgets can read one palette instead of hardcoding light-only colors.
///
/// Brand colors (accents, gradients, the teal CTA, branded header) intentionally
/// live in [AppColors] and stay fixed across themes — only neutral surfaces,
/// text, borders, and icons shift here.
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
    scaffold: Color(0xFFF5F6F8),
    surface: Colors.white,
    surfaceMuted: Color(0xFFF3F5F7),
    textPrimary: Color(0xFF101214),
    textSecondary: Color(0xFF6F7378),
    textTertiary: Color(0xFF9A9FA4),
    border: Color(0xFFE9E9E9),
    divider: Color(0xFFE7E9EC),
    iconPrimary: Color(0xFF101214),
    iconMuted: Color(0xFF8C8C8C),
    success: Color(0xFF22C55E),
    warning: Color(0xFFFFC857),
    info: Color(0xFF3B82F6),
    error: Color(0xFFD93B3B),
  );

  static const dark = AppPalette(
    scaffold: Color(0xFF101214),
    surface: Color(0xFF1A1D20),
    surfaceMuted: Color(0xFF22262B),
    textPrimary: Colors.white,
    textSecondary: Color(0xFFB7BDC3),
    textTertiary: Color(0xFF7E868D),
    border: Color(0xFF2A2E33),
    divider: Color(0xFF2A2E33),
    iconPrimary: Colors.white,
    iconMuted: Color(0xFFA5ABB1),
    success: Color(0xFF22C55E),
    warning: Color(0xFFFFC857),
    info: Color(0xFF3B82F6),
    error: Color(0xFFEF4444),
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
