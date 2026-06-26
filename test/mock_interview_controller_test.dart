import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_storage/get_storage.dart';
import 'package:jobodia_frontend/features/interview/controller/mock_interview_controller.dart';

/// Mock path_provider so GetStorage can initialize in tests.
Future<void> _setupPathProviderMock() async {
  const channel = MethodChannel('plugins.flutter.io/path_provider');
  final tempDir = await Directory.systemTemp.createTemp('gs_mock_test_');

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

  late MockInterviewController ctrl;

  setUp(() {
    ctrl = MockInterviewController();
  });

  tearDown(() {
    ctrl.dispose();
  });

  group('rate', () {
    test('records rating in ratings list', () {
      ctrl.rate('nailed');

      expect(ctrl.ratings, contains('nailed'));
      expect(ctrl.ratings.length, 1);
    });

    test('advances currentIndex when not on last question', () {
      expect(ctrl.currentIndex.value, 0);

      ctrl.rate('nailed');

      expect(ctrl.currentIndex.value, 1);
    });

    test('finishes session on last question', () {
      ctrl.currentIndex.value = ctrl.totalQuestions - 1;

      ctrl.rate('missed');

      expect(ctrl.isFinished.value, isTrue);
    });

    test('preserves lastRating value when finishing', () {
      ctrl.currentIndex.value = ctrl.totalQuestions - 1;

      ctrl.rate('nailed');

      expect(ctrl.lastRating.value, 'nailed');
    });

    test('resets lastRating after advancing to next question', () {
      ctrl.rate('almost');

      // After rating on non-last question, lastRating is reset to ''.
      expect(ctrl.lastRating.value, '');
    });

    test('computed nailedCount after ratings', () {
      // Rate multiple questions by manually setting currentIndex forward.
      ctrl.rate('nailed'); // index 0 -> 1
      ctrl.currentIndex.value = 1;
      ctrl.rate('nailed'); // index 1 -> 2
      ctrl.currentIndex.value = 2;
      ctrl.rate('almost'); // index 2 -> 3

      expect(ctrl.nailedCount, 2);
      expect(ctrl.almostCount, 1);
      expect(ctrl.missedCount, 0);
    });

    test('scorePercent computes weighted score', () {
      ctrl.ratings.addAll(['nailed', 'nailed', 'almost', 'missed']);
      // scorePercent = (2*100 + 1*50) / 4 = 62.5 -> 63
      expect(ctrl.scorePercent, 63);
    });

    test('scorePercent is 0 with no ratings', () {
      expect(ctrl.scorePercent, 0);
    });
  });

  group('startTimer', () {
    test('resets timerSeconds to 90', () {
      ctrl.timerSeconds.value = 10;

      ctrl.startTimer();

      expect(ctrl.timerSeconds.value, 90);
    });

    test('sets isTimerPaused to false', () {
      ctrl.isTimerPaused.value = true;

      ctrl.startTimer();

      expect(ctrl.isTimerPaused.value, isFalse);
    });

    test('sets isAnswerRevealed to false', () {
      ctrl.isAnswerRevealed.value = true;

      ctrl.startTimer();

      expect(ctrl.isAnswerRevealed.value, isFalse);
    });

    test('timer counts down', () async {
      ctrl.startTimer();

      await Future<void>.delayed(const Duration(milliseconds: 1100));

      expect(ctrl.timerSeconds.value, lessThan(90));
    });
  });

  group('resetSession', () {
    test('resets currentIndex to 0', () {
      ctrl.currentIndex.value = 5;

      ctrl.resetSession();

      expect(ctrl.currentIndex.value, 0);
    });

    test('clears ratings', () {
      ctrl.ratings.addAll(['nailed', 'almost', 'missed']);

      ctrl.resetSession();

      expect(ctrl.ratings, isEmpty);
    });

    test('sets isFinished to false', () {
      ctrl.isFinished.value = true;

      ctrl.resetSession();

      expect(ctrl.isFinished.value, isFalse);
    });

    test('resets timerSeconds to 90', () {
      ctrl.timerSeconds.value = 30;

      ctrl.resetSession();

      expect(ctrl.timerSeconds.value, 90);
    });

    test('resets isTimerPaused to false', () {
      ctrl.isTimerPaused.value = true;

      ctrl.resetSession();

      expect(ctrl.isTimerPaused.value, isFalse);
    });

    test('resets isAnswerRevealed to false', () {
      ctrl.isAnswerRevealed.value = true;

      ctrl.resetSession();

      expect(ctrl.isAnswerRevealed.value, isFalse);
    });

    test('starts a new timer after reset', () async {
      ctrl.resetSession();

      await Future<void>.delayed(const Duration(milliseconds: 1100));

      expect(ctrl.timerSeconds.value, lessThan(90));
    });
  });

  group('pauseResume', () {
    test('toggles isTimerPaused', () {
      expect(ctrl.isTimerPaused.value, isFalse);

      ctrl.pauseResume();
      expect(ctrl.isTimerPaused.value, isTrue);

      ctrl.pauseResume();
      expect(ctrl.isTimerPaused.value, isFalse);
    });
  });

  group('revealAnswer', () {
    test('sets isAnswerRevealed to true', () {
      ctrl.revealAnswer();

      expect(ctrl.isAnswerRevealed.value, isTrue);
    });
  });

  group('computed getters', () {
    test('nailedCount, almostCount, missedCount count correctly', () {
      ctrl.ratings.addAll([
        'nailed',
        'nailed',
        'almost',
        'missed',
        'missed',
        'missed',
      ]);

      expect(ctrl.nailedCount, 2);
      expect(ctrl.almostCount, 1);
      expect(ctrl.missedCount, 3);
    });
  });
}
