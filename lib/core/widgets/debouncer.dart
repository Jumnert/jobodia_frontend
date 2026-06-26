import 'dart:async';

/// Timer-based debouncer that delays execution until [duration] has elapsed
/// since the last call to [run]. Default delay is 300 ms.
class Debouncer {
  Debouncer({this.duration = const Duration(milliseconds: 300)});

  /// How long to wait after the last [run] call before executing.
  final Duration duration;

  Timer? _timer;

  /// Schedules [action] to run after [duration]. If called again before the
  /// timer fires, the previous action is cancelled.
  void run(void Function() action) {
    _timer?.cancel();
    _timer = Timer(duration, action);
  }

  /// Cancels any pending action.
  void cancel() {
    _timer?.cancel();
    _timer = null;
  }

  /// Cancels the timer. Call in `dispose()`.
  void dispose() => cancel();
}
