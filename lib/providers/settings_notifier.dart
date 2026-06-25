import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/quiz_settings.dart';

class SettingsNotifier extends StateNotifier<QuizSettings> {
  SettingsNotifier() : super(const QuizSettings());

  void setTopic(String topic) {
    state = state.copyWith(topic: topic);
  }

  void setModelVersion(String modelVersion) {
    state = state.copyWith(modelVersion: modelVersion);
  }

  void setQuestionCount(int questionCount) {
    state = state.copyWith(questionCount: questionCount);
  }

  void setDifficulty(String difficulty) {
    state = state.copyWith(difficulty: difficulty);
  }

  void setFocusArea(String focusArea) {
    state = state.copyWith(focusArea: focusArea);
  }

  void reset() {
    state = const QuizSettings();
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, QuizSettings>((ref) {
  return SettingsNotifier();
});
