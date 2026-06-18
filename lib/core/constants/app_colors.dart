import 'package:flutter/material.dart';

/// App color palette. Change these values to match final Figma colors.
abstract final class AppColors {
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

  /// Gradient pairings for job feed cards. Cards cycle through these by index
  /// so each card gets a distinct, high-contrast background for white text.
  static const cardGradients = <List<Color>>[
    [Color(0xFF2B5DF0), Color(0xFF7C3AED)], // Deep Blue → Purple
    [Color(0xFF0EA5A4), Color(0xFF10B981)], // Teal → Emerald
    [Color(0xFFFF7E45), Color(0xFFFF5A6E)], // Sunset Orange → Coral
    [Color(0xFF6D5BF8), Color(0xFFB14CF0)], // Indigo → Violet
  ];
}
