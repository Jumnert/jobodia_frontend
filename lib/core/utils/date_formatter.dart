/// Shared date formatting utilities.
abstract final class DateFormatter {
  static const _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  /// "Jun 2025"
  static String monthYear(DateTime date) =>
      '${_months[date.month - 1]} ${date.year}';

  /// "Jun 26, 2025"
  static String fullDate(DateTime date) =>
      '${_months[date.month - 1]} ${date.day}, ${date.year}';

  /// "3 days ago", "Just now", etc.
  static String timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()}w ago';
    return monthYear(date);
  }

  /// Date range string: "Jun 2023 – Present" or "Jun 2023 – Dec 2024".
  static String dateRange(DateTime start, DateTime? end) {
    final startStr = monthYear(start);
    final endStr = end != null ? monthYear(end) : 'Present';
    return '$startStr – $endStr';
  }
}
