import 'package:get/get.dart';

/// Localizes app-formatted relative times while leaving unknown source text
/// untouched. This prevents employer-provided content from being translated.
String localizedTimeAgo(String value) {
  final normalized = value.trim().toLowerCase();
  if (normalized == 'just now') return 'just_now'.tr;

  final match = RegExp(
    r'^(\d+)\s+(minute|minutes|hour|hours|day|days)\s+ago$',
  ).firstMatch(normalized);
  if (match == null) return value;

  final count = int.parse(match.group(1)!);
  final unit = match.group(2)!;
  final key = switch (unit) {
    'minute' => 'minute_ago',
    'minutes' => 'minutes_ago',
    'hour' => 'hour_ago',
    'hours' => 'hours_ago',
    'day' => 'day_ago',
    'days' => 'days_ago',
    _ => '',
  };
  return key.trParams({'count': '$count'});
}
