class AssessmentModel {
  const AssessmentModel({
    required this.id,
    required this.title,
    required this.durationMinutes,
    required this.totalQuestions,
    this.score,
    this.passed = false,
  });

  final String id;
  final String title;
  final int durationMinutes;
  final int totalQuestions;
  final double? score;
  final bool passed;

  AssessmentModel copyWith({
    String? id,
    String? title,
    int? durationMinutes,
    int? totalQuestions,
    double? score,
    bool? passed,
  }) {
    return AssessmentModel(
      id: id ?? this.id,
      title: title ?? this.title,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      score: score ?? this.score,
      passed: passed ?? this.passed,
    );
  }
}

class QuizQuestion {
  const QuizQuestion({
    required this.questionText,
    required this.options,
    required this.correctIndex,
  });

  final String questionText;
  final List<String> options;
  final int correctIndex;
}
