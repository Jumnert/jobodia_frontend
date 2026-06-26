/// Standardized spacing scale used throughout the app.
///
/// Use these constants instead of raw numeric literals for consistent spacing:
/// ```dart
/// SizedBox(height: AppSpacing.md)
/// Padding(padding: EdgeInsets.all(AppSpacing.lg))
/// ```
abstract final class AppSpacing {
  /// 4 px — tight gap (icon-to-label, inline chip padding).
  static const double xs = 4;

  /// 8 px — small gap (between related elements).
  static const double sm = 8;

  /// 12 px — medium-small gap.
  static const double md = 12;

  /// 16 px — standard gap (card padding, section spacing).
  static const double lg = 16;

  /// 20 px — large gap.
  static const double xl = 20;

  /// 24 px — extra-large gap (section headers).
  static const double xxl = 24;

  /// 32 px — section divider spacing.
  static const double xxxl = 32;
}
