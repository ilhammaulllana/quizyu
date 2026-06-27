import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/quiz_notifier.dart';
import '../providers/settings_notifier.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _submitQuery(String query) {
    if (query.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.white),
              SizedBox(width: 12),
              Expanded(
                child: Text('Harap masukkan topik kuis terlebih dahulu!'),
              ),
            ],
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }

    final settings = ref.read(settingsProvider);

    // Parse potential question count from prompt, e.g., "Tata surya 5 soal"
    int count = settings.questionCount;
    final match = RegExp(
      r'(\d+)\s*(?:soal|pertanyaan|items?)',
      caseSensitive: false,
    ).firstMatch(query);
    if (match != null) {
      final parsed = int.tryParse(match.group(1) ?? '');
      if (parsed != null && parsed > 0 && parsed <= 30) {
        count = parsed;
      }
    }

    ref
        .read(quizProvider.notifier)
        .startQuiz(
          topic: query,
          count: count,
          difficulty: settings.difficulty,
          modelVersion: settings.modelVersion,
        );
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final theme = Theme.of(context);

    // Listen for error changes in quizState and show snackbar
    ref.listen<AsyncValue>(quizProvider, (previous, next) {
      next.whenOrNull(
        error: (error, stackTrace) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error_outline_rounded, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      error.toString(),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              backgroundColor: theme.colorScheme.error,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.all(16),
              action: SnackBarAction(
                label: 'Coba Lagi',
                textColor: Colors.white,
                onPressed: () {
                  _focusNode.requestFocus();
                },
              ),
            ),
          );
        },
      );
    });

    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        constraints: const BoxConstraints.expand(),
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.0,
            colors: [
              Color(0xFFEBF5FF), // Subtle blue in the center
              Colors.white, // Pure white at the edges
            ],
            stops: [0.0, 0.8],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24.0,
                        vertical: 20.0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Top header: logo icon (top-left) and name (top-right)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Logo Icon on the left
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: theme.primaryColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: theme.primaryColor.withValues(alpha: 0.2),
                                    width: 1.5,
                                  ),
                                ),
                                child: Icon(
                                  Icons.auto_awesome,
                                  color: theme.primaryColor,
                                  size: 20,
                                ),
                              ),
                              // Logo Name on the right
                              ShaderMask(
                                shaderCallback: (bounds) =>
                                    const LinearGradient(
                                      colors: [
                                        Color(0xFF7F5AF0),
                                        Color(0xFF9061F9),
                                      ],
                                    ).createShader(bounds),
                                child: const Text(
                                  'quizyu',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          // Centered Content
                          Expanded(
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Glowing blue gradient orb behind the objects
                                Container(
                                  width: 360,
                                  height: 360,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: RadialGradient(
                                      colors: [
                                        const Color(0xFF60A5FA).withValues(
                                          alpha: 0.24,
                                        ), // Soft blue center glow
                                        const Color(
                                          0xFF93C5FD,
                                        ).withValues(alpha: 0.06),
                                        Colors.transparent,
                                      ],
                                      stops: const [0.0, 0.5, 1.0],
                                    ),
                                  ),
                                ),
                                // Main elements Column
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    // Header main greeting text
                                    const Text(
                                      'Sebaiknya kita mulai dari mana?',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                        color: Color(
                                          0xFF0F172A,
                                        ), // Dark slate gray for readability
                                        letterSpacing: -0.5,
                                        height: 1.2,
                                      ),
                                    ),
                                    const SizedBox(height: 48),

                                    // Premium search bar container
                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withValues(
                                              alpha: 0.04,
                                            ),
                                            blurRadius: 20,
                                            offset: const Offset(0, 8),
                                          ),
                                        ],
                                      ),
                                      child: TextField(
                                        controller: _searchController,
                                        focusNode: _focusNode,
                                        onSubmitted: _submitQuery,
                                        textInputAction: TextInputAction.search,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xFF0F172A),
                                        ),
                                        decoration: InputDecoration(
                                          hintText:
                                              'Minta Gemini... (e.g. "Kopi Nusantara", "Tata Surya")',
                                          hintStyle: const TextStyle(
                                            color: Color(0xFF94A1B2),
                                          ),
                                          fillColor: Colors.white,
                                          filled: true,
                                          prefixIcon: const Icon(
                                            Icons.search_rounded,
                                            color: Color(0xFF7F5AF0),
                                            size: 24,
                                          ),
                                          suffixIcon: IconButton(
                                            icon: Container(
                                              padding: const EdgeInsets.all(6),
                                              decoration: BoxDecoration(
                                                color: theme.primaryColor,
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(
                                                Icons.arrow_forward_rounded,
                                                color: Colors.white,
                                                size: 18,
                                              ),
                                            ),
                                            onPressed: () => _submitQuery(
                                              _searchController.text,
                                            ),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                            borderSide: const BorderSide(
                                              color: Color(0xFFE2E8F0),
                                              width: 1.5,
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                            borderSide: const BorderSide(
                                              color: Color(0xFF7F5AF0),
                                              width: 2,
                                            ),
                                          ),
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                horizontal: 20,
                                                vertical: 18,
                                              ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 24),

                                    // Dropdown model switcher (Standard vs Pro pills)
                                    Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: const Color(
                                          0xFFF1F5F9,
                                        ), // Light grey panel
                                        borderRadius: BorderRadius.circular(14),
                                        border: Border.all(
                                          color: const Color(0xFFE2E8F0),
                                          width: 1,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          _buildModelPill(
                                            label: 'Gemini Standard',
                                            isSelected:
                                                settings.modelVersion ==
                                                'Standard',
                                            icon: Icons.flash_on_rounded,
                                            activeColor: const Color(
                                              0xFF3B82F6,
                                            ),
                                            onTap: () {
                                              ref
                                                  .read(
                                                    settingsProvider.notifier,
                                                  )
                                                  .setModelVersion('Standard');
                                            },
                                          ),
                                          const SizedBox(width: 4),
                                          _buildModelPill(
                                            label: 'Gemini Pro',
                                            isSelected:
                                                settings.modelVersion == 'Pro',
                                            icon: Icons.stars_rounded,
                                            activeColor: const Color(
                                              0xFF8B5CF6,
                                            ),
                                            onTap: () {
                                              ref
                                                  .read(
                                                    settingsProvider.notifier,
                                                  )
                                                  .setModelVersion('Pro');
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // Spacer to balance the top logo header height so the content is perfectly centered
                          const SizedBox(height: 48),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildModelPill({
    required String label,
    required bool isSelected,
    required IconData icon,
    required Color activeColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? activeColor : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: activeColor.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : const Color(0xFF64748B),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Colors.white : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
