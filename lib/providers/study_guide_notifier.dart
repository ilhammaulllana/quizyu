import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/quiz_session.dart';
import '../services/api_service.dart';

class StudyGuideNotifier extends StateNotifier<AsyncValue<String?>> {
  StudyGuideNotifier() : super(const AsyncValue.data(null));

  /// Generates a study guide based on the wrong answers in the provided quiz session.
  Future<void> generateGuide(QuizSession session) async {
    state = const AsyncValue.loading();
    try {
      // Find incorrect questions
      final incorrectQuestions = session.questions.where((q) {
        final index = session.questions.indexOf(q);
        final selectedAnswer = session.selectedAnswers[index];
        return selectedAnswer != q.correctAnswerIndex;
      }).toList();

      final incorrectQuestionsJson = incorrectQuestions.map((q) => q.toJson()).toList();

      final markdown = await ApiService().generateStudyGuide(
        topic: session.topic,
        incorrectQuestions: incorrectQuestionsJson,
      );

      state = AsyncValue.data(markdown);
    } catch (e, stack) {
      state = AsyncValue.error('Gagal membuat panduan belajar: $e', stack);
    }
  }

  /// Resets the study guide state.
  void reset() {
    state = const AsyncValue.data(null);
  }
}

final studyGuideProvider = StateNotifierProvider<StudyGuideNotifier, AsyncValue<String?>>((ref) {
  return StudyGuideNotifier();
});
