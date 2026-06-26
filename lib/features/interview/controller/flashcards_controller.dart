import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:jobodia_frontend/core/utils/app_logger.dart';
import 'package:jobodia_frontend/features/interview/data/flashcard_data.dart';

class FlashcardsController extends GetxController {
  static const _bookmarksKey = 'flashcardBookmarks';
  static const _progressKey = 'flashcardProgress';
  final _storage = GetStorage();

  final bookmarkedKeys = <String>{}.obs;
  final lastSeenIndex = <String, int>{}.obs;
  final isLoadingData = true.obs;

  @override
  void onInit() {
    super.onInit();
    _load();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final jsonString = await rootBundle.loadString(
        'assets/data/flashcards.json',
      );
      final Map<String, dynamic> data = jsonDecode(jsonString);

      for (final category in flashcardCategories) {
        final cardsJson = data[category.name] as List<dynamic>? ?? [];
        category.cards = cardsJson
            .map(
              (c) => Flashcard(
                front: c['front'] as String,
                back: c['back'] as String,
                isCode: c['isCode'] as bool? ?? false,
              ),
            )
            .toList();
      }
    } catch (e, st) {
      AppLogger.error('Failed to load flashcard data', e, st);
    } finally {
      isLoadingData.value = false;
    }
  }

  bool isBookmarked(String category, int index) =>
      bookmarkedKeys.contains('$category:$index');

  void toggleBookmark(String category, int index) {
    final key = '$category:$index';
    if (bookmarkedKeys.contains(key)) {
      bookmarkedKeys.remove(key);
    } else {
      bookmarkedKeys.add(key);
    }
    bookmarkedKeys.refresh();
    _storage.write(_bookmarksKey, bookmarkedKeys.toList());
  }

  int getLastIndex(String category) => lastSeenIndex[category] ?? 0;

  void recordProgress(String category, int index) {
    final current = lastSeenIndex[category] ?? 0;
    if (index > current) {
      lastSeenIndex[category] = index;
      lastSeenIndex.refresh();
      _storage.write(_progressKey, Map<String, int>.from(lastSeenIndex));
    }
  }

  void _load() {
    try {
      final stored = _storage.read<List>(_bookmarksKey)?.cast<String>() ?? [];
      bookmarkedKeys.addAll(stored);
      final progressMap = _storage.read<Map<String, dynamic>>(_progressKey);
      if (progressMap != null) {
        lastSeenIndex.addAll(progressMap.map((k, v) => MapEntry(k, v as int)));
      }
    } on Object catch (e, st) {
      AppLogger.error('Failed to load flashcard progress from storage', e, st);
    }
  }
}
