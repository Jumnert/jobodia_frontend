import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

enum AppLogLevel { info, warning, error }

class AppLogEntry {
  const AppLogEntry({
    required this.timestamp,
    required this.level,
    required this.message,
    this.error,
  });

  final DateTime timestamp;
  final AppLogLevel level;
  final String message;
  final String? error;
}

/// Lightweight app logger. Only emits in debug/profile mode via `assert`.
/// Silent in release builds — zero overhead in production.
class AppLogger {
  static const _maxEntries = 100;

  /// Recent debug/profile logs kept in memory for the Dev Logs screen.
  static final ValueNotifier<List<AppLogEntry>> entries = ValueNotifier(
    const [],
  );

  static void _remember(AppLogLevel level, String message, [Object? error]) {
    final updated = [
      ...entries.value,
      AppLogEntry(
        timestamp: DateTime.now(),
        level: level,
        message: message,
        error: error?.toString(),
      ),
    ];
    entries.value = updated.length > _maxEntries
        ? updated.sublist(updated.length - _maxEntries)
        : updated;
  }

  static void clear() => entries.value = const [];

  /// Logs an error with optional [error] object and [stack] trace.
  static void error(String message, [Object? error, StackTrace? stack]) {
    assert(() {
      _remember(AppLogLevel.error, message, error);
      developer.log(message, name: 'Jobodia', error: error, stackTrace: stack);
      return true;
    }());
  }

  /// Logs a warning message.
  static void warning(String message) {
    assert(() {
      _remember(AppLogLevel.warning, message);
      developer.log(message, name: 'Jobodia', level: 900);
      return true;
    }());
  }

  /// Logs an info message.
  static void info(String message) {
    assert(() {
      _remember(AppLogLevel.info, message);
      developer.log(message, name: 'Jobodia', level: 800);
      return true;
    }());
  }
}
