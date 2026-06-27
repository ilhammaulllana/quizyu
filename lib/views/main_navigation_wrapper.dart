import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/quiz_notifier.dart';
import 'home_screen.dart';
import 'quiz_screen.dart';
import 'dashboard_screen.dart';
import 'loading_screen.dart';

class MainNavigationWrapper extends ConsumerWidget {
  const MainNavigationWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quizState = ref.watch(quizProvider);

    return quizState.when(
      data: (session) {
        if (session == null) {
          return const HomeScreen();
        }
        if (session.isCompleted) {
          return const DashboardScreen();
        }
        return const QuizScreen();
      },
      loading: () => const GorgeousLoadingScreen(),
      error: (error, stack) {
        // If there's an error state, we show the HomeScreen but will display the error.
        // The HomeScreen itself has a listener to show Snackbars for errors,
        // so we render HomeScreen here as fallback.
        return const HomeScreen();
      },
    );
  }
}
