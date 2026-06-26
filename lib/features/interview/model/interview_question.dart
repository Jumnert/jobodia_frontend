/// A single mock-interview question with a model answer the user can reveal.
class InterviewQuestion {
  const InterviewQuestion({required this.prompt, required this.modelAnswer});

  final String prompt;
  final String modelAnswer;
}
