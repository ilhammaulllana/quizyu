import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'providers/quiz_notifier.dart';
import 'views/home_screen.dart';
import 'views/quiz_screen.dart';
import 'views/dashboard_screen.dart';

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
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0B0A12), // Deep cosmic black
        primaryColor: const Color(0xFF7F5AF0), // Electric Purple
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF7F5AF0),
          secondary: Color(0xFF2CB67D), // Neon Emerald Green
          error: Color(0xFFEF4565), // Vibrant Rosy Red
          background: Color(0xFF0B0A12),
          surface: Color(0xFF161424), // Rich Dark Indigo-Gray
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onBackground: Color(0xFFE6E6FA), // Lavender White
          onSurface: Color(0xFFE6E6FA),
        ),
        textTheme: GoogleFonts.outfitTextTheme(
          ThemeData.dark().textTheme.apply(
                bodyColor: const Color(0xFFE6E6FA),
                displayColor: Colors.white,
              ),
        ),
        cardTheme: CardThemeData(
          color: const Color(0xFF161424),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFF2E2A47), width: 1.5),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF1C1A30),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFF2E2A47), width: 1.5),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFF2E2A47), width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFF7F5AF0), width: 2),
          ),
          labelStyle: const TextStyle(color: Color(0xFF94A1B2)),
          hintStyle: const TextStyle(color: Color(0xFF6E6A8A)),
        ),
        useMaterial3: true,
      ),
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

class GorgeousLoadingScreen extends StatefulWidget {
  const GorgeousLoadingScreen({super.key});

  @override
  State<GorgeousLoadingScreen> createState() => _GorgeousLoadingScreenState();
}

class _GorgeousLoadingScreenState extends State<GorgeousLoadingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int _messageIndex = 0;
  final List<String> _loadingMessages = [
    'Membangun koneksi dengan Gemini...',
    'Menganalisis topik Anda...',
    'Merakit System Prompt kuis...',
    'Membuat set pertanyaan interaktif...',
    'Menyusun petunjuk & pembahasan...',
    'Hampir selesai, memformat jawaban...'
  ];
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _timer = Timer.periodic(const Duration(milliseconds: 1800), (timer) {
      if (mounted) {
        setState(() {
          _messageIndex = (_messageIndex + 1) % _loadingMessages.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF09080F),
              Color(0xFF131124),
              Color(0xFF09080F),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Outer rotating neon glow
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _controller.value * 2.0 * 3.14159,
                    child: Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: SweepGradient(
                          colors: [
                            theme.primaryColor,
                            theme.colorScheme.secondary,
                            theme.primaryColor.withOpacity(0.1),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: theme.primaryColor.withOpacity(0.4),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Color(0xFF0B0A12),
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.auto_awesome,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 40),
              // Glowing main loading text
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Color(0xFFA78BFA), Color(0xFFF472B6)],
                ).createShader(bounds),
                child: const Text(
                  'Memproses Kuis AI',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Animated cycling message
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) => FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: animation.drive(
                      Tween<Offset>(
                        begin: const Offset(0, 0.2),
                        end: Offset.zero,
                      ),
                    ),
                    child: child,
                  ),
                ),
                child: Text(
                  _loadingMessages[_messageIndex],
                  key: ValueKey<int>(_messageIndex),
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xFF94A1B2),
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 32),
              // Small loading dot indicators
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (index) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: theme.primaryColor.withOpacity(0.5 + (index * 0.25)),
                      shape: BoxShape.circle,
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
