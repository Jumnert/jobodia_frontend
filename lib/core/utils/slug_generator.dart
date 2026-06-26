/// Generates URL-safe slugs from display names.
abstract final class SlugGenerator {
  /// "Flutter Developer" → "flutter-developer"
  static String generate(String input) {
    return input
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s-]'), '')
        .replaceAll(RegExp(r'\s+'), '-')
        .replaceAll(RegExp(r'-+'), '-')
        .replaceAll(RegExp(r'^-|-$'), '');
  }
}
