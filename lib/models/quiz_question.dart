class QuizQuestion {
  final String id;
  final String question;
  final List<String> options;
  final int correctAnswerIndex;
  final String hint;
  final String explanation;

  const QuizQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.correctAnswerIndex,
    required this.hint,
    required this.explanation,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json, String id) {
    return QuizQuestion(
      id: id,
      question: json['question'] ?? '',
      options: List<String>.from(json['options'] ?? []),
      correctAnswerIndex: json['correct_answer_index'] ?? 0,
      hint: json['hint'] ?? '',
      explanation: json['explanation'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'question': question,
      'options': options,
      'correct_answer_index': correctAnswerIndex,
      'hint': hint,
      'explanation': explanation,
    };
  }
}
