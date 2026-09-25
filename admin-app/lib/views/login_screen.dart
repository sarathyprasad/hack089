import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/api_endpoints.dart';
import '../core/storage/storage_service.dart';

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

  void _showServerConfigDialog() {
    final urlController = TextEditingController(text: ApiEndpoints.activeBaseUrl);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardSurface,
        title: Text(
          'API Server Configuration',
          style: GoogleFonts.dmSans(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Specify backend endpoint for Android emulator or device:',
              style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: urlController,
              style: GoogleFonts.inter(color: AppColors.textPrimary),
              decoration: const InputDecoration(
                labelText: 'Base URL',
                hintText: 'http://10.0.2.2:5000/api',
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                ActionChip(
                  label: const Text('Emulator (10.0.2.2)'),
                  backgroundColor: AppColors.cardSurfaceAlt,
                  labelStyle: GoogleFonts.inter(fontSize: 11, color: AppColors.primary),
                  onPressed: () => urlController.text = 'http://10.0.2.2:5000/api',
                ),
                ActionChip(
                  label: const Text('Localhost (5000)'),
                  backgroundColor: AppColors.cardSurfaceAlt,
                  labelStyle: GoogleFonts.inter(fontSize: 11, color: AppColors.primary),
                  onPressed: () => urlController.text = 'http://localhost:5000/api',
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () async {
              final newUrl = urlController.text.trim();
              if (newUrl.isNotEmpty) {
                await StorageService.saveCustomBaseUrl(newUrl);
                if (ctx.mounted) {
                  Navigator.pop(ctx);
                }
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('API Base URL set to: $newUrl')),
                  );
                }
              }
            },
            child: const Text('Save URL'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Government / Sahakari Institutional Header
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.cardSurface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.borderDark),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withAlpha(35),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: AppColors.primary.withAlpha(100)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.shield_outlined, color: AppColors.primary, size: 14),
                                  const SizedBox(width: 5),
                                  Text(
                                    'STATUTORY PORTAL',
                                    style: GoogleFonts.dmSans(
                                      color: AppColors.primary,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.settings_outlined, color: AppColors.textSecondary, size: 20),
                              tooltip: 'Configure Backend URL',
                              onPressed: _showServerConfigDialog,
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Container(
                          width: 72,
                          height: 72,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withAlpha(60),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Image.asset(
                            'assets/images/logo-emblem.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          'सहकारी प्रबन्धन पोर्टल',
                          style: GoogleFonts.dmSans(
                            color: AppColors.primaryLight,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Prithvi Fix — Sahakari Console',
                          style: GoogleFonts.dmSans(
                            color: AppColors.textPrimary,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Apex Federation & District Registrar Regulatory Console',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Error notification if present
                  if (auth.errorMessage != null)
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.errorBg,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.error.withAlpha(120)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: AppColors.error, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              auth.errorMessage!,
                              style: GoogleFonts.inter(color: Colors.white, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Credentials Form
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Administrative Login',
                            style: GoogleFonts.dmSans(
                              color: AppColors.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            style: GoogleFonts.inter(color: AppColors.textPrimary),
                            decoration: const InputDecoration(
                              labelText: 'Official Email ID',
                              prefixIcon: Icon(Icons.email_outlined, color: AppColors.textSecondary, size: 20),
                            ),
                          ),
                          const SizedBox(height: 14),
                          TextField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            style: GoogleFonts.inter(color: AppColors.textPrimary),
                            decoration: InputDecoration(
                              labelText: 'Security Password',
                              prefixIcon: const Icon(Icons.lock_outline, color: AppColors.textSecondary, size: 20),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                  color: AppColors.textSecondary,
                                  size: 20,
                                ),
                                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                              ),
                            ),
                          ),
                                        ElevatedButton(
                            onPressed: auth.isLoading
                                ? null
                                : () async {
                                    final success = await auth.login(
                                      _emailController.text,
                                      _passwordController.text,
                                    );
                                    if (!context.mounted) return;
                                    if (success) {
                                      context.go('/');
                                    }
                                  },
                            child: auth.isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                                  )
                                : const Text('Access Sahakari Console'),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Quick Demo Personas
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.cardSurface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.borderDark),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.flash_on, color: AppColors.primary, size: 16),
                            const SizedBox(width: 6),
                            Text(
                              'Instant Demo Credentials',
                              style: GoogleFonts.dmSans(
                                color: AppColors.textPrimary,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        _PersonaButton(
                          title: 'State Apex Federation Head',
                          subtitle: 'Shri Arun Kumar Pattnaik (State Level)',
                          icon: Icons.workspace_premium_outlined,
                          accentColor: AppColors.primary,
                          onTap: () async {
                            final ok = await auth.loginAsApexHead();
                            if (!context.mounted) return;
                            if (ok) context.go('/');
                          },
                        ),
                        const SizedBox(height: 8),
                        _PersonaButton(
                          title: 'District Registrar (Khordha DCO)',
                          subtitle: 'Shri Debendra Nayak (District Level)',
                          icon: Icons.gavel_outlined,
                          accentColor: AppColors.info,
                          onTap: () async {
                            final ok = await auth.loginAsDco();
                            if (!context.mounted) return;
                            if (ok) context.go('/');
                          },
                        ),
                        const SizedBox(height: 8),
                        _PersonaButton(
                          title: 'Society Administrator',
                          subtitle: 'Bikash Mohanty (Shramik Kalyan Samiti)',
                          icon: Icons.groups_outlined,
                          accentColor: AppColors.success,
                          onTap: () async {
                            final ok = await auth.loginAsSocietyAdmin();
                            if (!context.mounted) return;
                            if (ok) context.go('/');
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PersonaButton extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
  final VoidCallback onTap;

  const _PersonaButton({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.cardSurfaceAlt,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.borderDark),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: accentColor.withAlpha(30),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: accentColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.dmSans(
                      color: AppColors.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textSecondary, size: 18),
          ],
        ),
      ),
    );
  }
}
