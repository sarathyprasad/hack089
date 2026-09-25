import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../core/constants/app_colors.dart';
import '../widgets/animated_entrance.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final auth = context.read<AuthProvider>();
    final success = await auth.login(_emailController.text, _passwordController.text);
    if (success && mounted) {
      context.go('/home');
    }
  }

  Future<void> _handleDemoLogin() async {
    final auth = context.read<AuthProvider>();
    final success = await auth.demoLogin();
    if (success && mounted) {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 60),

              // Logo & Welcome
              AnimatedListItem(
                index: 0,
                delay: const Duration(milliseconds: 80),
                child: Center(
                  child: Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColors.borderLight, width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.12),
                          blurRadius: 18,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Image.asset(
                      'assets/images/logo-emblem.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              AnimatedListItem(
                index: 1,
                delay: const Duration(milliseconds: 80),
                child: Text(
                  'Welcome, Citizen',
                  style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 8),
              AnimatedListItem(
                index: 2,
                delay: const Duration(milliseconds: 80),
                child: Text(
                  'Sign in to book verified home services from your local cooperative',
                  style: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 40),

              // Email
              AnimatedListItem(
                index: 3,
                delay: const Duration(milliseconds: 80),
                child: TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email Address',
                    prefixIcon: Icon(Icons.email_outlined, color: AppColors.primary),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Password
              AnimatedListItem(
                index: 4,
                delay: const Duration(milliseconds: 80),
                child: TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outline, color: AppColors.primary),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: AppColors.textMuted),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Error
              if (auth.errorMessage != null)
                AnimatedListItem(
                  index: 0,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.errorBg,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, size: 18, color: AppColors.error),
                        const SizedBox(width: 8),
                        Expanded(child: Text(auth.errorMessage!, style: const TextStyle(fontSize: 12, color: AppColors.error))),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 24),

              // Login Button
              AnimatedListItem(
                index: 5,
                delay: const Duration(milliseconds: 80),
                child: SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: auth.isLoading ? null : _handleLogin,
                    child: auth.isLoading
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text('Sign In', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Demo Login
              AnimatedListItem(
                index: 6,
                delay: const Duration(milliseconds: 80),
                child: OutlinedButton.icon(
                  onPressed: auth.isLoading ? null : _handleDemoLogin,
                  icon: const Icon(Icons.flash_on, size: 18),
                  label: const Text('Quick Demo Login (Citizen)'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: BorderSide(color: AppColors.accent.withValues(alpha: 0.5)),
                    foregroundColor: AppColors.accent,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Register
              AnimatedListItem(
                index: 7,
                delay: const Duration(milliseconds: 80),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account? ", style: TextStyle(color: AppColors.textSecondary)),
                    GestureDetector(
                      onTap: () => context.go('/register'),
                      child: Text('Register', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Cross-app hint
              AnimatedListItem(
                index: 8,
                delay: const Duration(milliseconds: 80),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, size: 18, color: AppColors.textMuted),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Workers and Cooperative Admins have separate dedicated apps.',
                          style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
