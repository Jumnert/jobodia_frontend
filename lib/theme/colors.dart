part of 'theme.dart';

/// Jobodia brand colors integrated with Forui theme.
final FColors lightColors = FColors(
  brightness: Brightness.light,
  systemOverlayStyle: SystemUiOverlayStyle.dark,
  barrier: const Color(0x33000000),
  background: const Color(0xFFF5F6F8),
  foreground: const Color(0xFF101214),
  primary: const Color(0xFF0EA5A4), // Jobodia brand teal
  primaryForeground: const Color(0xFFFFFFFF),
  secondary: const Color(0xFFF3F5F7),
  secondaryForeground: const Color(0xFF101214),
  muted: const Color(0xFFF3F5F7),
  mutedForeground: const Color(0xFF6F7378),
  destructive: const Color(0xFFD93B3B),
  destructiveForeground: const Color(0xFFFFFFFF),
  error: const Color(0xFFD93B3B),
  errorForeground: const Color(0xFFFFFFFF),
  card: const Color(0xFFFFFFFF),
  border: const Color(0xFFE9E9E9),
  extensions: const [JobodiaColors()],
);

final FColors darkColors = FColors(
  brightness: Brightness.dark,
  systemOverlayStyle: SystemUiOverlayStyle.light,
  barrier: const Color(0x7A000000),
  background: const Color(0xFF101214),
  foreground: const Color(0xFFFFFFFF),
  primary: const Color(0xFF0EA5A4), // Jobodia brand teal
  primaryForeground: const Color(0xFFFFFFFF),
  secondary: const Color(0xFF22262B),
  secondaryForeground: const Color(0xFFB7BDC3),
  muted: const Color(0xFF22262B),
  mutedForeground: const Color(0xFF7E868D),
  destructive: const Color(0xFFFF6467),
  destructiveForeground: const Color(0xFFFFFFFF),
  error: const Color(0xFFFF6467),
  errorForeground: const Color(0xFFFFFFFF),
  card: const Color(0xFF1A1D20),
  border: const Color(0xFF2A2E33),
  extensions: const [JobodiaColors()],
);

/// Provides convenient access to theme extensions on [FColors].
extension FColorsExtensions on FColors {
  JobodiaColors get jobodia => extension<JobodiaColors>();
}

/// Jobodia-specific color tokens.
class JobodiaColors extends ThemeExtension<JobodiaColors> {
  const JobodiaColors({
    this.accent = const Color(0xFF0EA5A4),
    this.accentDark = const Color(0xFF0C8A89),
    this.purple = const Color(0xFF8B5CF6),
    this.purpleDark = const Color(0xFF7C3AED),
  });

  final Color accent;
  final Color accentDark;
  final Color purple;
  final Color purpleDark;

  @override
  JobodiaColors copyWith({
    Color? accent,
    Color? accentDark,
    Color? purple,
    Color? purpleDark,
  }) {
    return JobodiaColors(
      accent: accent ?? this.accent,
      accentDark: accentDark ?? this.accentDark,
      purple: purple ?? this.purple,
      purpleDark: purpleDark ?? this.purpleDark,
    );
  }

  @override
  JobodiaColors lerp(covariant JobodiaColors? other, double t) {
    if (other == null) return this;
    return JobodiaColors(
      accent: Color.lerp(accent, other.accent, t)!,
      accentDark: Color.lerp(accentDark, other.accentDark, t)!,
      purple: Color.lerp(purple, other.purple, t)!,
      purpleDark: Color.lerp(purpleDark, other.purpleDark, t)!,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JobodiaColors &&
          accent == other.accent &&
          accentDark == other.accentDark &&
          purple == other.purple &&
          purpleDark == other.purpleDark;

  @override
  int get hashCode => Object.hash(accent, accentDark, purple, purpleDark);
}
