import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../core/localization/app_localizations.dart';
import '../providers/auth_provider.dart';
import '../core/constants/app_colors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;

  Future<void> _login() async {
    final auth = context.read<AuthProvider>();
    final ok = await auth.login(_emailCtrl.text, _passCtrl.text);
    if (ok && mounted) context.go('/dashboard');
  }

  Future<void> _demoLogin() async {
    final auth = context.read<AuthProvider>();
    final ok = await auth.demoLogin();
    if (ok && mounted) context.go('/dashboard');
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
              // Official Emblem logo
              Center(
                child: Container(
                  width: 84,
                  height: 84,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 6),
                      ),
                    ],
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.25),
                      width: 2,
                    ),
                  ),
                  child: Image.asset(
                    'assets/images/logo-emblem.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(context.tr('shramikPortal', 'Prithvi Worker Portal'), style: GoogleFonts.outfit(fontSize: 26, fontWeight: FontWeight.w700, color: AppColors.textPrimary), textAlign: TextAlign.center),
              const SizedBox(height: 6),
              Text(context.tr('portalSubHeader', 'Worker Member Terminal'), style: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary), textAlign: TextAlign.center),
              const SizedBox(height: 40),

              TextField(controller: _emailCtrl, keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(labelText: context.tr('email', 'Worker Email'), prefixIcon: const Icon(Icons.badge_outlined, color: AppColors.primary))),
              const SizedBox(height: 16),
              TextField(controller: _passCtrl, obscureText: _obscure,
                decoration: InputDecoration(labelText: context.tr('password', 'Password'), prefixIcon: const Icon(Icons.lock_outline, color: AppColors.primary),
                  suffixIcon: IconButton(icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility, color: AppColors.textMuted), onPressed: () => setState(() => _obscure = !_obscure)))),
              const SizedBox(height: 8),

              if (auth.errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(12), margin: const EdgeInsets.only(top: 8),
                  decoration: BoxDecoration(color: AppColors.errorBg, borderRadius: BorderRadius.circular(8)),
                  child: Text(auth.errorMessage!, style: const TextStyle(fontSize: 12, color: AppColors.error)),
                ),
              const SizedBox(height: 24),

              SizedBox(height: 52, child: ElevatedButton(
                onPressed: auth.isLoading ? null : _login,
                child: auth.isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : Text(context.tr('signIn', 'Sign In'), style: const TextStyle(fontSize: 16)),
              )),
              const SizedBox(height: 14),

              OutlinedButton.icon(
                onPressed: auth.isLoading ? null : _demoLogin,
                icon: const Icon(Icons.flash_on, size: 18, color: AppColors.accent),
                label: const Text('Demo Login (Worker — Ramesh)', style: TextStyle(color: AppColors.accent)),
                style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), side: const BorderSide(color: AppColors.borderDark)),
              ),
              const SizedBox(height: 32),

              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: AppColors.cardSurface, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.borderDark)),
                child: const Row(children: [
                  Icon(Icons.info_outline, size: 18, color: AppColors.textMuted),
                  SizedBox(width: 10),
                  Expanded(child: Text('Citizens and Cooperative Admins have separate dedicated apps.', style: TextStyle(fontSize: 12, color: AppColors.textMuted))),
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
