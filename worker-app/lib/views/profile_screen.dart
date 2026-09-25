import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../core/constants/app_colors.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        if (context.canPop()) {
          context.pop();
        } else {
          context.go('/dashboard');
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.bg(context),
        appBar: AppBar(
          title: Text(
            'My Profile',
            style: GoogleFonts.outfit(
              color: AppColors.text(context),
              fontWeight: FontWeight.bold,
            ),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back_rounded, color: AppColors.text(context)),
            tooltip: 'Back',
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/dashboard');
              }
            },
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar & Identity Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface(context),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border(context)),
                  boxShadow: isDark
                      ? null
                      : [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 38,
                      backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                      child: Text(
                        (user?.name ?? 'W')[0].toUpperCase(),
                        style: GoogleFonts.outfit(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      user?.name ?? 'Artisan Member',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.text(context),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user?.email ?? '',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.textSec(context),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.verified_rounded, size: 14, color: AppColors.primary),
                          const SizedBox(width: 4),
                          Text(
                            'Verified Shramik Artisan',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Membership Details
              Text(
                'MEMBERSHIP DETAILS',
                style: GoogleFonts.outfit(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textSec(context),
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              _ProfileRow(icon: Icons.phone_outlined, label: 'Phone', value: user?.phone ?? '—'),
              _ProfileRow(icon: Icons.location_on_outlined, label: 'District', value: user?.district ?? '—'),
              _ProfileRow(icon: Icons.business_outlined, label: 'Cooperative', value: user?.cooperativeName ?? 'Odisha Artisan Federation'),
              _ProfileRow(icon: Icons.badge_outlined, label: 'Artisan ID', value: 'OD-SHR-2026-089'),

              const SizedBox(height: 24),

              // Appearance & Display Theme Setting
              Text(
                'APPEARANCE & THEME SETTING',
                style: GoogleFonts.outfit(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textSec(context),
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface(context),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border(context)),
                ),
                child: Column(
                  children: [
                    _ThemeOptionTile(
                      title: 'Dark Mode',
                      subtitle: 'Operational slate terminal • Low glare',
                      icon: Icons.dark_mode_outlined,
                      isSelected: themeProvider.themeMode == ThemeMode.dark,
                      onTap: () => themeProvider.setThemeMode(ThemeMode.dark),
                    ),
                    Divider(height: 1, color: AppColors.border(context)),
                    _ThemeOptionTile(
                      title: 'Light Mode',
                      subtitle: 'High sunlight clarity • Clean white theme',
                      icon: Icons.light_mode_outlined,
                      isSelected: themeProvider.themeMode == ThemeMode.light,
                      onTap: () => themeProvider.setThemeMode(ThemeMode.light),
                    ),
                    Divider(height: 1, color: AppColors.border(context)),
                    _ThemeOptionTile(
                      title: 'System Default',
                      subtitle: 'Matches device system theme automatically',
                      icon: Icons.settings_brightness_outlined,
                      isSelected: themeProvider.themeMode == ThemeMode.system,
                      onTap: () => themeProvider.setThemeMode(ThemeMode.system),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Statutory Wage Architecture Banner
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.shield_outlined, color: AppColors.primary, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '93-2-5 Wage Protection Active',
                            style: GoogleFonts.inter(
                              fontSize: 12.5,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '93% direct wage payout to your wallet on OTP completion with zero hidden commissions.',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: AppColors.textSec(context),
                              height: 1.25,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _ThemeOptionTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeOptionTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.15)
                    : AppColors.surfaceAlt(context),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: isSelected ? AppColors.primary : AppColors.muted(context),
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 13.5,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      color: AppColors.text(context),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: AppColors.textSec(context),
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 20)
            else
              Icon(Icons.radio_button_unchecked, color: AppColors.muted(context), size: 18),
          ],
        ),
      ),
    );
  }
}

class _ProfileRow extends StatelessWidget {
  final IconData icon;
  final String label, value;

  const _ProfileRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.muted(context)),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSec(context),
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.text(context),
            ),
          ),
        ],
      ),
    );
  }
}
