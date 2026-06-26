mixin FormValidationMixin {
  /// Validates any standard email address (not just Gmail).
  bool isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email.trim().toLowerCase());
  }

  bool isValidUsername(String username) {
    final usernameRegex = RegExp(r'^[a-zA-Z0-9\s\-]+$');
    return usernameRegex.hasMatch(username.trim());
  }

  /// Validates password strength. Returns an error message or null if valid.
  String? validatePassword(String password) {
    if (password.length < 8) return 'Password must be at least 8 characters';
    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      return 'Password must contain an uppercase letter';
    }
    if (!RegExp(r'[a-z]').hasMatch(password)) {
      return 'Password must contain a lowercase letter';
    }
    if (!RegExp(r'[0-9]').hasMatch(password)) {
      return 'Password must contain a number';
    }
    return null;
  }
}
