import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/quiz_notifier.dart';
import '../providers/study_guide_notifier.dart';
import 'widgets/quiz_settings_sheet.dart';
import 'study_guide_screen.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quizState = ref.watch(quizProvider);
    final theme = Theme.of(context);

    final session = quizState.value;
    if (session == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final accuracy = session.accuracy;
    final correctCount = session.correctCount;
    final incorrectCount = session.incorrectCount;
    final skippedCount = session.skippedCount;
    final totalQuestions = session.totalQuestions;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF07050C),
              Color(0xFF0F0E1E),
              Color(0xFF07050C),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                // Heading banner
                const Center(
                  child: Text(
                    'Kuis Selesai! 🎉',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Center(
                  child: Text(
                    session.topic,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFFA78BFA),
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 36),

                // Main Accuracy Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(28.0),
                    child: Column(
                      children: [
                        // Circular gauge
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 140,
                              height: 140,
                              child: CircularProgressIndicator(
                                value: accuracy / 100,
                                strokeWidth: 12,
                                backgroundColor: const Color(0xFF1C1A30),
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  accuracy >= 70
                                      ? theme.colorScheme.secondary
                                      : accuracy >= 40
                                          ? const Color(0xFFFF8906)
                                          : theme.colorScheme.error,
                                ),
                              ),
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '${accuracy.toStringAsFixed(0)}%',
                                  style: const TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: -1.0,
                                  ),
                                ),
                                const Text(
                                  'Akurasi',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF94A1B2),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        // Score raw text
                        Text(
                          'Skor Anda: $correctCount dari $totalQuestions benar',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Breakout Grid (Benar, Salah, Dilewati)
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        title: 'Benar',
                        count: correctCount,
                        color: theme.colorScheme.secondary,
                        icon: Icons.check_circle_outline_rounded,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        title: 'Salah',
                        count: incorrectCount,
                        color: theme.colorScheme.error,
                        icon: Icons.highlight_off_rounded,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        title: 'Dilewati',
                        count: skippedCount,
                        color: const Color(0xFF94A1B2),
                        icon: Icons.next_plan_outlined,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 48),

                // Primary action: "Analisis performa saya" (AI Study Guide)
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF7F5AF0), Color(0xFF9061F9)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: theme.primaryColor.withOpacity(0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () {
                      // Trigger loading study guide
                      ref.read(studyGuideProvider.notifier).generateGuide(session);
                      
                      // Navigate to study guide screen
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const StudyGuideScreen(),
                        ),
                      );
                    },
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.auto_awesome, size: 20),
                        SizedBox(width: 10),
                        Text(
                          'Analisis Performa Saya',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Secondary action: "Tambahkan pertanyaan" (Custom Settings bottom sheet)
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: theme.primaryColor.withOpacity(0.5), width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () {
                    // Open customization sheet
                    showModalBottomSheet(
                      context: context,
                      backgroundColor: Colors.transparent,
                      isScrollControlled: true,
                      builder: (context) => const QuizSettingsSheet(),
                    );
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.tune_rounded, size: 20, color: theme.primaryColor),
                      const SizedBox(width: 10),
                      Text(
                        'Tambahkan Pertanyaan',
                        style: TextStyle(
                          fontSize: 16,
                          color: theme.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Text link to reset and go home
                Center(
                  child: TextButton.icon(
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF94A1B2),
                    ),
                    onPressed: () {
                      ref.read(quizProvider.notifier).resetQuiz();
                    },
                    icon: const Icon(Icons.home_rounded, size: 18),
                    label: const Text(
                      'Kembali ke Beranda',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required int count,
    required Color color,
    required IconData icon,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 8),
            Text(
              '$count',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF94A1B2),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
