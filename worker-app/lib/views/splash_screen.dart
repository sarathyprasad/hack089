import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class WorkerSplashScreen extends StatefulWidget {
  const WorkerSplashScreen({super.key});

  @override
  State<WorkerSplashScreen> createState() => _WorkerSplashScreenState();
}

class _WorkerSplashScreenState extends State<WorkerSplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _logoController;
  late final AnimationController _contentController;
  late final AnimationController _progressController;

  late final Animation<double> _logoScale;
  late final Animation<double> _logoOpacity;
  late final Animation<double> _titleOpacity;
  late final Animation<Offset> _titleSlide;
  late final Animation<double> _taglineOpacity;
  late final Animation<Offset> _taglineSlide;
  late final Animation<double> _progressValue;

  @override
  void initState() {
    super.initState();

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _logoScale = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOutBack),
    );
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOut),
    );

    _contentController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _titleOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _contentController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );
    _titleSlide = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _contentController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );
    _taglineOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _contentController,
        curve: const Interval(0.3, 0.8, curve: Curves.easeOut),
      ),
    );
    _taglineSlide = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _contentController,
        curve: const Interval(0.3, 0.8, curve: Curves.easeOut),
      ),
    );

    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _progressValue = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
    );

    _startSequence();
  }

  Future<void> _startSequence() async {
    await Future.delayed(const Duration(milliseconds: 100));
    _logoController.forward();
    await Future.delayed(const Duration(milliseconds: 350));
    _contentController.forward();
    await Future.delayed(const Duration(milliseconds: 250));
    _progressController.forward();
    await Future.delayed(const Duration(milliseconds: 1000));
    if (mounted) {
      context.go('/dashboard');
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _contentController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF059669), Color(0xFF047857), Color(0xFF065F46)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 3),

                // Logo
                AnimatedBuilder(
                  animation: _logoController,
                  builder: (context, child) => Opacity(
                    opacity: _logoOpacity.value,
                    child: Transform.scale(
                      scale: _logoScale.value,
                      child: child,
                    ),
                  ),
                  child: Container(
                    width: 96,
                    height: 96,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Image.asset(
                      'assets/images/logo-emblem.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Title
                AnimatedBuilder(
                  animation: _contentController,
                  builder: (context, child) => SlideTransition(
                    position: _titleSlide,
                    child: Opacity(
                      opacity: _titleOpacity.value,
                      child: child,
                    ),
                  ),
                  child: Text(
                    'Prithvi Fix',
                    style: GoogleFonts.outfit(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // Tagline
                AnimatedBuilder(
                  animation: _contentController,
                  builder: (context, child) => SlideTransition(
                    position: _taglineSlide,
                    child: Opacity(
                      opacity: _taglineOpacity.value,
                      child: child,
                    ),
                  ),
                  child: Text(
                    'Shramik Artisan Portal',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withValues(alpha: 0.8),
                      letterSpacing: 0.3,
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // Progress bar
                AnimatedBuilder(
                  animation: _progressController,
                  builder: (context, child) => Opacity(
                    opacity: _progressValue.value.clamp(0.0, 1.0),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 80),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: _progressValue.value,
                          minHeight: 3,
                          backgroundColor: Colors.white.withValues(alpha: 0.15),
                          valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                    ),
                  ),
                ),

                const Spacer(flex: 4),

                // Bottom branding
                AnimatedBuilder(
                  animation: _contentController,
                  builder: (context, child) => Opacity(
                    opacity: _taglineOpacity.value * 0.6,
                    child: child,
                  ),
                  child: Text(
                    '93% Direct Wage • Zero Surge',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: Colors.white.withValues(alpha: 0.5),
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
