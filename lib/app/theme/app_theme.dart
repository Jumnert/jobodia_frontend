import 'package:flutter/material.dart';
import 'package:jobodia_frontend/core/constants/app_colors.dart';

/// Central app theme.
abstract final class AppTheme {
  static ThemeData get light {
    final palette = AppPalette.light;
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: palette.scaffold,
      colorScheme:
          ColorScheme.fromSeed(
            seedColor: AppColors.brandTeal,
            brightness: Brightness.light,
          ).copyWith(
            surface: palette.surface,
            onSurface: palette.textPrimary,
            error: palette.error,
          ),
      fontFamily: 'Arial',
    );
  }

  static ThemeData get dark {
    final palette = AppPalette.dark;
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: palette.scaffold,
      colorScheme:
          ColorScheme.fromSeed(
            seedColor: AppColors.brandTeal,
            brightness: Brightness.dark,
          ).copyWith(
            surface: palette.surface,
            onSurface: palette.textPrimary,
            error: palette.error,
          ),
      fontFamily: 'Arial',
    );
  }
}
