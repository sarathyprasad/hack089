import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../core/storage/storage_service.dart';
import '../providers/auth_provider.dart';
import '../providers/locale_provider.dart';
import '../core/localization/app_localizations.dart';
import '../views/ai_assistant_dialog.dart';

class CitizenDrawer extends StatelessWidget {
  const CitizenDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.user;
    final isLoggedIn = auth.isAuthenticated;

    final userName = user?.name.isNotEmpty == true ? user!.name : (isLoggedIn ? 'Citizen User' : 'Namaste, Guest');
    final userPhone = user?.phone ?? (isLoggedIn ? '+91 94370 12345' : 'Sign in to access bookings & rewards');

    return Drawer(
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Header with Gradient & User Profile Card
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
                colors: [Color(0xFF0284C7), Color(0xFF0369A1), Color(0xFF075985)],
              ),
              borderRadius: BorderRadius.only(topRight: Radius.circular(24)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.white,
                      child: CircleAvatar(
                        radius: 25,
                        backgroundColor: AppColors.primaryLight.withValues(alpha: 0.3),
                        child: Text(
                          userName.isNotEmpty ? userName[0].toUpperCase() : 'C',
                          style: GoogleFonts.outfit(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryDark,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            'assets/images/logo-emblem.png',
                            width: 22,
                            height: 22,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Prithvi Fix',
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
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
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  userPhone,
                  style: GoogleFonts.inter(
                    fontSize: 11.5,
                    color: Colors.white70,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Drawer Navigation Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
              children: [
                // 1. My Profile
                _DrawerItem(
                  icon: Icons.person_outline_rounded,
                  title: context.tr('profile', 'My Profile'),
                  subtitle: context.tr('myProfileBadgesSub', 'Personal details & membership'),
                  badgeText: isLoggedIn ? 'Verified' : null,
                  badgeColor: AppColors.primary,
                  onTap: () {
                    Navigator.pop(context);
                    if (isLoggedIn) {
                      context.push('/profile');
                    } else {
                      context.push('/login');
                    }
                  },
                ),

                const SizedBox(height: 4),

                // 2. Saved Address
                _DrawerItem(
                  icon: Icons.location_on_outlined,
                  title: context.tr('savedAddresses', 'Saved Address'),
                  subtitle: context.tr('savedAddressesSub', 'Manage home, office & family address'),
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/addresses');
                  },
                ),

                const SizedBox(height: 4),

                // 3. Coupons and Rewards
                _DrawerItem(
                  icon: Icons.card_giftcard_rounded,
                  title: context.tr('couponsRewards', 'Coupons and Rewards'),
                  subtitle: context.tr('couponsRewardsSub', 'Prithvi coins, vouchers & dividends'),
                  badgeText: '450 Coins',
                  badgeColor: AppColors.accent,
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/rewards');
                  },
                ),

                const SizedBox(height: 4),

                // Extra Value: My Bookings
                _DrawerItem(
                  icon: Icons.receipt_long_rounded,
                  title: context.tr('myBookings', 'My Bookings'),
                  subtitle: context.tr('activeRepairsSub', 'Active repairs & warranty claims'),
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/my-bookings');
                  },
                ),

                const SizedBox(height: 4),

                // Prithvi AI Assistant & Diagnostics
                _DrawerItem(
                  icon: Icons.auto_awesome,
                  title: context.tr('prithviAi', 'Prithvi AI Assistant'),
                  subtitle: context.tr('prithviAiSub', 'Photo defect scan & 93-2-5 rate check'),
                  badgeText: 'Free AI',
                  badgeColor: AppColors.primary,
                  iconColor: AppColors.primary,
                  onTap: () {
                    Navigator.pop(context);
                    AiAssistantSheet.show(context);
                  },
                ),

                const Divider(height: 24, color: AppColors.borderLight),

                // Language Switcher Tile
                _DrawerItem(
                  icon: Icons.translate_rounded,
                  title: context.tr('language', 'Language / ଭାଷା'),
                  subtitle: 'Current: ${context.watch<LocaleProvider>().currentLanguageName}',
                  badgeText: context.watch<LocaleProvider>().currentLanguageCode.toUpperCase(),
                  badgeColor: AppColors.primary,
                  iconColor: const Color(0xFF0284C7),
                  onTap: () {
                    Navigator.pop(context);
                    showLanguageDialog(context);
                  },
                ),

                const SizedBox(height: 4),

                // 4. Help & Support
                _DrawerItem(
                  icon: Icons.help_outline_rounded,
                  title: context.tr('help', 'Help & Support'),
                  subtitle: '24/7 Helpline, FAQs & grievance desk',
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/help');
                  },
                ),

                const SizedBox(height: 4),

                // Rate Card
                _DrawerItem(
                  icon: Icons.currency_rupee_rounded,
                  title: context.tr('rateCard', 'Official Rate Card'),
                  subtitle: context.tr('tariffRateCardSub', 'Govt standardized fair tariffs'),
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/rate-card');
                  },
                ),

                const SizedBox(height: 4),

                // Appliance Lineage
                _DrawerItem(
                  icon: Icons.history_edu_rounded,
                  title: context.tr('applianceLineage', 'Appliance Passport'),
                  subtitle: context.tr('applianceLineageSub', 'Service history & warranty logs'),
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/lineage');
                  },
                ),

                const SizedBox(height: 4),

                // Language Switcher
                _DrawerItem(
                  icon: Icons.translate_rounded,
                  title: 'Language / ଭାଷା',
                  subtitle: 'Current: ${context.watch<LocaleProvider>().currentLanguageName}',
                  badgeText: context.watch<LocaleProvider>().currentLanguageCode.toUpperCase(),
                  badgeColor: AppColors.primary,
                  onTap: () {
                    Navigator.pop(context);
                    showLanguageDialog(context);
                  },
                ),

                const Divider(height: 24, color: AppColors.borderLight),

                // 5. Login / Logout
                if (isLoggedIn)
                  _DrawerItem(
                    icon: Icons.logout_rounded,
                    title: context.tr('logout', 'Log Out'),
                    subtitle: 'Sign out of this session',
                    iconColor: AppColors.error,
                    textColor: AppColors.error,
                    onTap: () async {
                      Navigator.pop(context);
                      await auth.logout();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Logged out successfully')),
                        );
                        context.go('/login');
                      }
                    },
                  )
                else
                  _DrawerItem(
                    icon: Icons.login_rounded,
                    title: context.tr('login', 'Login / Sign Up'),
                    subtitle: 'Access full cooperative privileges',
                    iconColor: AppColors.primary,
                    textColor: AppColors.primary,
                    badgeText: 'Instant OTP',
                    badgeColor: AppColors.primary,
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/login');
                    },
                  ),
              ],
            ),
          ),

          // Footer (Tap to configure backend server IP / URL)
          InkWell(
            onTap: () {
              final controller = TextEditingController(text: StorageService.getServerUrl());
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  title: Row(
                    children: [
                      const Icon(Icons.dns_rounded, color: AppColors.primary, size: 22),
                      const SizedBox(width: 8),
                      Text('Backend Server Connection', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Set backend IP address to connect from your physical phone over Wi-Fi:',
                        style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary),
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
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                      child: const Text('Save & Apply', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
              decoration: const BoxDecoration(
                color: AppColors.scaffoldBg,
                border: Border(top: BorderSide(color: AppColors.borderLight)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.shield_outlined, color: AppColors.primary, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Prithvi Fix • Sahakari Seva',
                          style: GoogleFonts.outfit(
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          'Tap to configure IP (${StorageService.getServerUrl()})',
                          style: GoogleFonts.inter(fontSize: 9.5, color: AppColors.textMuted),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.settings_outlined, size: 14, color: AppColors.textMuted),
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (iconColor ?? AppColors.primary).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: iconColor ?? AppColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
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
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: textColor ?? AppColors.textPrimary,
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
                            border: Border.all(
                              color: (badgeColor ?? AppColors.primary).withValues(alpha: 0.4),
                            ),
                          ),
                          child: Text(
                            badgeText!,
                            style: GoogleFonts.inter(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: badgeColor ?? AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 1),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 10.5,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textMuted,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}
