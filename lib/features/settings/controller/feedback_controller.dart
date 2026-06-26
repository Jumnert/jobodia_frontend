import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class FeedbackEntry {
  FeedbackEntry({
    required this.rating,
    required this.comment,
    required this.date,
  });
  final int rating;
  final String comment;
  final DateTime date;

  Map<String, dynamic> toJson() => {
    'rating': rating,
    'comment': comment,
    'date': date.toIso8601String(),
  };
  factory FeedbackEntry.fromJson(Map<String, dynamic> json) => FeedbackEntry(
    rating: (json['rating'] as num?)?.toInt() ?? 0,
    comment: json['comment'] as String? ?? '',
    date: DateTime.tryParse(json['date'] as String? ?? '') ?? DateTime.now(),
  );
}

class FeedbackController extends GetxController {
  static const _key = 'feedbackEntries';
  final _storage = GetStorage();
  final entries = <FeedbackEntry>[].obs;

  @override
  void onInit() {
    super.onInit();
    final stored = _storage.read<List>(_key);
    if (stored != null) {
      entries.assignAll(
        stored.map((e) => FeedbackEntry.fromJson(e as Map<String, dynamic>)),
      );
    }
  }

  void submit(int rating, String comment) {
    if (rating < 1 || rating > 5) return;
    final trimmed = comment.trim();
    if (trimmed.isEmpty) return;
    entries.insert(
      0,
      FeedbackEntry(rating: rating, comment: trimmed, date: DateTime.now()),
    );
    _storage.write(_key, entries.map((e) => e.toJson()).toList());
  }
}
