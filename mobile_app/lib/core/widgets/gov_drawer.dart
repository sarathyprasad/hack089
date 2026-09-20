import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../localization/language_provider.dart';
import '../theme/accessibility_provider.dart';
import '../../providers/auth_provider.dart';

import '../../providers/location_provider.dart';
import 'location_selection_modal.dart';

class GovDrawer extends StatelessWidget {
  const GovDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final lang = context.watch<LanguageProvider>();
    final locProv = context.watch<LocationProvider>();
    final user = auth.currentUser;
    final isGuest = auth.isGuest;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final unsupp = locProv.unsupportedLocation;
    final selectedLoc = locProv.selectedLocation;

    return Drawer(
      child: Column(
        children: [
          // 1. Modern Drawer Header with explicit Close (X) button
          Container(
            padding: EdgeInsets.fromLTRB(16, MediaQuery.of(context).padding.top + 12, 16, 16),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.navyDark, AppColors.primaryNavy],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 22,
                          backgroundColor: AppColors.secondarySaffron,
                          child: Text(
                            user != null && user.name.isNotEmpty
                                ? user.name[0].toUpperCase()
                                : (isGuest ? 'G' : 'P'),
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          width: 40,
                          height: 40,
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.asset('assets/images/logo_emblem.png', fit: BoxFit.contain),
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white, size: 24),
                      tooltip: 'Close Sidebar',
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  user?.name ?? (isGuest ? lang.translate('guest_monitor_mode') : 'Citizen'),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: user != null ? AppColors.accentGreen : AppColors.secondarySaffron,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        user != null ? user.role : lang.translate('guest_monitor_mode').toUpperCase(),
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          color: user != null ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                    if (user?.district != null) ...[
                      const SizedBox(width: 8),
                      Text(
                        '• ${user!.district}',
                        style: const TextStyle(fontSize: 11, color: Colors.white70),
                      ),
                    ],
                  ],
                ),

                // Guest Callout Card
                if (isGuest) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, color: AppColors.secondarySaffron, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            lang.translate('guest_signin_prompt'),
                            style: const TextStyle(fontSize: 11, color: Colors.white),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.pop(context);
                            context.push('/login');
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.secondarySaffron,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              lang.translate('login'),
                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          // 2. Interactive Location Row
          InkWell(
            onTap: () {
              Navigator.pop(context);
              LocationSelectionModal.show(context);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: unsupp != null
                    ? (isDark ? AppColors.darkAmberBg : AppColors.amber50)
                    : (isDark ? AppColors.darkCardAlt : AppColors.slate100),
                border: Border(
                  bottom: BorderSide(
                    color: isDark ? AppColors.darkBorder : AppColors.slate200,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.location_on_rounded,
                    size: 18,
                    color: unsupp != null ? AppColors.amber600 : AppColors.primaryNavy,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          unsupp != null
                              ? '📍 ${unsupp.name} (Coming Soon)'
                              : '📍 ${selectedLoc.shortName} (${selectedLoc.city})',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: unsupp != null
                                ? AppColors.amber700
                                : (isDark ? Colors.white : AppColors.slate900),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          unsupp != null
                              ? 'Outside coverage • Tap to switch'
                              : '${selectedLoc.label} • Tap to change',
                          style: TextStyle(
                            fontSize: 10,
                            color: isDark ? AppColors.slate400 : AppColors.slate500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.slate400),
                ],
              ),
            ),
          ),

          // 3. Language Switcher Row (5 Languages)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            color: isDark ? const Color(0xFF131B38) : const Color(0xFFF8FAFC),
            child: Row(
              children: [
                Icon(Icons.translate, size: 14, color: isDark ? AppColors.secondarySaffron : AppColors.primaryNavy),
                const SizedBox(width: 6),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildLangPill(context, lang, 'EN', 'EN', isDark),
                        const SizedBox(width: 3),
                        _buildLangPill(context, lang, 'OR', 'ଓଡ଼ିଆ', isDark),
                        const SizedBox(width: 3),
                        _buildLangPill(context, lang, 'HI', 'हिन्दी', isDark),
                        const SizedBox(width: 3),
                        _buildLangPill(context, lang, 'BN', 'বাংলা', isDark),
                        const SizedBox(width: 3),
                        _buildLangPill(context, lang, 'TE', 'తెలుగు', isDark),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 3. Navigation List
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _drawerTile(context, icon: Icons.home_rounded, title: lang.translate('home'), path: '/', isDark: isDark),
                _drawerTile(context, icon: Icons.handyman_rounded, title: lang.translate('services'), path: '/services', isDark: isDark),
                _drawerTile(context, icon: Icons.person_search_rounded, title: lang.translate('find_worker'), path: '/find-worker', isDark: isDark),
                _drawerTile(context, icon: Icons.receipt_long_rounded, title: lang.translate('rate_card'), path: '/rate-card', isDark: isDark),

                const Divider(height: 16),

                // Appearance: Dark Theme Switch Tile
                Consumer<AccessibilityProvider>(
                  builder: (ctx, access, _) => SwitchListTile(
                    dense: true,
                    secondary: Icon(
                      access.isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_outlined,
                      color: access.isDarkMode ? AppColors.secondarySaffron : AppColors.primaryNavy,
                      size: 20,
                    ),
                    title: Text(
                      access.isDarkMode ? 'Dark Theme: On' : 'Dark Theme: Off',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                    value: access.isDarkMode,
                    activeThumbColor: AppColors.secondarySaffron,
                    onChanged: (val) => access.setDarkMode(val),
                  ),
                ),

                const Divider(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Text(
                    lang.translate('odisha_network'),
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: isDark ? const Color(0xFF94A3B8) : AppColors.textMuted, letterSpacing: 0.5),
                  ),
                ),
                _drawerTile(context, icon: Icons.app_registration_rounded, title: 'Register Society', path: '/society/register', isDark: isDark),
                _drawerTile(context, icon: Icons.timeline_rounded, title: 'Track Society Timeline', path: '/society/timeline', isDark: isDark),

                // Workspaces (only for logged-in users)
                if (user != null) ...[
                  const Divider(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: Text('MY WORKSPACE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: isDark ? const Color(0xFF94A3B8) : AppColors.textMuted, letterSpacing: 0.5)),
                  ),
                  if (user.role == 'citizen') ...[
                    _drawerTile(context, icon: Icons.receipt_rounded, title: lang.translate('my_bookings'), path: '/customer/bookings', isDark: isDark),
                  ] else if (user.role == 'artisan') ...[
                    _drawerTile(context, icon: Icons.work_history_rounded, title: 'Active Jobs & Assignments', path: '/worker/dashboard', isDark: isDark),
                    _drawerTile(context, icon: Icons.health_and_safety_rounded, title: 'Welfare Fund & Insurance', path: '/worker/welfare', isDark: isDark),
                  ] else if (user.role == 'admin') ...[
                    _drawerTile(context, icon: Icons.admin_panel_settings_rounded, title: 'State Federation Console', path: '/admin/dashboard', isDark: isDark),
                    _drawerTile(context, icon: Icons.account_balance_rounded, title: 'District Federation Portal', path: '/federation/portal', isDark: isDark),
                    _drawerTile(context, icon: Icons.gavel_rounded, title: 'Institutional Tenders', path: '/federation/tenders', isDark: isDark),
                  ],
                ],

                const Divider(height: 20),
                _drawerTile(context, icon: Icons.settings_outlined, title: lang.translate('settings'), path: '/settings', isDark: isDark),
                _drawerTile(context, icon: Icons.info_outline_rounded, title: lang.translate('about_cooperative'), path: '/about', isDark: isDark),
                _drawerTile(context, icon: Icons.contact_support_rounded, title: lang.translate('help_support'), path: '/help', isDark: isDark),
              ],
            ),
          ),

          // 4. Footer: Sign In or Logout
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.borderLight)),
            ),
            child: isGuest
                ? Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            context.push('/login');
                          },
                          icon: const Icon(Icons.login, size: 16),
                          label: Text(
                            lang.translate('login'),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isDark ? AppColors.secondarySaffron : AppColors.primaryNavy,
                            foregroundColor: isDark ? Colors.black : Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                    ],
                  )
                : Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            Navigator.pop(context);
                            await auth.logout();
                            if (context.mounted) {
                              context.go('/welcome');
                            }
                          },
                          icon: const Icon(Icons.logout, size: 16, color: AppColors.emergencyRed),
                          label: Text(
                            lang.translate('logout'),
                            style: const TextStyle(color: AppColors.emergencyRed, fontWeight: FontWeight.bold),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.emergencyRed),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  static Widget _buildLangPill(BuildContext context, LanguageProvider lang, String code, String label, bool isDark) {
    final isSelected = lang.currentLocale == code;
    return InkWell(
      onTap: () => lang.setLanguage(code),
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? AppColors.secondarySaffron : AppColors.primaryNavy)
              : (isDark ? const Color(0xFF1E294B) : Colors.white),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected
                ? (isDark ? AppColors.secondarySaffron : AppColors.primaryNavy)
                : (isDark ? AppColors.darkBorder : const Color(0xFFCBD5E1)),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            color: isSelected
                ? (isDark ? Colors.black : Colors.white)
                : (isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155)),
          ),
        ),
      ),
    );
  }

  static Widget _drawerTile(BuildContext context, {required IconData icon, required String title, required String path, required bool isDark}) {
    return ListTile(
      dense: true,
      leading: Icon(icon, color: isDark ? AppColors.secondarySaffron : AppColors.primaryNavy, size: 20),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: isDark ? Colors.white : AppColors.textPrimary,
        ),
      ),
      onTap: () {
        Navigator.pop(context);
        if (path == '/') {
          context.go('/');
        } else {
          context.push(path);
        }
      },
    );
  }
}
