/// Named durations used across the app for animations, debounce, and timers.
abstract final class AppDurations {
  /// Quick micro-interaction (button press, toggle).
  static const fast = Duration(milliseconds: 150);

  /// Standard transition (page slide, fade).
  static const medium = Duration(milliseconds: 250);

  /// Longer entrance animation.
  static const slow = Duration(milliseconds: 400);

  /// Debounce delay for text input.
  static const debounce = Duration(milliseconds: 300);

  /// Typing indicator delay before bot reply.
  static const typingDelay = Duration(milliseconds: 1500);

  /// Snackbar auto-dismiss.
  static const snackbar = Duration(seconds: 3);

  /// Mock timer per interview question.
  static const interviewTimerSeconds = 90;
}
