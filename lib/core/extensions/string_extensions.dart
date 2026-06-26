/// Convenience extensions on [String].
extension StringX on String {
  /// Capitalises the first character: `"hello"` → `"Hello"`.
  String get capitalize {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  /// URL-safe slug: `"Hello World!"` → `"hello-world"`.
  String get toSlug {
    return toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s-]'), '')
        .replaceAll(RegExp(r'\s+'), '-')
        .replaceAll(RegExp(r'-+'), '-')
        .replaceAll(RegExp(r'^-|-$'), '');
  }

  /// Whether this is a syntactically valid email address.
  bool get isValidEmail {
    return RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    ).hasMatch(trim().toLowerCase());
  }

  /// Truncate to [maxLength] with ellipsis.
  String truncate(int maxLength, {String suffix = '…'}) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength)}$suffix';
  }
}
