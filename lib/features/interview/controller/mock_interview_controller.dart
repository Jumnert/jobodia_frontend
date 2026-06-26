import 'dart:async';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:jobodia_frontend/core/utils/app_logger.dart';

class MockInterviewController extends GetxController {
  static const _historyKey = 'mockInterviewHistory';
  final _storage = GetStorage();

  final currentIndex = 0.obs;
  final isAnswerRevealed = false.obs;
  final isFinished = false.obs;
  final ratings = <String>[].obs;
  final lastRating = ''.obs;
  final timerSeconds = 90.obs;
  final isTimerPaused = false.obs;
  final pastSessions = <Map<String, dynamic>>[].obs;
  Timer? _timer;
  int totalQuestions = 10;

  int get nailedCount => ratings.where((r) => r == 'nailed').length;
  int get almostCount => ratings.where((r) => r == 'almost').length;
  int get missedCount => ratings.where((r) => r == 'missed').length;
  int get scorePercent => ratings.isEmpty
      ? 0
      : ((nailedCount * 100 + almostCount * 50) / ratings.length).round();

  @override
  void onInit() {
    super.onInit();
    _loadHistory();
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }

  void startTimer() {
    _timer?.cancel();
    timerSeconds.value = 90;
    isTimerPaused.value = false;
    isAnswerRevealed.value = false;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (isTimerPaused.value) return;
      if (timerSeconds.value > 0) {
        timerSeconds.value--;
      } else {
        t.cancel();
        isAnswerRevealed.value = true;
      }
    });
  }

  void pauseResume() => isTimerPaused.value = !isTimerPaused.value;

  void revealAnswer() {
    _timer?.cancel();
    isAnswerRevealed.value = true;
  }

  void rate(String rating) {
    lastRating.value = rating;
    ratings.add(rating);
    if (currentIndex.value < totalQuestions - 1) {
      currentIndex.value++;
      lastRating.value = '';
      startTimer();
    } else {
      _finishSession();
    }
  }

  void nextQuestion() {
    if (currentIndex.value < totalQuestions - 1) {
      currentIndex.value++;
      startTimer();
    }
  }

  void previousQuestion() {
    if (currentIndex.value > 0) {
      currentIndex.value--;
      startTimer();
    }
  }

  void _finishSession() {
    _timer?.cancel();
    isFinished.value = true;
    pastSessions.insert(0, {
      'date': DateTime.now().toIso8601String(),
      'score': scorePercent,
      'nailed': nailedCount,
      'almost': almostCount,
      'missed': missedCount,
      'total': totalQuestions,
    });
    if (pastSessions.length > 10) {
      pastSessions.removeRange(10, pastSessions.length);
    }
    _storage.write(_historyKey, pastSessions.toList());
  }

  void resetSession() {
    _timer?.cancel();
    currentIndex.value = 0;
    isAnswerRevealed.value = false;
    isFinished.value = false;
    ratings.clear();
    timerSeconds.value = 90;
    isTimerPaused.value = false;
    startTimer();
  }

  void _loadHistory() {
    try {
      final stored = _storage.read<List>(_historyKey);
      if (stored != null) {
        pastSessions.assignAll(stored.cast<Map<String, dynamic>>());
      }
    } on Object catch (e, st) {
      AppLogger.error('Failed to load interview history from storage', e, st);
    }
  }
}
