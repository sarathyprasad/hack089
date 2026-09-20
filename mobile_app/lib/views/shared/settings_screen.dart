import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_colors.dart';
import '../../core/localization/language_provider.dart';
import '../../core/theme/accessibility_provider.dart';
import '../../core/storage/storage_service.dart';
import '../../core/widgets/gov_app_bar.dart';
import '../../core/widgets/gov_drawer.dart';
import '../../providers/auth_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _voiceAlerts = false;
  bool _soundEffects = true;
  bool _notifBookings = true;
  bool _notifEscrow = true;
  bool _notifSafety = true;
  bool _isClearingCache = false;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  void _loadPreferences() {
    setState(() {
      _voiceAlerts = StorageService.getVoiceAlerts();
      _soundEffects = StorageService.getSoundEffects();
      _notifBookings = StorageService.getNotificationPref('pref_notif_bookings', defaultValue: true);
      _notifEscrow = StorageService.getNotificationPref('pref_notif_escrow', defaultValue: true);
      _notifSafety = StorageService.getNotificationPref('pref_notif_safety', defaultValue: true);
    });
  }

  Future<void> _handleClearCache() async {
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF131B38) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(color: isDark ? const Color(0xFF1E294B) : const Color(0xFFE2E8F0)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.delete_sweep_rounded, color: Colors.amber, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Clear Temporary Offline Cache?',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'This will clear locally cached rate cards, temporary photos, and search indices. Your account, login session, and booking records will remain completely secure.',
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? const Color(0xFF94A3B8) : AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.emergencyRed,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Clear Cache'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );

    if (confirmed == true && mounted) {
      setState(() => _isClearingCache = true);
      await StorageService.clearCache();
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        setState(() => _isClearingCache = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Temporary offline cache cleared successfully.'),
            backgroundColor: AppColors.accentGreen,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _makeCall(String phoneNumber) async {
    final uri = Uri.parse('tel:$phoneNumber');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not dial $phoneNumber on this device.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lang = context.watch<LanguageProvider>();
    final access = context.watch<AccessibilityProvider>();
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;
    final isGuest = auth.isGuest;

    final cardBg = isDark ? const Color(0xFF131B38) : Colors.white;
    final cardBorder = isDark ? const Color(0xFF1E294B) : const Color(0xFFE2E8F0);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (context.canPop()) {
          context.pop();
        } else {
          context.go('/');
        }
      },
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF0A0F24) : const Color(0xFFF8FAFC),
        appBar: GovAppBar(
          title: lang.translate('settings'),
          showBack: true,
        ),
        drawer: const GovDrawer(),
        body: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          children: [
            // ── Section 1: Active Identity & Account ──
            _buildSectionHeader('ACTIVE USER SESSION', Icons.account_circle_outlined, isDark),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: cardBorder),
                boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2))],
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: isGuest
                          ? Colors.grey.withValues(alpha: 0.2)
                          : (isDark ? AppColors.secondarySaffron : AppColors.primaryNavy),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        isGuest ? 'G' : (user?.name.isNotEmpty == true ? user!.name.substring(0, 1).toUpperCase() : 'U'),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isGuest
                              ? (isDark ? Colors.white70 : Colors.black87)
                              : (isDark ? Colors.black : Colors.white),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isGuest ? 'Guest Visitor (Monitor Only)' : (user?.name ?? 'Registered User'),
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: isGuest
                                    ? Colors.amber.withValues(alpha: 0.2)
                                    : AppColors.accentGreen.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                isGuest ? 'GUEST' : (user?.role.toUpperCase() ?? 'CITIZEN'),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: isGuest ? AppColors.secondarySaffron : AppColors.accentGreen,
                                ),
                              ),
                            ),
                            if (!isGuest && user?.district != null) ...[
                              const SizedBox(width: 6),
                              Text(
                                '• ${user!.district}',
                                style: TextStyle(fontSize: 11, color: isDark ? const Color(0xFF94A3B8) : AppColors.textMuted),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      if (isGuest) {
                        context.push('/login');
                      } else {
                        await auth.logout();
                        if (context.mounted) context.go('/welcome');
                      }
                    },
                    child: Text(
                      isGuest ? 'Sign In' : 'Sign Out',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isGuest ? AppColors.secondarySaffron : AppColors.emergencyRed,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── Section 2: Appearance & Theme ──
            _buildSectionHeader(lang.translate('appearance'), Icons.palette_outlined, isDark),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: cardBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Color Scheme Mode',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isDark ? Colors.white : AppColors.textPrimary),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      // Light Theme
                      Expanded(
                        child: _themeSelectPill(
                          label: 'Light',
                          icon: Icons.light_mode_rounded,
                          isSelected: !access.isDarkMode && !access.highContrast,
                          isDark: isDark,
                          onTap: () {
                            if (access.highContrast) access.toggleHighContrast();
                            if (access.isDarkMode) access.setDarkMode(false);
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Dark Theme (Midnight Navy)
                      Expanded(
                        child: _themeSelectPill(
                          label: 'Dark Navy',
                          icon: Icons.dark_mode_rounded,
                          isSelected: access.isDarkMode && !access.highContrast,
                          isDark: isDark,
                          onTap: () {
                            if (access.highContrast) access.toggleHighContrast();
                            if (!access.isDarkMode) access.setDarkMode(true);
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      // High Contrast Mode
                      Expanded(
                        child: _themeSelectPill(
                          label: 'Contrast',
                          icon: Icons.contrast_rounded,
                          isSelected: access.highContrast,
                          isDark: isDark,
                          onTap: () {
                            if (!access.highContrast) access.toggleHighContrast();
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── Section 3: Language & Regional ──
            _buildSectionHeader('LANGUAGE / ଭାଷା / भाषा', Icons.translate_rounded, isDark),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: cardBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Select Application Interface Language',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isDark ? Colors.white : AppColors.textPrimary),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _langSelectPill(
                          label: 'English',
                          code: 'EN',
                          currentCode: lang.currentLocale,
                          isDark: isDark,
                          onTap: () => lang.setLanguage('EN'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _langSelectPill(
                          label: 'ଓଡ଼ିଆ (Odia)',
                          code: 'OR',
                          currentCode: lang.currentLocale,
                          isDark: isDark,
                          onTap: () => lang.setLanguage('OR'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _langSelectPill(
                          label: 'हिन्दी (Hindi)',
                          code: 'HI',
                          currentCode: lang.currentLocale,
                          isDark: isDark,
                          onTap: () => lang.setLanguage('HI'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── Section 4: Voice & Audio Guidance ──
            _buildSectionHeader(lang.translate('voice_sound'), Icons.volume_up_outlined, isDark),
            Container(
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: cardBorder),
              ),
              child: Column(
                children: [
                  SwitchListTile.adaptive(
                    value: _voiceAlerts,
                    activeTrackColor: AppColors.secondarySaffron,
                    activeThumbColor: Colors.black,
                    title: Text(
                      'Worker Voice Job Announcements',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isDark ? Colors.white : AppColors.textPrimary),
                    ),
                    subtitle: Text(
                      'Speaks incoming work order alerts in regional languages (Opt-in).',
                      style: TextStyle(fontSize: 11, color: isDark ? const Color(0xFF94A3B8) : AppColors.textMuted),
                    ),
                    onChanged: (val) async {
                      setState(() => _voiceAlerts = val);
                      await StorageService.saveVoiceAlerts(val);
                    },
                  ),
                  Divider(height: 1, color: cardBorder),
                  SwitchListTile.adaptive(
                    value: _soundEffects,
                    activeTrackColor: AppColors.secondarySaffron,
                    activeThumbColor: Colors.black,
                    title: Text(
                      'Feedback Sound Effects & Chimes',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isDark ? Colors.white : AppColors.textPrimary),
                    ),
                    subtitle: Text(
                      'Subtle haptic chimes when claiming orders or submitting OTPs.',
                      style: TextStyle(fontSize: 11, color: isDark ? const Color(0xFF94A3B8) : AppColors.textMuted),
                    ),
                    onChanged: (val) async {
                      setState(() => _soundEffects = val);
                      await StorageService.saveSoundEffects(val);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── Section 5: Offline Storage & Cache ──
            _buildSectionHeader(lang.translate('storage_cache'), Icons.storage_rounded, isDark),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: cardBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Offline Cache & Datasets',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isDark ? Colors.white : AppColors.textPrimary),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Cached trade catalog, rates & local indices (~3.8 MB)',
                            style: TextStyle(fontSize: 11, color: isDark ? const Color(0xFF94A3B8) : AppColors.textMuted),
                          ),
                        ],
                      ),
                      ElevatedButton.icon(
                        onPressed: _isClearingCache ? null : _handleClearCache,
                        icon: _isClearingCache
                            ? const SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Icon(Icons.delete_sweep_rounded, size: 15),
                        label: Text(lang.translate('clear_cache'), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDark ? const Color(0xFF1E294B) : const Color(0xFFF1F5F9),
                          foregroundColor: isDark ? Colors.white : AppColors.primaryNavy,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── Section 6: System Notifications ──
            _buildSectionHeader(lang.translate('notifications'), Icons.notifications_none_rounded, isDark),
            Container(
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: cardBorder),
              ),
              child: Column(
                children: [
                  SwitchListTile.adaptive(
                    value: _notifBookings,
                    activeTrackColor: AppColors.secondarySaffron,
                    activeThumbColor: Colors.black,
                    title: Text(
                      'Booking & Job Dispatch Updates',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isDark ? Colors.white : AppColors.textPrimary),
                    ),
                    onChanged: (val) async {
                      setState(() => _notifBookings = val);
                      await StorageService.saveNotificationPref('pref_notif_bookings', val);
                    },
                  ),
                  Divider(height: 1, color: cardBorder),
                  SwitchListTile.adaptive(
                    value: _notifEscrow,
                    activeTrackColor: AppColors.secondarySaffron,
                    activeThumbColor: Colors.black,
                    title: Text(
                      'Escrow Payouts & Welfare Credits',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isDark ? Colors.white : AppColors.textPrimary),
                    ),
                    onChanged: (val) async {
                      setState(() => _notifEscrow = val);
                      await StorageService.saveNotificationPref('pref_notif_escrow', val);
                    },
                  ),
                  Divider(height: 1, color: cardBorder),
                  SwitchListTile.adaptive(
                    value: _notifSafety,
                    activeTrackColor: AppColors.secondarySaffron,
                    activeThumbColor: Colors.black,
                    title: Text(
                      'Disaster & Statutory Safety Advisories',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isDark ? Colors.white : AppColors.textPrimary),
                    ),
                    onChanged: (val) async {
                      setState(() => _notifSafety = val);
                      await StorageService.saveNotificationPref('pref_notif_safety', val);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── Section 7: Safety & Helplines ──
            _buildSectionHeader(lang.translate('safety_helpline'), Icons.support_agent_rounded, isDark),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: cardBorder),
              ),
              child: Column(
                children: [
                  _helplineRow(
                    title: 'Odisha Cooperative Citizen Toll-Free',
                    number: '1800-345-7788',
                    isDark: isDark,
                    onTap: () => _makeCall('18003457788'),
                  ),
                  Divider(height: 20, color: cardBorder),
                  _helplineRow(
                    title: 'Artisan Safety & Emergency Squad',
                    number: '1800-345-1088',
                    isDark: isDark,
                    onTap: () => _makeCall('18003451088'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── Section 8: Statutory App Governance & Disclaimers ──
            _buildSectionHeader(lang.translate('about_app'), Icons.info_outline_rounded, isDark),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: cardBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.borderLight),
                        ),
                        child: Image.asset('assets/images/logo_emblem.png', fit: BoxFit.contain),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Prithvi Fix (ପୃଥିବୀ ଫିକ୍ସ)',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.textPrimary),
                            ),
                            Text(
                              'Version 2.4.0 (CivicBuild 2026.1)',
                              style: TextStyle(fontSize: 11, color: isDark ? const Color(0xFF94A3B8) : AppColors.textMuted),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Operated under the Labour Cooperatives Federation (LCF) and Odisha Co-operative Societies Act, 1962 (Form IV GST Certified). All wage settlements adhere strictly to the statutory 93-2-5 escrow protocol.',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? const Color(0xFF94A3B8) : AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  static Widget _buildSectionHeader(String title, IconData icon, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 15, color: isDark ? AppColors.secondarySaffron : AppColors.primaryNavy),
          const SizedBox(width: 6),
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: isDark ? const Color(0xFF94A3B8) : AppColors.textMuted,
              letterSpacing: 0.6,
            ),
          ),
        ],
      ),
    );
  }

  static Widget _themeSelectPill({
    required String label,
    required IconData icon,
    required bool isSelected,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? AppColors.secondarySaffron : AppColors.primaryNavy)
              : (isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9)),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? (isDark ? AppColors.secondarySaffron : AppColors.primaryNavy)
                : (isDark ? const Color(0xFF1E294B) : const Color(0xFFCBD5E1)),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected
                  ? (isDark ? Colors.black : Colors.white)
                  : (isDark ? const Color(0xFFCBD5E1) : AppColors.textPrimary),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected
                    ? (isDark ? Colors.black : Colors.white)
                    : (isDark ? const Color(0xFFCBD5E1) : AppColors.textPrimary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _langSelectPill({
    required String label,
    required String code,
    required String currentCode,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    final isSelected = code == currentCode;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? AppColors.secondarySaffron : AppColors.primaryNavy)
              : (isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9)),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? (isDark ? AppColors.secondarySaffron : AppColors.primaryNavy)
                : (isDark ? const Color(0xFF1E294B) : const Color(0xFFCBD5E1)),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Center(
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              color: isSelected
                  ? (isDark ? Colors.black : Colors.white)
                  : (isDark ? const Color(0xFFCBD5E1) : AppColors.textPrimary),
            ),
          ),
        ),
      ),
    );
  }

  static Widget _helplineRow({
    required String title,
    required String number,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isDark ? Colors.white : AppColors.textPrimary),
            ),
            const SizedBox(height: 2),
            Text(
              number,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isDark ? AppColors.secondarySaffron : AppColors.primaryNavy),
            ),
          ],
        ),
        ElevatedButton.icon(
          onPressed: onTap,
          icon: const Icon(Icons.phone_in_talk_rounded, size: 14),
          label: const Text('Call Now', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accentGreen,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ],
    );
  }
}
