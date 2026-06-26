import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jobodia_frontend/features/assessments/model/assessment_model.dart';
import 'package:uuid/uuid.dart';

class AssessmentController extends GetxController {
  final _uuid = const Uuid();
  late final RxList<AssessmentModel> assessments;

  // Active quiz state
  final Rx<AssessmentModel?> currentQuiz = Rx<AssessmentModel?>(null);
  final currentQuestionIndex = 0.obs;
  final answers = <int, int>{}.obs; // questionIndex -> optionIndex

  final List<QuizQuestion> mockQuestions = [
    const QuizQuestion(
      questionText: 'What does "Widget" represent in Flutter?',
      options: [
        'A background service',
        'A database table',
        'An immutable description of part of a user interface',
        'A network request handler',
      ],
      correctIndex: 2,
    ),
    const QuizQuestion(
      questionText: 'Which keyword is used to wait for a Future?',
      options: ['yield', 'await', 'async', 'defer'],
      correctIndex: 1,
    ),
    const QuizQuestion(
      questionText: 'What does GetX primarily provide?',
      options: [
        'Only State Management',
        'Only Navigation',
        'State Management, Navigation, and Dependency Injection',
        'A database ORM',
      ],
      correctIndex: 2,
    ),
  ];

  @override
  void onInit() {
    super.onInit();
    assessments = [
      AssessmentModel(
        id: _uuid.v4(),
        title: 'Flutter Fundamentals',
        durationMinutes: 15,
        totalQuestions: 3,
        score: 100,
        passed: true,
      ),
      AssessmentModel(
        id: _uuid.v4(),
        title: 'Advanced Dart',
        durationMinutes: 20,
        totalQuestions: 3,
      ),
      AssessmentModel(
        id: _uuid.v4(),
        title: 'GetX Architecture',
        durationMinutes: 15,
        totalQuestions: 3,
      ),
    ].obs;
  }

  void startQuiz(AssessmentModel assessment) {
    currentQuiz.value = assessment;
    currentQuestionIndex.value = 0;
    answers.clear();
    Get.toNamed<void>('/assessment-quiz');
  }

  void selectAnswer(int optionIndex) {
    answers[currentQuestionIndex.value] = optionIndex;
  }

  void nextQuestion() {
    if (currentQuestionIndex.value < mockQuestions.length - 1) {
      currentQuestionIndex.value++;
    } else {
      _gradeQuiz();
    }
  }

  void _gradeQuiz() {
    int correctCount = 0;
    for (int i = 0; i < mockQuestions.length; i++) {
      if (answers[i] == mockQuestions[i].correctIndex) {
        correctCount++;
      }
    }

    final score = (correctCount / mockQuestions.length) * 100;
    final passed = score >= 70;

    // Update assessment list
    final idx = assessments.indexWhere((a) => a.id == currentQuiz.value!.id);
    if (idx != -1) {
      assessments[idx] = assessments[idx].copyWith(
        score: score,
        passed: passed,
      );
    }

    Get.back(); // close quiz screen

    Get.dialog<void>(
      AlertDialog(
        title: Text(passed ? 'Congratulations!' : 'Keep Practicing'),
        content: Text(
          'You scored ${score.toStringAsFixed(0)}%.\n'
          '${passed ? "You earned a new badge!" : "You need 70% to pass."}',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('OK')),
        ],
      ),
    );
  }
}
