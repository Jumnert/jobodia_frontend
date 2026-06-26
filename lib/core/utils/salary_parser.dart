/// Parses salary range strings like "$3k–$6k" or "3000-6000" into a double range.
abstract final class SalaryParser {
  /// Returns [min, max] from a salary range string, or null if unparseable.
  static List<double>? parse(String input) {
    final cleaned = input.replaceAll(RegExp(r'[^\d\s\-–kKmM.]'), '').trim();
    final parts = cleaned.split(RegExp(r'\s*[-–]\s*'));
    if (parts.length != 2) return null;

    double? parsePart(String s) {
      s = s.trim().toLowerCase();
      if (s.endsWith('k')) {
        return double.tryParse(s.replaceAll('k', ''))?.let((v) => v * 1000);
      }
      if (s.endsWith('m')) {
        return double.tryParse(s.replaceAll('m', ''))?.let((v) => v * 1000000);
      }
      return double.tryParse(s);
    }

    final min = parsePart(parts[0]);
    final max = parsePart(parts[1]);
    if (min == null || max == null) return null;
    return [min, max];
  }
}

extension _Let<T> on T {
  R let<R>(R Function(T) fn) => fn(this);
}
