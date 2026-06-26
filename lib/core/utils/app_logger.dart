import 'dart:developer' as developer;

/// Lightweight app logger. Only emits in debug/profile mode via `assert`.
/// Silent in release builds — zero overhead in production.
class AppLogger {
  /// Logs an error with optional [error] object and [stack] trace.
  static void error(String message, [Object? error, StackTrace? stack]) {
    assert(() {
      developer.log(message, name: 'Jobodia', error: error, stackTrace: stack);
      return true;
    }());
  }

  /// Logs a warning message.
  static void warning(String message) {
    assert(() {
      developer.log(message, name: 'Jobodia', level: 900);
      return true;
    }());
  }

  /// Logs an info message.
  static void info(String message) {
    assert(() {
      developer.log(message, name: 'Jobodia', level: 800);
      return true;
    }());
  }
}
