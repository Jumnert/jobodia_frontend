/// Shared form-field validators.
abstract final class Validators {
  /// Returns an error message if [email] is not a valid email address,
  /// or `null` if valid.
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email is required';
    final re = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!re.hasMatch(value.trim().toLowerCase())) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  /// Returns an error message if [password] doesn't meet strength requirements.
  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 8) return 'Password must be at least 8 characters';
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Must contain an uppercase letter';
    }
    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'Must contain a lowercase letter';
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Must contain a number';
    }
    return null;
  }

  /// Returns an error message if [value] is empty.
  static String? required(String? value, {String label = 'This field'}) {
    if (value == null || value.trim().isEmpty) return '$label is required';
    return null;
  }

  /// Returns an error message if [value] is shorter than [min] characters.
  static String? minLength(String? value, int min, {String label = 'Value'}) {
    if (value == null || value.trim().length < min) {
      return '$label must be at least $min characters';
    }
    return null;
  }
}
