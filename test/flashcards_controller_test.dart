import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_storage/get_storage.dart';
import 'package:jobodia_frontend/features/interview/controller/flashcards_controller.dart';

/// Mock path_provider so GetStorage can initialize in tests.
Future<void> _setupPathProviderMock() async {
  const channel = MethodChannel('plugins.flutter.io/path_provider');
  final tempDir = await Directory.systemTemp.createTemp('gs_test_');

  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(channel, (MethodCall call) async {
        if (call.method == 'getApplicationDocumentsDirectory') {
          return tempDir.path;
        }
        return null;
      });
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await _setupPathProviderMock();
    await GetStorage.init();
  });

  setUp(() async {
    final storage = GetStorage();
    await storage.erase();
  });

  late FlashcardsController ctrl;

  setUp(() {
    ctrl = FlashcardsController();
  });

  tearDown(() {
    ctrl.dispose();
  });

  group('isBookmarked', () {
    test('returns false when set is empty', () {
      expect(ctrl.isBookmarked('Flutter', 0), isFalse);
    });

    test('returns true after adding the key', () {
      ctrl.bookmarkedKeys.add('Flutter:0');
      expect(ctrl.isBookmarked('Flutter', 0), isTrue);
    });

    test('returns false for different category/index', () {
      ctrl.bookmarkedKeys.add('Flutter:0');
      expect(ctrl.isBookmarked('Dart', 0), isFalse);
      expect(ctrl.isBookmarked('Flutter', 1), isFalse);
    });

    test('composite key format is "category:index"', () {
      ctrl.bookmarkedKeys.add('Flutter:3');
      expect(ctrl.bookmarkedKeys, contains('Flutter:3'));
    });
  });

  group('toggleBookmark', () {
    test('adds a bookmark when not present', () {
      ctrl.toggleBookmark('Flutter', 0);

      expect(ctrl.bookmarkedKeys, contains('Flutter:0'));
      expect(ctrl.isBookmarked('Flutter', 0), isTrue);
    });

    test('removes a bookmark when already present', () {
      ctrl.toggleBookmark('Flutter', 0);
      ctrl.toggleBookmark('Flutter', 0);

      expect(ctrl.bookmarkedKeys, isNot(contains('Flutter:0')));
      expect(ctrl.isBookmarked('Flutter', 0), isFalse);
    });

    test('toggling does not affect other bookmarks', () {
      ctrl.toggleBookmark('Flutter', 0);
      ctrl.toggleBookmark('Dart', 1);

      ctrl.toggleBookmark('Flutter', 0); // remove Flutter:0

      expect(ctrl.isBookmarked('Flutter', 0), isFalse);
      expect(ctrl.isBookmarked('Dart', 1), isTrue);
    });

    test('multiple toggles work correctly', () {
      ctrl.toggleBookmark('A', 0);
      ctrl.toggleBookmark('B', 1);
      ctrl.toggleBookmark('C', 2);

      expect(ctrl.bookmarkedKeys.length, 3);

      ctrl.toggleBookmark('B', 1); // remove
      expect(ctrl.bookmarkedKeys.length, 2);
      expect(ctrl.isBookmarked('A', 0), isTrue);
      expect(ctrl.isBookmarked('B', 1), isFalse);
      expect(ctrl.isBookmarked('C', 2), isTrue);
    });
  });

  group('recordProgress', () {
    test('updates lastSeenIndex for new category', () {
      ctrl.recordProgress('Flutter', 3);

      expect(ctrl.lastSeenIndex['Flutter'], 3);
    });

    test('getLastIndex returns 0 for unknown category', () {
      expect(ctrl.getLastIndex('Unknown'), 0);
    });

    test('getLastIndex returns recorded value', () {
      ctrl.recordProgress('Flutter', 5);

      expect(ctrl.getLastIndex('Flutter'), 5);
    });

    test('updates when index is higher than current', () {
      ctrl.recordProgress('Flutter', 3);
      ctrl.recordProgress('Flutter', 7);

      expect(ctrl.lastSeenIndex['Flutter'], 7);
    });

    test('does NOT update when index is lower than current', () {
      ctrl.recordProgress('Flutter', 7);
      ctrl.recordProgress('Flutter', 3);

      expect(ctrl.lastSeenIndex['Flutter'], 7);
    });

    test('does NOT update when index equals current', () {
      ctrl.recordProgress('Flutter', 5);
      ctrl.recordProgress('Flutter', 5);

      expect(ctrl.lastSeenIndex['Flutter'], 5);
    });

    test('tracks multiple categories independently', () {
      ctrl.recordProgress('Flutter', 5);
      ctrl.recordProgress('Dart', 2);
      ctrl.recordProgress('Firebase', 8);

      expect(ctrl.getLastIndex('Flutter'), 5);
      expect(ctrl.getLastIndex('Dart'), 2);
      expect(ctrl.getLastIndex('Firebase'), 8);
    });
  });
}
