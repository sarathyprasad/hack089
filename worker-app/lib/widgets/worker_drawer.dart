import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../core/storage/storage_service.dart';
import '../core/localization/app_localizations.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/locale_provider.dart';
import '../views/sos_beacon_sheet.dart';

class WorkerDrawer extends StatelessWidget {
  const WorkerDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = auth.currentUser;
    final userName = user?.name ?? 'Subhransu Nayak';
    final userPhone = user?.phone ?? '+91 98612 34567';

    return Drawer(
      backgroundColor: AppColors.bg(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Header with Deep Navy gradient
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 24,
              bottom: 20,
              left: 20,
              right: 20,
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
              ),
              borderRadius: BorderRadius.only(topRight: Radius.circular(24)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: Image.asset(
                              'assets/images/logo-emblem.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: AppColors.primary,
                          child: Text(
                            userName.isNotEmpty ? userName[0].toUpperCase() : 'S',
                            style: GoogleFonts.outfit(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.cardSurfaceAlt,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.accent),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.shield, color: AppColors.accent, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            'OD-SHR-2026-089',
                            style: GoogleFonts.outfit(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppColors.accent,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  userName,
                  style: GoogleFonts.outfit(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  userPhone,
                  style: GoogleFonts.inter(fontSize: 11.5, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.available,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Master Electrician • Khordha Central',
                      style: GoogleFonts.inter(fontSize: 11, color: AppColors.available, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Drawer Navigation Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
              children: [
                _DrawerItem(
                  icon: Icons.person_outline,
                  title: context.tr('myProfileBadges', 'My Profile & Badges'),
                  subtitle: context.tr('myProfileBadgesSub', 'KYC, society affiliation, ratings'),
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/profile');
                  },
                ),
                const SizedBox(height: 4),
                _DrawerItem(
                  icon: Icons.account_balance_wallet_outlined,
                  title: context.tr('walletCashout', 'Wallet & Instant Cashout'),
                  subtitle: context.tr('walletCashoutSub', '0% fee IMPS / UPI withdrawals'),
                  badgeText: '₹3,840',
                  badgeColor: AppColors.success,
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/wallet');
                  },
                ),
                const SizedBox(height: 4),
                _DrawerItem(
                  icon: Icons.whatshot_outlined,
                  title: context.tr('demandSurge', 'Demand Surge Heatmap'),
                  subtitle: context.tr('demandSurgeSub', 'Live zones with up to +20% bonus'),
                  badgeText: '+20% Rush',
                  badgeColor: AppColors.warning,
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/heatmap');
                  },
                ),
                const SizedBox(height: 4),
                _DrawerItem(
                  icon: Icons.school_outlined,
                  title: context.tr('skillsCertification', 'NCCT Skills Upgrade'),
                  subtitle: context.tr('skillsCertificationSub', 'Govt certifications & ₹5K stipend'),
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/skills');
                  },
                ),
                const SizedBox(height: 4),
                _DrawerItem(
                  icon: Icons.health_and_safety_outlined,
                  title: context.tr('welfareCentre', 'Welfare & ESIC Center'),
                  subtitle: context.tr('welfareCentreSub', 'Social security & medical claims'),
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/welfare');
                  },
                ),
                const Divider(height: 24, color: AppColors.borderDark),
                _DrawerItem(
                  icon: Icons.emergency_share,
                  title: context.tr('emergencySosBeacon', 'Safety SOS Panic Beacon'),
                  subtitle: context.tr('emergencySosSub', 'Instant GPS distress to Police 112'),
                  iconColor: AppColors.error,
                  textColor: AppColors.error,
                  onTap: () {
                    Navigator.pop(context);
                    SosBeaconSheet.show(context);
                  },
                ),
                const SizedBox(height: 4),
                _DrawerItem(
                  icon: Icons.support_agent_outlined,
                  title: context.tr('help', 'Shramik Helpdesk'),
                  subtitle: context.tr('tollFreeLabel', '24/7 Co-op Secretary helpline'),
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Dialing Shramik Helpline: 1800-345-HELP...')),
                    );
                  },
                ),
                const Divider(height: 24, color: AppColors.borderDark),

                // Language Switcher
                _DrawerItem(
                  icon: Icons.translate_rounded,
                  title: context.tr('language', 'Language / ଭାଷା'),
                  subtitle: 'Current: ${context.watch<LocaleProvider>().currentLanguageName}',
                  badgeText: context.watch<LocaleProvider>().currentLanguageCode.toUpperCase(),
                  badgeColor: AppColors.primary,
                  onTap: () {
                    Navigator.pop(context);
                    showLanguageDialog(context);
                  },
                ),

                const SizedBox(height: 4),

                // Theme Mode Switcher
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkCardSurface : AppColors.lightCardSurface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: (isDark ? AppColors.accentLight : AppColors.primary).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          themeProvider.isDarkMode ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
                          color: isDark ? AppColors.accentLight : AppColors.primary,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              themeProvider.isDarkMode ? 'Dark Mode' : 'Light Mode',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                              ),
                            ),
                            Text(
                              themeProvider.isDarkMode ? 'Operational Terminal' : 'Daylight Clarity',
                              style: GoogleFonts.inter(
                                fontSize: 10.5,
                                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch.adaptive(
                        value: themeProvider.isDarkMode,
                        activeThumbColor: AppColors.accent,
                        activeTrackColor: AppColors.accent.withValues(alpha: 0.4),
                        onChanged: (val) {
                          themeProvider.setThemeMode(val ? ThemeMode.dark : ThemeMode.light);
                        },
                      ),
                    ],
                  ),
                ),
                const Divider(height: 24, color: AppColors.borderDark),
                _DrawerItem(
                  icon: Icons.logout,
                  title: context.tr('logout', 'Log Out'),
                  subtitle: context.tr('signOutBtn', 'Sign out of Shramik Terminal'),
                  iconColor: AppColors.textMuted,
                  textColor: AppColors.textMuted,
                  onTap: () async {
                    Navigator.pop(context);
                    await auth.logout();
                    if (context.mounted) {
                      context.go('/login');
                    }
                  },
                ),
              ],
            ),
          ),

          // Footer with Server Connection Switcher
          InkWell(
            onTap: () {
              final controller = TextEditingController(text: StorageService.getServerUrl());
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  backgroundColor: isDark ? AppColors.darkCardSurface : AppColors.lightCardSurface,
                  title: Row(
                    children: [
                      const Icon(Icons.dns_rounded, color: AppColors.accent, size: 20),
                      const SizedBox(width: 8),
                      Text('Server Connection', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Set backend IP address to connect Shramik app over Wi-Fi:',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: controller,
                        decoration: InputDecoration(
                          labelText: 'API Base URL',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => controller.text = 'http://192.168.5.37:5000/api',
                              style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 8)),
                              child: const Text('Wi-Fi LAN', style: TextStyle(fontSize: 11)),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => controller.text = 'http://10.0.2.2:5000/api',
                              style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 8)),
                              child: const Text('Emulator', style: TextStyle(fontSize: 11)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        final val = controller.text.trim();
                        if (val.isNotEmpty) {
                          await StorageService.saveServerUrl(val);
                          if (ctx.mounted) {
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Server connected to $val')),
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent),
                      child: const Text('Save & Apply', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCardSurface : AppColors.lightCardSurface,
                border: Border(top: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder)),
              ),
              child: Row(
                children: [
                  Image.asset('assets/images/logo-emblem.png', width: 22, height: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      context.tr('fairWageFooter', 'Prithvi Fix Shramik v2.4.0 • 93% Fair Wage'),
                      style: GoogleFonts.outfit(
                        fontSize: 10,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                    ),
                  ),
                  const Icon(Icons.settings_ethernet, size: 16, color: AppColors.accent),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? textColor;
  final String? badgeText;
  final Color? badgeColor;

  const _DrawerItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.iconColor,
    this.textColor,
    this.badgeText,
    this.badgeColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (iconColor ?? AppColors.primary).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: iconColor ?? AppColors.primary, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          title,
                          style: GoogleFonts.outfit(
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                            color: textColor ?? (isDark ? Colors.white : AppColors.lightTextPrimary),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (badgeText != null) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: (badgeColor ?? AppColors.primary).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: badgeColor ?? AppColors.primary),
                          ),
                          child: Text(
                            badgeText!,
                            style: GoogleFonts.outfit(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: badgeColor ?? AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 10.5,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textMuted, size: 16),
          ],
        ),
      ),
    );
  }
}
