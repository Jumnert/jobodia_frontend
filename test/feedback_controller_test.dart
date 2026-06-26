import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_storage/get_storage.dart';
import 'package:jobodia_frontend/features/settings/controller/feedback_controller.dart';

/// Mock path_provider so GetStorage can initialize in tests.
Future<void> _setupPathProviderMock() async {
  const channel = MethodChannel('plugins.flutter.io/path_provider');
  final tempDir = await Directory.systemTemp.createTemp('gs_feedback_test_');

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

  late FeedbackController ctrl;

  setUp(() {
    ctrl = FeedbackController();
  });

  tearDown(() {
    ctrl.dispose();
  });

  group('submit - rating validation', () {
    test('rejects rating below 1', () {
      ctrl.submit(0, 'Some comment');

      expect(ctrl.entries, isEmpty);
    });

    test('rejects rating of 0', () {
      ctrl.submit(0, 'Comment');

      expect(ctrl.entries, isEmpty);
    });

    test('rejects negative rating', () {
      ctrl.submit(-1, 'Comment');

      expect(ctrl.entries, isEmpty);
    });

    test('rejects rating above 5', () {
      ctrl.submit(6, 'Comment');

      expect(ctrl.entries, isEmpty);
    });

    test('accepts rating of 1', () {
      ctrl.submit(1, 'Valid comment');

      expect(ctrl.entries.length, 1);
      expect(ctrl.entries.first.rating, 1);
    });

    test('accepts rating of 5', () {
      ctrl.submit(5, 'Valid comment');

      expect(ctrl.entries.length, 1);
      expect(ctrl.entries.first.rating, 5);
    });

    test('accepts ratings in the middle (2, 3, 4)', () {
      ctrl.submit(2, 'Comment 2');
      ctrl.submit(3, 'Comment 3');
      ctrl.submit(4, 'Comment 4');

      expect(ctrl.entries.length, 3);
    });
  });

  group('submit - comment validation', () {
    test('rejects empty comment', () {
      ctrl.submit(5, '');

      expect(ctrl.entries, isEmpty);
    });

    test('rejects whitespace-only comment', () {
      ctrl.submit(5, '   ');

      expect(ctrl.entries, isEmpty);
    });

    test('trims comment whitespace', () {
      ctrl.submit(5, '  Great app!  ');

      expect(ctrl.entries.length, 1);
      expect(ctrl.entries.first.comment, 'Great app!');
    });

    test('accepts non-empty comment', () {
      ctrl.submit(4, 'Nice experience');

      expect(ctrl.entries.length, 1);
      expect(ctrl.entries.first.comment, 'Nice experience');
    });
  });

  group('submit - entry structure', () {
    test('entry contains correct rating and comment', () {
      ctrl.submit(3, 'Average app');

      expect(ctrl.entries.first.rating, 3);
      expect(ctrl.entries.first.comment, 'Average app');
    });

    test('entry has a date', () {
      final before = DateTime.now();
      ctrl.submit(4, 'Good');
      final after = DateTime.now();

      expect(
        ctrl.entries.first.date.isAfter(before) ||
            ctrl.entries.first.date.isAtSameMomentAs(before),
        isTrue,
      );
      expect(
        ctrl.entries.first.date.isBefore(after) ||
            ctrl.entries.first.date.isAtSameMomentAs(after),
        isTrue,
      );
    });

    test('new entries are inserted at the front', () {
      ctrl.submit(5, 'First');
      ctrl.submit(3, 'Second');

      expect(ctrl.entries.first.comment, 'Second');
      expect(ctrl.entries.last.comment, 'First');
    });

    test('multiple valid submissions all recorded', () {
      ctrl.submit(5, 'Great');
      ctrl.submit(4, 'Good');
      ctrl.submit(3, 'Okay');

      expect(ctrl.entries.length, 3);
    });
  });

  group('FeedbackEntry', () {
    test('toJson/fromJson round-trip', () {
      final entry = FeedbackEntry(
        rating: 4,
        comment: 'Test feedback',
        date: DateTime(2025, 6, 15, 10, 30),
      );

      final json = entry.toJson();
      final restored = FeedbackEntry.fromJson(json);

      expect(restored.rating, 4);
      expect(restored.comment, 'Test feedback');
      expect(restored.date, DateTime(2025, 6, 15, 10, 30));
    });

    test('fromJson handles missing fields gracefully', () {
      final restored = FeedbackEntry.fromJson(<String, dynamic>{});

      expect(restored.rating, 0);
      expect(restored.comment, '');
      expect(restored.date, isA<DateTime>());
    });

    test('fromJson handles null values gracefully', () {
      final restored = FeedbackEntry.fromJson({
        'rating': null,
        'comment': null,
        'date': null,
      });

      expect(restored.rating, 0);
      expect(restored.comment, '');
      expect(restored.date, isA<DateTime>());
    });
  });
}
