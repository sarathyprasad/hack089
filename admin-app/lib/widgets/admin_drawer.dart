import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../core/constants/api_endpoints.dart';
import '../core/constants/app_colors.dart';
import '../core/storage/storage_service.dart';
import '../providers/auth_provider.dart';
import '../providers/locale_provider.dart';

class AdminDrawer extends StatelessWidget {
  const AdminDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.currentUser;
    final userName = user?.name ?? 'Admin User';
    final userRole = user?.role ?? 'COOPERATIVE_ADMIN';
    final designation = auth.roleDisplay;

    return Drawer(
      backgroundColor: AppColors.scaffoldBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Header with Charcoal & Amber Gradient
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
                colors: [Color(0xFF292524), Color(0xFF1C1917)],
              ),
              borderRadius: BorderRadius.only(topRight: Radius.circular(24)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.25),
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
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.primary),
                      ),
                      child: Text(
                        userRole,
                        style: GoogleFonts.dmSans(
                          fontSize: 9.5,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  userName,
                  style: GoogleFonts.dmSans(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  designation,
                  style: GoogleFonts.inter(fontSize: 11.5, color: AppColors.primaryLight),
                ),
                const SizedBox(height: 8),
                Text(
                  'Odisha State Cooperative Governance Console',
                  style: GoogleFonts.inter(fontSize: 10, color: AppColors.textMuted),
                ),
              ],
            ),
          ),

          // Drawer Navigation Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
              children: [
                _AdminDrawerItem(
                  icon: Icons.dashboard_outlined,
                  title: 'Command Dashboard',
                  subtitle: 'Statewide GMV, verification queue',
                  onTap: () {
                    Navigator.pop(context);
                    context.go('/');
                  },
                ),
                const SizedBox(height: 4),
                _AdminDrawerItem(
                  icon: Icons.payments_outlined,
                  title: 'Escrow & Payout Clearing',
                  subtitle: '93-2-5 automated batch settlement',
                  badgeText: 'Batch Ready',
                  badgeColor: AppColors.success,
                  onTap: () {
                    Navigator.pop(context);
                    context.go('/escrow');
                  },
                ),
                const SizedBox(height: 4),
                _AdminDrawerItem(
                  icon: Icons.how_to_vote_outlined,
                  title: 'AGM Governance & Ballots',
                  subtitle: 'Statutory resolutions & member voting',
                  badgeText: '78% Quorum',
                  badgeColor: AppColors.gold,
                  onTap: () {
                    Navigator.pop(context);
                    context.go('/agm');
                  },
                ),
                const SizedBox(height: 4),
                _AdminDrawerItem(
                  icon: Icons.warehouse_outlined,
                  title: 'Bulk Warehouse & Sourcing',
                  subtitle: 'OEM direct procurement discounts',
                  onTap: () {
                    Navigator.pop(context);
                    context.go('/inventory');
                  },
                ),
                const Divider(height: 20, color: AppColors.borderDark),
                _AdminDrawerItem(
                  icon: Icons.account_balance_outlined,
                  title: 'Federation Districts',
                  subtitle: 'Khordha, Cuttack & Puri oversight',
                  onTap: () {
                    Navigator.pop(context);
                    context.go('/federation');
                  },
                ),
                const SizedBox(height: 4),
                _AdminDrawerItem(
                  icon: Icons.insights_outlined,
                  title: 'Apex AI Strategic Demand',
                  subtitle: '7-day surge forecasting & relocation',
                  onTap: () {
                    Navigator.pop(context);
                    context.go('/apex');
                  },
                ),
                const SizedBox(height: 4),
                _AdminDrawerItem(
                  icon: Icons.radar,
                  title: 'Live Telemetry & GPS',
                  subtitle: 'Active workforce & SOS emergency map',
                  onTap: () {
                    Navigator.pop(context);
                    context.go('/monitoring');
                  },
                ),
                const SizedBox(height: 4),
                _AdminDrawerItem(
                  icon: Icons.gavel_outlined,
                  title: 'Dispute Redressal Tribunal',
                  subtitle: 'Statutory grievance rulings',
                  onTap: () {
                    Navigator.pop(context);
                    context.go('/disputes');
                  },
                ),
                const SizedBox(height: 4),
                _AdminDrawerItem(
                  icon: Icons.price_change_outlined,
                  title: 'Tariff & Parts Admin',
                  subtitle: 'Statewide rate cards & spare catalog',
                  onTap: () {
                    Navigator.pop(context);
                    context.go('/tariffs');
                  },
                ),
                const Divider(height: 20, color: AppColors.borderDark),

                // Language Switcher Tile
                _AdminDrawerItem(
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

                const SizedBox(height: 4),

                _AdminDrawerItem(
                  icon: Icons.logout,
                  title: 'Log Out / Switch Persona',
                  subtitle: 'Return to login portal',
                  iconColor: AppColors.error,
                  textColor: AppColors.error,
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
              final controller = TextEditingController(text: StorageService.getCustomBaseUrl() ?? ApiEndpoints.defaultBaseUrl);
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  backgroundColor: AppColors.cardSurface,
                  title: Row(
                    children: [
                      const Icon(Icons.dns_rounded, color: AppColors.primary, size: 20),
                      const SizedBox(width: 8),
                      Text('Server Connection', style: GoogleFonts.dmSans(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                    ],
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Set backend IP address to connect Sahakari console over Wi-Fi:',
                        style: GoogleFonts.dmSans(fontSize: 12, color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: controller,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'API Base URL',
                          labelStyle: const TextStyle(color: AppColors.textSecondary),
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
                          await StorageService.saveCustomBaseUrl(val);
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
                color: AppColors.cardSurface,
                border: Border(top: BorderSide(color: AppColors.borderDark)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.verified_user_outlined, color: AppColors.primary, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Prithvi Fix Sahakari v2.4.0 • Registrar Console',
                      style: GoogleFonts.dmSans(fontSize: 10.5, color: AppColors.textSecondary),
                    ),
                  ),
                  const Icon(Icons.settings_ethernet, size: 16, color: AppColors.primary),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminDrawerItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? textColor;
  final String? badgeText;
  final Color? badgeColor;

  const _AdminDrawerItem({
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
                          style: GoogleFonts.dmSans(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: textColor ?? Colors.white,
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
                            style: GoogleFonts.dmSans(
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
                    style: GoogleFonts.inter(fontSize: 10.5, color: AppColors.textSecondary),
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
