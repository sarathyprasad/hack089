import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/localization/language_provider.dart';
import '../../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  final String? initialRole;
  const LoginScreen({super.key, this.initialRole});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  int _selectedRoleIndex = 0;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  final _formKey = GlobalKey<FormState>();

  late AnimationController _fadeController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    if (widget.initialRole == 'worker') {
      _selectedRoleIndex = 1;
    } else if (widget.initialRole == 'admin') {
      _selectedRoleIndex = 2;
    }

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
    _fadeController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final auth = context.read<AuthProvider>();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showError('Please enter both email and password');
      return;
    }

    final success = await auth.login(email, password);
    if (!mounted) return;

    if (success) {
      final user = auth.currentUser;
      if (user?.isWorker == true) {
        context.go('/worker/dashboard');
      } else if (user?.isAdmin == true) {
        context.go('/admin/dashboard');
      } else {
        context.go('/customer/bookings');
      }
    } else {
      _showError(auth.errorMessage ?? 'Login failed. Please check credentials.');
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(fontSize: 13)),
        backgroundColor: const Color(0xFFDC2626),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  String _getRoleDescription(LanguageProvider lang) {
    switch (_selectedRoleIndex) {
      case 1:
        return lang.translate('signin_artisan_desc');
      case 2:
        return lang.translate('signin_admin_desc');
      default:
        return lang.translate('signin_citizen_desc');
    }
  }

  String get _currentRoleHint {
    switch (_selectedRoleIndex) {
      case 1:
        return 'worker@demo.local';
      case 2:
        return 'admin@demo.local';
      default:
        return 'customer@demo.local';
    }
  }

  Color get _roleColor {
    switch (_selectedRoleIndex) {
      case 1:
        return const Color(0xFFE67300);
      case 2:
        return const Color(0xFF138808);
      default:
        return AppColors.primaryNavy;
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final lang = context.watch<LanguageProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0F172A) : Colors.white;
    final cardColor = isDark ? const Color(0xFF1A2340) : const Color(0xFFF8FAFC);
    final textPrimary = isDark ? Colors.white : const Color(0xFF0F172A);
    final textSecondary = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final textMuted = isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1);
    final borderColor = isDark ? const Color(0xFF1E294B) : const Color(0xFFE2E8F0);
    final inputBg = isDark ? const Color(0xFF131B38) : Colors.white;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (context.canPop()) {
          context.pop();
        } else {
          context.go('/welcome');
        }
      },
      child: Scaffold(
        backgroundColor: bgColor,
        body: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnim,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 12),

                    // ── Top Bar ──
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Back button
                        GestureDetector(
                          onTap: () {
                            if (context.canPop()) {
                              context.pop();
                            } else {
                              context.go('/welcome');
                            }
                          },
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: cardColor,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: borderColor),
                            ),
                            child: Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: textSecondary),
                          ),
                        ),
                        // Brand chip
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF9933),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            lang.translate('odisha_network'),
                            style: GoogleFonts.outfit(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // ── Logo Emblem ──
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        width: 52,
                        height: 52,
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                          border: Border.all(color: borderColor),
                        ),
                        child: Image.asset('assets/images/logo_emblem.png', fit: BoxFit.contain),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // ── Heading ──
                    Text(
                      lang.translate('signin_welcome'),
                      style: GoogleFonts.outfit(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: Text(
                        _getRoleDescription(lang),
                        key: ValueKey(_selectedRoleIndex),
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          color: textSecondary,
                          height: 1.5,
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // ── Role Tabs ──
                    _buildRoleTabs(lang, cardColor, borderColor, textPrimary, textMuted),

                    const SizedBox(height: 24),

                    // ── Form Card ──
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: borderColor),
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Email
                            Text(
                              lang.translate('email_label'),
                              style: GoogleFonts.outfit(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: textSecondary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            _buildInput(
                              controller: _emailController,
                              hint: _currentRoleHint,
                              icon: Icons.mail_outline_rounded,
                              inputBg: inputBg,
                              borderColor: borderColor,
                              textPrimary: textPrimary,
                              textMuted: textMuted,
                              keyboardType: TextInputType.emailAddress,
                            ),

                            const SizedBox(height: 18),

                            // Password
                            Text(
                              lang.translate('password_label'),
                              style: GoogleFonts.outfit(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: textSecondary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            _buildInput(
                              controller: _passwordController,
                              hint: '••••••••',
                              icon: Icons.lock_outline_rounded,
                              inputBg: inputBg,
                              borderColor: borderColor,
                              textPrimary: textPrimary,
                              textMuted: textMuted,
                              obscure: _obscurePassword,
                              suffixIcon: GestureDetector(
                                onTap: () => setState(() => _obscurePassword = !_obscurePassword),
                                child: Icon(
                                  _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                  size: 18,
                                  color: textMuted,
                                ),
                              ),
                            ),

                            const SizedBox(height: 24),

                            // Sign In Button
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: auth.isLoading ? null : _handleLogin,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _roleColor,
                                  foregroundColor: Colors.white,
                                  disabledBackgroundColor: _roleColor.withValues(alpha: 0.5),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                child: auth.isLoading
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            lang.translate('signin_button'),
                                            style: GoogleFonts.outfit(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          const Icon(Icons.arrow_forward_rounded, size: 16),
                                        ],
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ── Demo Accounts ──
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: borderColor),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            lang.translate('demo_accounts').toUpperCase(),
                            style: GoogleFonts.outfit(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: textMuted,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              _buildDemoChip('Citizen', 'customer@demo.local', 'demo123', 0, textPrimary, textMuted, borderColor, cardColor),
                              const SizedBox(width: 8),
                              _buildDemoChip('Artisan', 'ramesh.w@demo.local', 'demo123', 1, textPrimary, textMuted, borderColor, cardColor),
                              const SizedBox(width: 8),
                              _buildDemoChip('Admin', 'admin@demo.local', 'demo123', 2, textPrimary, textMuted, borderColor, cardColor),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ── Bottom Links ──
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          lang.translate('dont_have_account'),
                          style: GoogleFonts.outfit(fontSize: 13, color: textSecondary),
                        ),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: () => context.push('/register'),
                          child: Text(
                            lang.translate('register_now'),
                            style: GoogleFonts.outfit(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: _roleColor,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    Center(
                      child: TextButton(
                        onPressed: () {
                          context.read<AuthProvider>().continueAsGuest();
                          context.go('/');
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: textMuted,
                        ),
                        child: Text(
                          lang.translate('explore_as_guest'),
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: textMuted,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleTabs(LanguageProvider lang, Color cardColor, Color borderColor, Color textPrimary, Color textMuted) {
    final roles = [
      {'idx': 0, 'icon': Icons.person_outline_rounded, 'label': lang.translate('citizen_tab')},
      {'idx': 1, 'icon': Icons.handyman_outlined, 'label': lang.translate('artisan_tab')},
      {'idx': 2, 'icon': Icons.corporate_fare_outlined, 'label': lang.translate('admin_tab')},
    ];

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: roles.map((r) {
          final idx = r['idx'] as int;
          final isSelected = _selectedRoleIndex == idx;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedRoleIndex = idx),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? _roleColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      r['icon'] as IconData,
                      size: 15,
                      color: isSelected ? Colors.white : textMuted,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      r['label'] as String,
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected ? Colors.white : textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildInput({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required Color inputBg,
    required Color borderColor,
    required Color textPrimary,
    required Color textMuted,
    bool obscure = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      style: GoogleFonts.outfit(fontSize: 14, color: textPrimary),
      cursorColor: _roleColor,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.outfit(fontSize: 13, color: textMuted),
        prefixIcon: Icon(icon, color: textMuted, size: 18),
        suffixIcon: suffixIcon != null ? Padding(padding: const EdgeInsets.only(right: 4), child: suffixIcon) : null,
        filled: true,
        fillColor: inputBg,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _roleColor, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      ),
    );
  }

  Widget _buildDemoChip(String label, String email, String pass, int idx, Color textPrimary, Color textMuted, Color borderColor, Color cardColor) {
    final isActive = _selectedRoleIndex == idx;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedRoleIndex = idx;
            _emailController.text = email;
            _passwordController.text = pass;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isActive ? _roleColor : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: isActive ? _roleColor : borderColor),
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.outfit(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isActive ? Colors.white : textMuted,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
