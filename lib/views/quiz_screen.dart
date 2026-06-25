import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/quiz_notifier.dart';

class QuizScreen extends ConsumerWidget {
  const QuizScreen({super.key});

  void _showExitConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF161424),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFF2E2A47), width: 1.5),
        ),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Color(0xFFFF8906)),
            SizedBox(width: 12),
            Text('Keluar Kuis?'),
          ],
        ),
        content: const Text(
          'Apakah Anda yakin ingin keluar dari sesi kuis ini? Semua progres pengerjaan saat ini akan hilang.',
          style: TextStyle(color: Color(0xFF94A1B2)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Batal', style: TextStyle(color: Color(0xFF94A1B2))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(quizProvider.notifier).resetQuiz();
            },
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quizState = ref.watch(quizProvider);
    final theme = Theme.of(context);

    // If for some reason state is loading/error in this widget, we can return empty or fallback
    final session = quizState.value;
    if (session == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final currentQuestion = session.currentQuestion;
    if (currentQuestion == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final int questionIdx = session.currentIndex;
    final int totalQuestions = session.totalQuestions;
    final double progress = (questionIdx + 1) / totalQuestions;

    final isAnswered = session.selectedAnswers.containsKey(questionIdx);
    final selectedAnswerIndex = session.selectedAnswers[questionIdx];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Colors.white),
          onPressed: () => _showExitConfirmation(context, ref),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              session.topic,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFFA78BFA),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              'Soal ${questionIdx + 1} dari $totalQuestions',
              style: const TextStyle(fontSize: 12, color: Color(0xFF94A1B2)),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(6),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                backgroundColor: const Color(0xFF1C1A30),
                valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColor),
              ),
            ),
          ),
        ),
      ),
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
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Question text card
                      Card(
                        margin: EdgeInsets.zero,
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Text(
                            currentQuestion.question,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              height: 1.4,
                              letterSpacing: -0.2,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Hint Accordion Widget
                      HintAccordion(hintText: currentQuestion.hint),
                      const SizedBox(height: 24),

                      // Answer options (A, B, C, D)
                      ...List.generate(currentQuestion.options.length, (index) {
                        final optionText = currentQuestion.options[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: _buildOptionCard(
                            context: context,
                            ref: ref,
                            index: index,
                            optionText: optionText,
                            correctIndex: currentQuestion.correctAnswerIndex,
                            isAnswered: isAnswered,
                            isSelected: selectedAnswerIndex == index,
                          ),
                        );
                      }),

                      // Explanation block (revealed only after answering)
                      if (isAnswered) ...[
                        const SizedBox(height: 16),
                        AnimatedOpacity(
                          opacity: isAnswered ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 350),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF161424),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: theme.colorScheme.secondary.withOpacity(0.3),
                                width: 1.5,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.lightbulb_outline_rounded,
                                      color: theme.colorScheme.secondary,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Penjelasan Gemini',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: theme.colorScheme.secondary,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  currentQuestion.explanation,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFFE6E6FA),
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              // Bottom Control Bar
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Color(0xFF161424),
                  border: Border(
                    top: BorderSide(color: Color(0xFF2E2A47), width: 1.5),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: isAnswered
                          ? ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.primaryColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                elevation: 0,
                              ),
                              onPressed: () {
                                ref.read(quizProvider.notifier).nextQuestion();
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    questionIdx == totalQuestions - 1
                                        ? 'Lihat Hasil'
                                        : 'Soal Berikutnya',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(
                                    questionIdx == totalQuestions - 1
                                        ? Icons.analytics_rounded
                                        : Icons.arrow_forward_rounded,
                                    size: 18,
                                  ),
                                ],
                              ),
                            )
                          : OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Color(0xFF2E2A47), width: 1.5),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              onPressed: () {
                                // Skip marks as skipped and auto advances (or shows result first)
                                ref.read(quizProvider.notifier).skipQuestion();
                                ref.read(quizProvider.notifier).nextQuestion();
                              },
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Lewati Soal',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Color(0xFF94A1B2),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Icon(
                                    Icons.skip_next_rounded,
                                    color: Color(0xFF94A1B2),
                                    size: 18,
                                  ),
                                ],
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionCard({
    required BuildContext context,
    required WidgetRef ref,
    required int index,
    required String optionText,
    required int correctIndex,
    required bool isAnswered,
    required bool isSelected,
  }) {
    final theme = Theme.of(context);
    final letter = String.fromCharCode(65 + index); // A, B, C, D

    Color cardBgColor = const Color(0xFF161424);
    Color borderColor = const Color(0xFF2E2A47);
    Color letterBgColor = const Color(0xFF1C1A30);
    Color letterTextColor = const Color(0xFF94A1B2);
    Widget suffixIcon = const SizedBox.shrink();

    if (isAnswered) {
      if (index == correctIndex) {
        // Correct answer is always green
        cardBgColor = theme.colorScheme.secondary.withOpacity(0.12);
        borderColor = theme.colorScheme.secondary;
        letterBgColor = theme.colorScheme.secondary;
        letterTextColor = Colors.white;
        suffixIcon = const Icon(Icons.check_circle_rounded, color: Color(0xFF2CB67D));
      } else if (isSelected) {
        // User selected this and it was wrong
        cardBgColor = theme.colorScheme.error.withOpacity(0.12);
        borderColor = theme.colorScheme.error;
        letterBgColor = theme.colorScheme.error;
        letterTextColor = Colors.white;
        suffixIcon = const Icon(Icons.cancel_rounded, color: Color(0xFFEF4565));
      }
    } else {
      // Normal state, hover/active simulation
      if (isSelected) {
        borderColor = theme.primaryColor;
      }
    }

    return GestureDetector(
      onTap: isAnswered
          ? null
          : () {
              ref.read(quizProvider.notifier).answerQuestion(index);
            },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: cardBgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: 1.5),
        ),
        child: Row(
          children: [
            // Option letter capsule
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: letterBgColor,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  letter,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: letterTextColor,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Option text
            Expanded(
              child: Text(
                optionText,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isAnswered && index != correctIndex && !isSelected
                      ? const Color(0xFF6E6A8A)
                      : const Color(0xFFE6E6FA),
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Suffix icon
            suffixIcon,
          ],
        ),
      ),
    );
  }
}

class HintAccordion extends StatefulWidget {
  final String hintText;

  const HintAccordion({super.key, required this.hintText});

  @override
  State<HintAccordion> createState() => _HintAccordionState();
}

class _HintAccordionState extends State<HintAccordion> with SingleTickerProviderStateMixin {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF161424).withOpacity(0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isExpanded ? theme.primaryColor.withOpacity(0.4) : const Color(0xFF2E2A47),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Column(
          children: [
            InkWell(
              onTap: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: Row(
                  children: [
                    Icon(
                      Icons.help_outline_rounded,
                      size: 18,
                      color: _isExpanded ? theme.primaryColor : const Color(0xFF94A1B2),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Tampilkan Petunjuk',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFE6E6FA),
                        ),
                      ),
                    ),
                    AnimatedRotation(
                      turns: _isExpanded ? 0.5 : 0.0,
                      duration: const Duration(milliseconds: 250),
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 20,
                        color: _isExpanded ? theme.primaryColor : const Color(0xFF94A1B2),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: Padding(
                padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    widget.hintText,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF94A1B2),
                      fontStyle: FontStyle.italic,
                      height: 1.4,
                    ),
                  ),
                ),
              ),
              crossFadeState: _isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 250),
            ),
          ],
        ),
      ),
    );
  }
}
