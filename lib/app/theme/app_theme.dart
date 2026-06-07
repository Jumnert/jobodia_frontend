import 'package:flutter/material.dart';
import 'package:jobodia_frontend/core/constants/app_colors.dart';

/// Central app theme.
abstract final class AppTheme {
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
      ),
      fontFamily: 'Arial',
    );
  }
}
