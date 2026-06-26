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
  /// Teal brand accent (match badges, CV-match highlights, CTAs).
  static const brandTeal = Color(0xFF0EA5A4);

  /// Success / positive state (green).
  static const success = Color(0xFF22C55E);

  /// Warning / attention state (amber).
  static const warning = Color(0xFFFFC857);

  /// Informational state (blue).
  static const info = Color(0xFF3B82F6);

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
class AppPalette {
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
}

/// Reads the active [AppPalette] from the nearest theme. Use `context.palette`
/// in any widget that should respond to light/dark switching.
extension PaletteX on BuildContext {
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  AppPalette get palette => isDark ? AppPalette.dark : AppPalette.light;
}
