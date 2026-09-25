import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/locale_provider.dart';
import '../core/constants/app_colors.dart';
import '../core/localization/app_localizations.dart';
import '../core/network/api_client.dart';
import '../core/constants/api_endpoints.dart';
import '../widgets/worker_drawer.dart';
import 'sos_beacon_sheet.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Map<String, dynamic>? _dashboard;
  bool _loading = true;
  String _availability = 'AVAILABLE';
  int _navIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    try {
      final res = await ApiClient().get(ApiEndpoints.workerDashboard);
      if (res is Map) {
        setState(() {
          _dashboard = Map<String, dynamic>.from(res);
          _availability = res['worker']?['availability']?.toString() ??
              res['availability']?.toString() ??
              'AVAILABLE';
        });
      }
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _toggleAvailability(String status) async {
    setState(() => _availability = status);
    try {
      await ApiClient().put(ApiEndpoints.workerAvailability, data: {'availability': status});
    } catch (_) {}
  }

  Future<void> _acceptBooking(int bookingId) async {
    try {
      await ApiClient().put(ApiEndpoints.workerJobAction(bookingId), data: {'action': 'ACCEPT'});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Job accepted! Routing to job dispatch...')),
        );
        _loadDashboard();
        context.go('/job/$bookingId');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to accept job: $e')),
        );
      }
    }
  }

  Future<void> _declineBooking(int bookingId) async {
    try {
      await ApiClient().put(ApiEndpoints.workerJobAction(bookingId), data: {'action': 'DECLINE'});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Job declined.')),
        );
        _loadDashboard();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to decline job: $e')),
        );
      }
    }
  }

  Color _availColor(String s) {
    switch (s) {
      case 'AVAILABLE': return AppColors.available;
      case 'BUSY': return AppColors.busy;
      default: return AppColors.offline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final user = auth.currentUser;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Clean, robust data extraction
    final stats = _dashboard?['stats'] as Map<String, dynamic>?;
    final worker = _dashboard?['worker'] as Map<String, dynamic>?;
    final earnings = stats?['totalEarnings'] ?? worker?['total_earnings'] ?? _dashboard?['totalEarnings'] ?? 0;
    final completedJobsList = (_dashboard?['completedJobs'] as List?) ?? [];
    final activeJobs = (_dashboard?['activeJobs'] as List?) ?? [];
    final incomingJobs = (_dashboard?['incomingJobs'] as List?) ?? [];

    // Explicit numerical count — prevents stringifying raw JSON array!
    final completedCount = stats?['totalJobsCompleted'] ?? worker?['total_jobs_completed'] ?? completedJobsList.length;

    return Scaffold(
      backgroundColor: AppColors.bg(context),
      drawer: const WorkerDrawer(),
      appBar: AppBar(
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.surface(context),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border(context)),
              ),
              child: const Icon(Icons.menu_rounded, color: AppColors.accent, size: 20),
            ),
            tooltip: 'Open Menu',
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.accent.withValues(alpha: 0.4),
                  width: 1.2,
                ),
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/images/logo-emblem.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    context.tr('shramikPortal', 'Shramik Terminal'),
                    style: GoogleFonts.outfit(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.text(context),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (user != null)
                    Text(
                      user.name,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: AppColors.textSec(context),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          // Language Switcher Button
          Builder(
            builder: (ctx) {
              final localeProvider = ctx.watch<LocaleProvider>();
              return InkWell(
                onTap: () => showLanguageDialog(ctx),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.surface(context),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.border(context)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.translate_rounded, color: AppColors.accent, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        localeProvider.currentLanguageName,
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.text(context),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          // Quick Dark / Light Mode Toggle Button
          IconButton(
            icon: Icon(
              themeProvider.isDarkMode ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
              color: isDark ? AppColors.accentLight : AppColors.primary,
              size: 20,
            ),
            tooltip: themeProvider.isDarkMode ? 'Switch to Light Mode' : 'Switch to Dark Mode',
            onPressed: () => themeProvider.toggleTheme(),
          ),
          IconButton(
            icon: const Icon(Icons.account_balance_wallet_outlined, color: AppColors.success),
            tooltip: 'Wallet & Cashout',
            onPressed: () => context.go('/wallet'),
          ),
          IconButton(
            icon: const Icon(Icons.emergency_outlined, color: AppColors.error),
            tooltip: 'Emergency SOS',
            onPressed: () => SosBeaconSheet.show(context),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Duty Toggle
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface(context),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border(context)),
                      boxShadow: isDark
                          ? null
                          : [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.03),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Container(width: 10, height: 10, decoration: BoxDecoration(color: _availColor(_availability), shape: BoxShape.circle)),
                          const SizedBox(width: 8),
                          Text(context.tr('dutyStatus', 'DUTY STATUS'), style: GoogleFonts.outfit(fontSize: 12, color: AppColors.textSec(context), letterSpacing: 1.5)),
                        ]),
                        const SizedBox(height: 12),
                        Row(children: [
                          _DutyBtn(label: context.tr('available', 'Available'), active: _availability == 'AVAILABLE', color: AppColors.available, onTap: () => _toggleAvailability('AVAILABLE')),
                          const SizedBox(width: 8),
                          _DutyBtn(label: context.tr('busy', 'Busy'), active: _availability == 'BUSY', color: AppColors.busy, onTap: () => _toggleAvailability('BUSY')),
                          const SizedBox(width: 8),
                          _DutyBtn(label: context.tr('offline', 'Offline'), active: _availability == 'OFFLINE', color: AppColors.offline, onTap: () => _toggleAvailability('OFFLINE')),
                        ]),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Stats Row — Fixed: never displays raw JSON array toString!
                  Row(children: [
                    _StatCard(
                      label: context.tr('walletCashout', 'Earnings & Cashout'),
                      value: '₹$earnings',
                      icon: Icons.account_balance_wallet,
                      color: AppColors.workerWage,
                      onTap: () => context.go('/wallet'),
                    ),
                    const SizedBox(width: 12),
                    _StatCard(
                      label: context.tr('jobsCompleted', 'Completed Jobs'),
                      value: '$completedCount',
                      icon: Icons.check_circle,
                      color: AppColors.primary,
                    ),
                  ]),
                  const SizedBox(height: 14),

                  // Shortcuts: Surge Heatmap & NCCT Skills Upgrade
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () => context.go('/heatmap'),
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: AppColors.surface(context),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AppColors.warning.withValues(alpha: 0.5)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.whatshot, color: AppColors.warning, size: 18),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        context.tr('demandSurge', 'Surge Heatmap'),
                                        style: GoogleFonts.outfit(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.text(context),
                                        ),
                                      ),
                                      Text(
                                        'Up to +20% Bonus',
                                        style: GoogleFonts.inter(fontSize: 9.5, color: AppColors.warning),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: InkWell(
                          onTap: () => context.go('/skills'),
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: AppColors.surface(context),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AppColors.accent.withValues(alpha: 0.5)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.school, color: AppColors.accent, size: 18),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        context.tr('skillsCertification', 'Skill Upgrade'),
                                        style: GoogleFonts.outfit(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.text(context),
                                        ),
                                      ),
                                      Text(
                                        '₹5K Co-op Stipend',
                                        style: GoogleFonts.inter(fontSize: 9.5, color: AppColors.accent),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Incoming Job Requests (if any)
                  if (incomingJobs.isNotEmpty) ...[
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.warning,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'INCOMING DISPATCH REQUESTS (${incomingJobs.length})',
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.warning,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ...incomingJobs.map((j) {
                      final bId = j['id'] ?? j['booking_id'];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.surface(context),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.warning.withValues(alpha: 0.6), width: 1.5),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: AppColors.warning.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    j['booking_code']?.toString() ?? 'NEW DISPATCH',
                                    style: GoogleFonts.outfit(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.warning,
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  '₹${j['quoted_price'] ?? j['price'] ?? '—'}',
                                  style: GoogleFonts.outfit(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.accent,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              j['service_name']?.toString() ?? 'Service Booking Request',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.text(context),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.person_outline, size: 14, color: AppColors.muted(context)),
                                const SizedBox(width: 4),
                                Text(
                                  j['customer_name']?.toString() ?? 'Citizen Customer',
                                  style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSec(context)),
                                ),
                              ],
                            ),
                            if (j['location_address'] != null || j['location_city'] != null) ...[
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Icon(Icons.location_on_outlined, size: 14, color: AppColors.muted(context)),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      '${j['location_address'] ?? ''}, ${j['location_city'] ?? ''}'.trim(),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.inter(fontSize: 11, color: AppColors.muted(context)),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: bId != null ? () => _declineBooking(bId as int) : null,
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: AppColors.error,
                                      side: const BorderSide(color: AppColors.error),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      padding: const EdgeInsets.symmetric(vertical: 8),
                                    ),
                                    child: Text(context.tr('declineJob', 'Decline'), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: bId != null ? () => _acceptBooking(bId as int) : null,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      padding: const EdgeInsets.symmetric(vertical: 8),
                                    ),
                                    child: Text(context.tr('acceptJob', 'Accept Job'), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }),
                  ],

                  const SizedBox(height: 18),

                  // Active Jobs Section
                  Text(
                    context.tr('activeOrders', 'ACTIVE JOBS'),
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      color: AppColors.textSec(context),
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (activeJobs.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.surface(context),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border(context)),
                      ),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(Icons.inbox, size: 44, color: AppColors.muted(context)),
                            const SizedBox(height: 8),
                            Text(
                              context.tr('noActiveJobs', 'No active jobs right now'),
                              style: TextStyle(color: AppColors.muted(context), fontSize: 13),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              context.tr('offlineNotice', 'Keep duty status Available to receive nearby dispatches'),
                              style: TextStyle(color: AppColors.muted(context), fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ...activeJobs.map((j) => GestureDetector(
                      onTap: () => context.go('/job/${j['booking_id'] ?? j['id']}'),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.surface(context),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border(context)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.work, color: AppColors.primary),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    j['service_name']?.toString() ?? 'Job Service',
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.text(context),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    j['customer_name']?.toString() ?? '',
                                    style: TextStyle(fontSize: 12, color: AppColors.textSec(context)),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '₹${j['quoted_price'] ?? '—'}',
                              style: GoogleFonts.outfit(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.accent,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )),

                  // Recent Completed Jobs Section (if any)
                  if (completedJobsList.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        const Icon(Icons.check_circle_outline, color: AppColors.primary, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          'RECENT COMPLETED JOBS (${completedJobsList.length})',
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textSec(context),
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ...completedJobsList.take(3).map((cj) {
                      final sName = cj['service_name']?.toString() ?? 'Completed Service';
                      final bCode = cj['booking_code']?.toString() ?? 'BKG-DONE';
                      final loc = cj['location_city']?.toString() ?? cj['location_district']?.toString() ?? '';
                      final price = cj['final_price'] ?? cj['quoted_price'] ?? 0;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.surface(context),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.border(context)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.task_alt_rounded, color: AppColors.primary, size: 18),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    sName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.text(context),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '$bCode ${loc.isNotEmpty ? "• $loc" : ""}',
                                    style: GoogleFonts.inter(
                                      fontSize: 11,
                                      color: AppColors.textSec(context),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '₹$price',
                                  style: GoogleFonts.outfit(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.accent,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    '93% Wage Paid',
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ],
              ),
            ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _navIndex,
        onTap: (i) {
          setState(() => _navIndex = i);
          switch (i) {
            case 0: break;
            case 1: context.go('/earnings');
            case 2: context.go('/welfare');
            case 3: context.go('/profile');
          }
        },
        items: [
          BottomNavigationBarItem(icon: const Icon(Icons.dashboard), label: context.tr('dashboardBtn', 'Dashboard')),
          BottomNavigationBarItem(icon: const Icon(Icons.account_balance_wallet), label: context.tr('earningsOverview', 'Earnings')),
          BottomNavigationBarItem(icon: const Icon(Icons.health_and_safety), label: context.tr('welfare', 'Welfare')),
          BottomNavigationBarItem(icon: const Icon(Icons.person), label: context.tr('profile', 'Profile')),
        ],
      ),
    );
  }
}

class _DutyBtn extends StatelessWidget {
  final String label;
  final bool active;
  final Color color;
  final VoidCallback onTap;

  const _DutyBtn({
    required this.label,
    required this.active,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: active ? color.withValues(alpha: 0.15) : AppColors.surfaceAlt(context),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: active ? color : AppColors.border(context),
              width: active ? 1.5 : 1,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: active ? color : AppColors.muted(context),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface(context),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border(context)),
            boxShadow: isDark
                ? null
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(height: 8),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.text(context),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: AppColors.textSec(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
