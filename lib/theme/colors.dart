part of 'theme.dart';

/// shadcn OKLCH colors converted to sRGB for Flutter/forui.
final FColors lightColors = FColors(
  brightness: Brightness.light,
  systemOverlayStyle: SystemUiOverlayStyle.dark,
  barrier: const Color(0x33000000),
  background: const Color(0xFFFFFFFF),
  foreground: const Color(0xFF0A0A0A),
  primary: const Color(0xFF7CCF00),
  primaryForeground: const Color(0xFFFFF7ED),
  secondary: const Color(0xFFF4F4F5),
  secondaryForeground: const Color(0xFF18181B),
  muted: const Color(0xFFF5F5F5),
  mutedForeground: const Color(0xFF737373),
  destructive: const Color(0xFFDF2225),
  destructiveForeground: const Color(0xFFFFFFFF),
  error: const Color(0xFFDF2225),
  errorForeground: const Color(0xFFFFFFFF),
  card: const Color(0xFFFFFFFF),
  border: const Color(0xFFE5E5E5),
  extensions: const [JobodiaColors()],
);

final FColors darkColors = FColors(
  brightness: Brightness.dark,
  systemOverlayStyle: SystemUiOverlayStyle.light,
  barrier: const Color(0x7A000000),
  background: const Color(0xFF0A0A0A),
  foreground: const Color(0xFFFAFAFA),
  primary: const Color(0xFF7CCF00),
  primaryForeground: const Color(0xFFFFF7ED),
  secondary: const Color(0xFF27272A),
  secondaryForeground: const Color(0xFFFAFAFA),
  muted: const Color(0xFF262626),
  mutedForeground: const Color(0xFFA1A1A1),
  destructive: const Color(0xFFFF6467),
  destructiveForeground: const Color(0xFFFFFFFF),
  error: const Color(0xFFFF6467),
  errorForeground: const Color(0xFFFFFFFF),
  card: const Color(0xFF171717),
  border: const Color(0x1AFFFFFF),
  extensions: const [JobodiaColors()],
);

/// Provides convenient access to theme extensions on [FColors].
extension FColorsExtensions on FColors {
  JobodiaColors get jobodia => extension<JobodiaColors>();
}

/// Jobodia-specific color tokens.
class JobodiaColors extends ThemeExtension<JobodiaColors> {
  const JobodiaColors({
    this.accent = const Color(0xFF7CCF00),
    this.accentDark = const Color(0xFF4F8500),
    this.purple = const Color(0xFFF54900),
    this.purpleDark = const Color(0xFFCA3500),
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
