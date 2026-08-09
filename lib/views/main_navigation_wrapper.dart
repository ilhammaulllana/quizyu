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

    // Listen for error state globally in navigation wrapper so snackbar & logs are never missed
    ref.listen<AsyncValue>(quizProvider, (previous, next) {
      next.whenOrNull(
        error: (error, stackTrace) {
          final errorStr = error.toString().replaceAll('Exception: ', '');
          final isOffline = errorStr.toLowerCase().contains('koneksi') ||
              errorStr.toLowerCase().contains('internet') ||
              errorStr.toLowerCase().contains('jaringan') ||
              errorStr.toLowerCase().contains('server');

          debugPrint('🌐 [GLOBAL NAVIGATION ERROR LOG] $errorStr (isOffline: $isOffline)');

          final scaffold = ScaffoldMessenger.maybeOf(context);
          if (scaffold != null) {
            scaffold.hideCurrentSnackBar();
            scaffold.showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    Icon(
                      isOffline ? Icons.wifi_off_rounded : Icons.error_outline_rounded,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        errorStr,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
                backgroundColor: isOffline ? const Color(0xFFD97706) : const Color(0xFFE11D48),
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.all(16),
                action: SnackBarAction(
                  label: 'OK',
                  textColor: Colors.white,
                  onPressed: () {
                    scaffold.hideCurrentSnackBar();
                  },
                ),
              ),
            );
          }
        },
      );
    });

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
        return const HomeScreen();
      },
    );
  }
}
