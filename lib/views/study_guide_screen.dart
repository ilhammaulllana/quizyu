import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/quiz_notifier.dart';
import '../providers/study_guide_notifier.dart';

class StudyGuideScreen extends ConsumerWidget {
  const StudyGuideScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final guideState = ref.watch(studyGuideProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF0F172A)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Analisis Performa AI',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F172A),
          ),
        ),
      ),
      body: SafeArea(
        child: guideState.when(
          data: (markdownText) {
            if (markdownText == null || markdownText.isEmpty) {
              return const Center(
                child: Text(
                  'Tidak ada panduan belajar yang tersedia.',
                  style: TextStyle(color: Color(0xFF64748B)),
                ),
              );
            }

            return Column(
              children: [
                Expanded(
                  child: Markdown(
                    data: markdownText,
                    padding: const EdgeInsets.all(20.0),
                    selectable: true,
                    styleSheet: MarkdownStyleSheet(
                      p: const TextStyle(
                        fontSize: 15,
                        height: 1.5,
                        color: Color(0xFF1E293B),
                      ),
                      h1: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: theme.primaryColor,
                        height: 1.4,
                      ),
                      h2: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                        height: 1.4,
                      ),
                      h3: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF7F5AF0),
                        height: 1.4,
                      ),
                      listBullet: const TextStyle(
                        fontSize: 15,
                        color: Color(0xFF7F5AF0),
                      ),
                      blockquoteDecoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(12),
                        border: Border(
                          left: BorderSide(
                            color: theme.primaryColor,
                            width: 4,
                          ),
                        ),
                      ),
                      blockquotePadding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 12.0,
                      ),
                      blockquote: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF475569),
                        height: 1.4,
                        fontStyle: FontStyle.italic,
                      ),
                      code: const TextStyle(
                        color: Color(0xFFBE185D),
                        backgroundColor: Color(0xFFF1F5F9),
                        fontFamily: 'monospace',
                        fontSize: 13,
                      ),
                      codeblockDecoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFE2E8F0),
                          width: 1,
                        ),
                      ),
                      horizontalRuleDecoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(
                            color: const Color(0xFFE2E8F0),
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text(
                        'Selesai Membaca',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
          loading: () => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  width: 48,
                  height: 48,
                  child: CircularProgressIndicator(strokeWidth: 4),
                ),
                const SizedBox(height: 24),
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [Color(0xFF7F5AF0), Color(0xFF9061F9)],
                  ).createShader(bounds),
                  child: const Text(
                    'Menyusun Analisis Performa...',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Gemini sedang menganalisis kelemahan jawaban Anda.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          error: (error, stack) {
            final rawMsg = error.toString().replaceAll('Exception: ', '');
            final isOffline = rawMsg.contains('[OFFLINE]') ||
                rawMsg.toLowerCase().contains('tidak ada koneksi') ||
                rawMsg.toLowerCase().contains('periksa jaringan');
            final isQuota = rawMsg.contains('[QUOTA_EXCEEDED]') ||
                rawMsg.toLowerCase().contains('rate limit') ||
                rawMsg.toLowerCase().contains('429') ||
                rawMsg.toLowerCase().contains('kuota');

            final displayMsg = rawMsg
                .replaceAll('[OFFLINE] ', '')
                .replaceAll('[QUOTA_EXCEEDED] ', '')
                .replaceAll('[SYSTEM_ERROR] ', '');

            if (isOffline) {
              debugPrint('🌐 [LOG TIDAK ADA KONEKSI INTERNET] $displayMsg');
            } else if (isQuota) {
              debugPrint('⏳ [LOG BATAS KUOTA AI GEMINI TERLAMPAUI] $displayMsg');
            } else {
              debugPrint('❌ [LOG KESALAHAN SISTEM] $displayMsg');
            }

            final IconData iconData = isOffline
                ? Icons.wifi_off_rounded
                : isQuota
                    ? Icons.hourglass_top_rounded
                    : Icons.error_outline_rounded;

            final Color accentColor = isOffline
                ? const Color(0xFFD97706)
                : isQuota
                    ? const Color(0xFF7F5AF0)
                    : theme.colorScheme.error;

            final String titleText = isOffline
                ? 'Koneksi Internet Terputus'
                : isQuota
                    ? 'Batas Kuota Gratis AI Gemini Terlampaui'
                    : 'Gagal Memuat Analisis';

            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      iconData,
                      color: accentColor,
                      size: 56,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      titleText,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: accentColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      displayMsg,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF64748B),
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        final session = ref.read(quizProvider).value;
                        if (session != null) {
                          ref.read(studyGuideProvider.notifier).generateGuide(session);
                        }
                      },
                      icon: const Icon(Icons.refresh_rounded, size: 18),
                      label: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
