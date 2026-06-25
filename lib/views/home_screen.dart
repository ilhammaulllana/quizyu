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
              Expanded(child: Text('Harap masukkan topik kuis terlebih dahulu!')),
            ],
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }

    final settings = ref.read(settingsProvider);
    
    // Parse potential question count from prompt, e.g., "Tata surya 5 soal"
    int count = settings.questionCount;
    final match = RegExp(r'(\d+)\s*(?:soal|pertanyaan|items?)', caseSensitive: false).firstMatch(query);
    if (match != null) {
      final parsed = int.tryParse(match.group(1) ?? '');
      if (parsed != null && parsed > 0 && parsed <= 30) {
        count = parsed;
      }
    }

    ref.read(quizProvider.notifier).startQuiz(
          topic: query,
          count: count,
          difficulty: settings.difficulty,
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
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                // Glowing branding logo
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: theme.primaryColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: theme.primaryColor.withOpacity(0.3),
                          width: 1.5,
                        ),
                      ),
                      child: const Icon(
                        Icons.auto_awesome,
                        color: Color(0xFFA78BFA),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [Color(0xFF9061F9), Color(0xFFF472B6)],
                      ).createShader(bounds),
                      child: const Text(
                        'quizyu',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 60),
                // Header main greeting text
                const Text(
                  'Sebaiknya kita mulai dari mana?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Ketik topik belajar apa saja. Gemini akan langsung membuatkan kuis, evaluasi, dan panduan belajar untuk Anda.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: Color(0xFF94A1B2),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 48),
                // Premium search bar container
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: theme.primaryColor.withOpacity(0.08),
                        blurRadius: 24,
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
                    ),
                    decoration: InputDecoration(
                      hintText: 'Minta Gemini... (e.g. "Kopi Nusantara", "Tata Surya")',
                      prefixIcon: const Icon(
                        Icons.search_rounded,
                        color: Color(0xFFA78BFA),
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
                        onPressed: () => _submitQuery(_searchController.text),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
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
                    color: const Color(0xFF161424),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF2E2A47),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildModelPill(
                        label: 'Gemini Standard',
                        isSelected: settings.modelVersion == 'Standard',
                        icon: Icons.flash_on_rounded,
                        activeColor: const Color(0xFF3B82F6),
                        onTap: () {
                          ref.read(settingsProvider.notifier).setModelVersion('Standard');
                        },
                      ),
                      _buildModelPill(
                        label: 'Gemini Pro',
                        isSelected: settings.modelVersion == 'Pro',
                        icon: Icons.stars_rounded,
                        activeColor: const Color(0xFF8B5CF6),
                        onTap: () {
                          ref.read(settingsProvider.notifier).setModelVersion('Pro');
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 60),
                // Suggestion chips
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '💡 Topik Populer',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF94A1B2),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  alignment: WrapAlignment.start,
                  children: [
                    _buildSuggestionChip('Flutter Development'),
                    _buildSuggestionChip('Tata Surya'),
                    _buildSuggestionChip('Kopi Nusantara'),
                    _buildSuggestionChip('Sejarah Kemerdekaan RI'),
                    _buildSuggestionChip('Struktur Sel Biologi'),
                  ],
                ),
              ],
            ),
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
          color: isSelected ? activeColor.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? activeColor.withOpacity(0.4) : Colors.transparent,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? activeColor : const Color(0xFF6E6A8A),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Colors.white : const Color(0xFF94A1B2),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionChip(String topic) {
    return ActionChip(
      label: Text(topic),
      avatar: const Icon(Icons.trending_up_rounded, size: 14, color: Color(0xFFA78BFA)),
      backgroundColor: const Color(0xFF161424),
      side: const BorderSide(color: Color(0xFF2E2A47), width: 1),
      labelStyle: const TextStyle(
        color: Color(0xFFE6E6FA),
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onPressed: () {
        _searchController.text = topic;
        _submitQuery(topic);
      },
    );
  }
}
