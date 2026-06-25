import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/quiz_notifier.dart';
import 'theme/app_theme.dart';
import 'views/home_screen.dart';
import 'views/quiz_screen.dart';
import 'views/dashboard_screen.dart';
import 'views/loading_screen.dart';

void main() {
  runApp(
    const ProviderScope(
      child: QuizyuApp(),
    ),
  );
}

class QuizyuApp extends StatelessWidget {
  const QuizyuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'quizyu - AI Smart Quiz',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.light,
      theme: AppTheme.lightTheme,
      home: const MainNavigationWrapper(),
    );
  }
}

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
