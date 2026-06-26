import 'package:flutter/material.dart';
import 'package:jobodia_frontend/core/constants/app_colors.dart';

/// Convenience extensions on [BuildContext].
extension ContextX on BuildContext {
  /// Whether the current theme is dark mode.
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  /// The active [AppPalette] (light or dark).
  AppPalette get palette => isDark ? AppPalette.dark : AppPalette.light;

  /// Screen width.
  double get screenWidth => MediaQuery.of(this).size.width;

  /// Screen height.
  double get screenHeight => MediaQuery.of(this).size.height;
}
