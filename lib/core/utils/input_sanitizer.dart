/// Input sanitization utilities for user-supplied text.
///
/// Apply before persisting to storage or sending to a backend API.
class InputSanitizer {
  /// Trims whitespace and collapses multiple spaces into one.
  static String sanitizeText(String input) {
    return input.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  /// Validates and normalizes email addresses.
  /// Returns the normalized email or null if invalid.
  static String? normalizeEmail(String email) {
    final trimmed = email.trim().toLowerCase();
    final valid = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return valid.hasMatch(trimmed) ? trimmed : null;
  }

  /// Strips control characters (keeps printable Unicode).
  static String stripControlChars(String input) {
    return input.replaceAll(RegExp(r'[\x00-\x08\x0B\x0C\x0E-\x1F\x7F]'), '');
  }

  /// Full sanitization for text fields going to storage/API.
  static String sanitize(String input) {
    return sanitizeText(stripControlChars(input));
  }
}
