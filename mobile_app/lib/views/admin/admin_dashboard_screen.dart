import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/gov_app_bar.dart';
import '../../core/widgets/status_badge.dart';
import '../../core/widgets/gov_loading_indicator.dart';
import '../../models/worker_model.dart';
import '../../providers/admin_provider.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _workerFilter = 'ALL';
  String _selectedDistrictHub = 'KHORDHA';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final aProv = context.read<AdminProvider>();
      aProv.fetchDashboard();
      aProv.fetchAdminWorkers();
      aProv.fetchSmartForecast();
      aProv.fetchSosAlerts();
      aProv.fetchLiveMap();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showDossierModal(WorkerModel worker, bool isDark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF131B38) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          border: Border.all(color: isDark ? const Color(0xFF1E294B) : AppColors.borderLight),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Artisan Statutory Dossier',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppColors.primaryNavy,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: isDark ? Colors.white70 : Colors.black54),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              Divider(color: isDark ? const Color(0xFF1E294B) : AppColors.borderLight),

              // Section 1: Identity
              _auditHeader('1. Identity & Police Background Clearance', isDark),
              _auditRow('Full Legal Name', worker.name, isDark),
              _auditRow('Registered District', '${worker.city}, ${worker.district}', isDark),
              _auditRow('Contact Mobile', worker.phone ?? '+91 98765 43210', isDark),
              _auditRow('Police Verification', 'Verified & Clean Record', isDark, valColor: AppColors.accentGreen),

              const SizedBox(height: 14),
              // Section 2: Trade Licenses
              _auditHeader('2. Trade Licenses & Certifications', isDark),
              _auditRow('Primary Specialization', worker.primaryTrade, isDark),
              _auditRow('Trade Experience', '${worker.experienceYears} Years Active', isDark),
              _auditRow('Trade Skill Certificate No.', 'SKILL-OD-2024-8842 (Certified)', isDark),
              _auditRow('Issuing Institute', 'National Skill Institute Bhubaneswar', isDark),

              const SizedBox(height: 14),
              // Section 3: Tooling & Safety
              _auditHeader('3. Tooling & Safety Compliance', isDark),
              _auditRow('Certified Multimeter & Tester', 'Verified Present', isDark, valColor: AppColors.accentGreen),
              _auditRow('Insulated 1000V Toolset', 'Compliant with IS 13730', isDark, valColor: AppColors.accentGreen),
              _auditRow('Safety Helmet & Boots', 'ISI Mark Certified', isDark, valColor: AppColors.accentGreen),

              const SizedBox(height: 14),
              // Section 4: Direct 93% Escrow Banking
              _auditHeader('4. Direct 93% Escrow Wage Settlement KYC', isDark),
              _auditRow('Bank Name', 'State Bank of India (Bhubaneswar Main Branch)', isDark),
              _auditRow('Account Number', '••••••••8821 (Verified Direct Payout)', isDark),
              _auditRow('IFSC Code', 'SBIN0000042', isDark),

              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        final aProv = context.read<AdminProvider>();
                        await aProv.verifyWorker(worker.id, 'VERIFIED');
                        if (ctx.mounted) Navigator.pop(ctx);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(backgroundColor: AppColors.accentGreen, content: Text('${worker.name} successfully accredited!')),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accentGreen,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('✓ Grant Accreditation', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton(
                    onPressed: () async {
                      final aProv = context.read<AdminProvider>();
                      await aProv.verifyWorker(worker.id, 'REJECTED', rejectionReason: 'Incomplete skill credentials');
                      if (ctx.mounted) Navigator.pop(ctx);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.emergencyRed,
                      side: const BorderSide(color: AppColors.emergencyRed),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('✕ Reject'),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final aProv = context.watch<AdminProvider>();
    final kpis = aProv.kpis;
    final sosCount = aProv.sosAlerts.length;

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
        appBar: const GovAppBar(title: 'Federation Governance Board', showBack: true),
        body: Column(
          children: [
            // 4 Clean Workspaces Navigation
            Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF131B38) : Colors.white,
                border: Border(bottom: BorderSide(color: isDark ? const Color(0xFF1E294B) : AppColors.borderLight)),
              ),
              child: TabBar(
                controller: _tabController,
                indicatorColor: isDark ? AppColors.secondarySaffron : AppColors.primaryNavy,
                indicatorWeight: 3,
                labelColor: isDark ? AppColors.secondarySaffron : AppColors.primaryNavy,
                unselectedLabelColor: isDark ? const Color(0xFF94A3B8) : AppColors.textSecondary,
                labelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                unselectedLabelStyle: const TextStyle(fontSize: 11),
                tabs: [
                  const Tab(icon: Icon(Icons.dashboard_rounded, size: 18), text: 'Overview'),
                  Tab(
                    icon: const Icon(Icons.engineering_rounded, size: 18),
                    text: 'Artisans (${aProv.adminWorkers.length})',
                  ),
                  Tab(
                    icon: Badge(
                      isLabelVisible: sosCount > 0,
                      label: Text('$sosCount'),
                      backgroundColor: AppColors.emergencyRed,
                      child: const Icon(Icons.shield_rounded, size: 18),
                    ),
                    text: 'Safety',
                  ),
                  const Tab(icon: Icon(Icons.auto_graph_rounded, size: 18), text: 'Forecast'),
                ],
              ),
            ),

            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // ─────────────────────────────────────────────────────────────
                  // TAB 1: EXECUTIVE OVERVIEW (4 CLEAN METRIC PILLARS)
                  // ─────────────────────────────────────────────────────────────
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Greeting Card
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF131B38) : Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: isDark ? const Color(0xFF1E294B) : AppColors.borderLight),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF1E294B) : AppColors.infoLight,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  Icons.account_balance_rounded,
                                  color: isDark ? AppColors.secondarySaffron : AppColors.primaryNavy,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Cooperative Federation Command',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: isDark ? Colors.white : AppColors.primaryNavy,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Khordha, Cuttack & Puri • Real-Time Oversight',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: isDark ? const Color(0xFF94A3B8) : AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 14),

                        // 4 Executive Metric Pillars
                        GridView.count(
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 1.25,
                          children: [
                            // Pillar 1: Workforce Pool
                            _executivePillarCard(
                              title: 'Artisan Workforce',
                              value: '${kpis['total_workers'] ?? 18}',
                              subLine: '${kpis['verified_workers'] ?? 14} Verified • ${kpis['pending_workers'] ?? 3} Pending',
                              icon: Icons.engineering_rounded,
                              color: isDark ? AppColors.secondarySaffron : AppColors.primaryNavy,
                              isDark: isDark,
                              onTap: () => _tabController.animateTo(1),
                            ),

                            // Pillar 2: Live Operations
                            _executivePillarCard(
                              title: 'Field Operations',
                              value: '${kpis['active_bookings'] ?? 5}',
                              subLine: 'Active Dispatches • ${kpis['completed_bookings'] ?? 42} Done',
                              icon: Icons.explore_rounded,
                              color: AppColors.accentGreen,
                              isDark: isDark,
                              onTap: () => _tabController.animateTo(1),
                            ),

                            // Pillar 3: Safety & Emergency
                            _executivePillarCard(
                              title: 'Safety & Grievance',
                              value: '$sosCount Alert',
                              subLine: sosCount > 0 ? 'Urgent Distress Beacon' : '24/7 Patrol Nominal',
                              icon: Icons.shield_rounded,
                              color: sosCount > 0 ? AppColors.emergencyRed : AppColors.accentGreen,
                              isDark: isDark,
                              onTap: () => _tabController.animateTo(2),
                            ),

                            // Pillar 4: Escrow & Welfare
                            _executivePillarCard(
                              title: 'Welfare & Escrow',
                              value: '₹1.42L',
                              subLine: '93% Direct Pay • 5% Social Security',
                              icon: Icons.account_balance_wallet_rounded,
                              color: AppColors.workerWageColor,
                              isDark: isDark,
                              onTap: () => _tabController.animateTo(3),
                            ),
                          ],
                        ),

                        const SizedBox(height: 14),

                        // Quick Actions Bar
                        Text(
                          'Quick Actions',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isDark ? const Color(0xFF94A3B8) : AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _quickActionChip(
                                label: 'Verify Artisans',
                                icon: Icons.verified_user_rounded,
                                isDark: isDark,
                                onTap: () => _tabController.animateTo(1),
                              ),
                              const SizedBox(width: 8),
                              _quickActionChip(
                                label: 'Safety Console',
                                icon: Icons.emergency_rounded,
                                isDark: isDark,
                                isEmergency: sosCount > 0,
                                onTap: () => _tabController.animateTo(2),
                              ),
                              const SizedBox(width: 8),
                              _quickActionChip(
                                label: 'AI Forecast',
                                icon: Icons.auto_graph_rounded,
                                isDark: isDark,
                                onTap: () => _tabController.animateTo(3),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 14),

                        // Emergency Status Banner
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: sosCount > 0
                                ? (isDark ? const Color(0xFF2A1215) : AppColors.redLight)
                                : (isDark ? const Color(0xFF0D251D) : AppColors.greenLight),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: sosCount > 0
                                  ? AppColors.emergencyRed.withValues(alpha: 0.4)
                                  : AppColors.accentGreen.withValues(alpha: 0.4),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                sosCount > 0 ? Icons.warning_rounded : Icons.check_circle_rounded,
                                color: sosCount > 0 ? AppColors.emergencyRed : AppColors.accentGreen,
                                size: 20,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      sosCount > 0
                                          ? '⚠️ $sosCount Active Emergency SOS Alert'
                                          : '24/7 Priority Emergency Squad: ALL CIRCUITS NOMINAL',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: sosCount > 0 ? AppColors.emergencyRed : AppColors.accentGreen,
                                      ),
                                    ),
                                    Text(
                                      sosCount > 0
                                          ? 'Artisan distress signal received. Open Safety tab to dispatch patrol.'
                                          : 'Khordha & Cuttack rapid response squads actively on standby.',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: isDark ? Colors.white70 : AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 14),

                        // Regional Federation GIS Telemetry & Live Dispatch Hub
                        _buildGisDispatchSection(context, isDark, aProv),
                      ],
                    ),
                  ),

                  // ─────────────────────────────────────────────────────────────
                  // TAB 2: ARTISAN ACCREDITATION & AUDITS
                  // ─────────────────────────────────────────────────────────────
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                        child: Row(
                          children: [
                            Text(
                              'Filter Status:',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Wrap(
                              spacing: 6,
                              children: ['ALL', 'PENDING', 'VERIFIED'].map((st) {
                                final sel = _workerFilter == st;
                                return ChoiceChip(
                                  label: Text(
                                    st,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: sel
                                          ? (isDark ? Colors.black : Colors.white)
                                          : (isDark ? Colors.white70 : AppColors.textPrimary),
                                    ),
                                  ),
                                  selected: sel,
                                  selectedColor: isDark ? AppColors.secondarySaffron : AppColors.primaryNavy,
                                  backgroundColor: isDark ? const Color(0xFF1E294B) : Colors.grey.shade200,
                                  onSelected: (_) {
                                    setState(() => _workerFilter = st);
                                    aProv.fetchAdminWorkers(status: st == 'ALL' ? null : st);
                                  },
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: aProv.isLoading
                            ? GovLoadingIndicator.card(
                                title: 'Auditing Registered Artisans...',
                                subtitle: 'Verifying trade certificates & police background dossiers',
                                isDark: isDark,
                              )
                            : aProv.adminWorkers.isEmpty
                                ? Center(
                                    child: Text(
                                      'No artisans matching this filter.',
                                      style: TextStyle(fontSize: 12, color: isDark ? Colors.white54 : AppColors.textSecondary),
                                    ),
                                  )
                                : ListView.builder(
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    itemCount: aProv.adminWorkers.length,
                                    itemBuilder: (context, idx) {
                                      final w = aProv.adminWorkers[idx];
                                      return Card(
                                        color: isDark ? const Color(0xFF131B38) : Colors.white,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          side: BorderSide(color: isDark ? const Color(0xFF1E294B) : AppColors.borderLight),
                                        ),
                                        margin: const EdgeInsets.only(bottom: 10),
                                        child: ListTile(
                                          title: Text(
                                            w.name,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13,
                                              color: isDark ? Colors.white : AppColors.textPrimary,
                                            ),
                                          ),
                                          subtitle: Text(
                                            '${w.primaryTrade} • ${w.city}, ${w.district}',
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: isDark ? const Color(0xFF94A3B8) : AppColors.textSecondary,
                                            ),
                                          ),
                                          trailing: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              StatusBadge(status: w.verificationStatus),
                                              const SizedBox(width: 8),
                                              IconButton(
                                                icon: Icon(
                                                  Icons.assignment_ind_outlined,
                                                  color: isDark ? AppColors.secondarySaffron : AppColors.primaryNavy,
                                                ),
                                                tooltip: 'Audit Dossier',
                                                onPressed: () => _showDossierModal(w, isDark),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                      ),
                    ],
                  ),

                  // ─────────────────────────────────────────────────────────────
                  // TAB 3: SAFETY & RAPID EMERGENCY FEEDS
                  // ─────────────────────────────────────────────────────────────
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '24/7 Worker Emergency Safety Feeds',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : AppColors.primaryNavy,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Live distress beacons and immediate dispatch controls.',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? const Color(0xFF94A3B8) : AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 12),

                        if (aProv.sosAlerts.isEmpty)
                          Container(
                            padding: const EdgeInsets.all(20),
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF131B38) : Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: isDark ? const Color(0xFF1E294B) : AppColors.borderLight),
                            ),
                            child: Column(
                              children: [
                                const Icon(Icons.verified_user_rounded, color: AppColors.accentGreen, size: 36),
                                const SizedBox(height: 8),
                                Text(
                                  'Zero Active Distress Signals',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.white : AppColors.primaryNavy,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'All registered artisans are active with normal telemetry.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isDark ? const Color(0xFF94A3B8) : AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: aProv.sosAlerts.length,
                            itemBuilder: (context, idx) {
                              final alert = aProv.sosAlerts[idx];
                              return Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF2A1215) : AppColors.redLight,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppColors.emergencyRed.withValues(alpha: 0.5)),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text('🚨 EMERGENCY DISTRESS BEACON', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.emergencyRed)),
                                        Text('${alert['worker_code'] ?? 'WRK-001'}', style: const TextStyle(fontSize: 10, fontFamily: 'monospace')),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${alert['worker_name'] ?? 'Artisan'} (${alert['worker_district'] ?? 'Khordha'})',
                                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.textPrimary),
                                    ),
                                    Text('Phone: ${alert['worker_phone'] ?? 'N/A'} • ${alert['details'] ?? 'Assistance requested'}', style: const TextStyle(fontSize: 11)),
                                    const SizedBox(height: 8),
                                    ElevatedButton(
                                      onPressed: () {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(backgroundColor: AppColors.emergencyRed, content: Text('Patrol squad dispatched!')),
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.emergencyRed, minimumSize: const Size.fromHeight(36)),
                                      child: const Text('Dispatch Rapid Patrol', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),

                        const SizedBox(height: 16),
                        Text(
                          'Statutory Emergency Helplines',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isDark ? const Color(0xFF94A3B8) : AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _helplineTile('Citizen Grievance Helpline', '1800-345-7788', Icons.support_agent_rounded, isDark),
                        const SizedBox(height: 8),
                        _helplineTile('Artisan Rapid Response Squad', '1800-345-1088', Icons.emergency_rounded, isDark),
                      ],
                    ),
                  ),

                  // ─────────────────────────────────────────────────────────────
                  // TAB 4: AI DEMAND FORECAST & MUTUAL AID
                  // ─────────────────────────────────────────────────────────────
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF131B38) : const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: isDark ? const Color(0xFF1E294B) : const Color(0xFFBFDBFE)),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.auto_graph_rounded, color: isDark ? AppColors.secondarySaffron : AppColors.primaryNavy),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'AI Demand Forecasting: 4-Week Forward Seasonal Projections',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.white : AppColors.primaryNavy,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        _forecastCard('Electrical & Switchgear', 'Khordha Circle', '+42% Expected Demand', 'Monsoon surge directive: mobilize 15 backup linemen', isDark),
                        const SizedBox(height: 8),
                        _forecastCard('Plumbing & Drainage', 'Cuttack Sadar', '+28% Expected Demand', 'Flood risk preparedness in low-lying river wards', isDark),
                        const SizedBox(height: 8),
                        _forecastCard('Appliance & Cooling', 'Puri Heritage Ward', '+35% Expected Demand', 'Rath Yatra tourist footfall load readiness', isDark),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () {
                            aProv.approveMutualAid(1);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(backgroundColor: AppColors.accentGreen, content: Text('Inter-District Mutual Aid transfer authorized!')),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isDark ? AppColors.secondarySaffron : AppColors.primaryNavy,
                            foregroundColor: isDark ? const Color(0xFF0A0F24) : Colors.white,
                            minimumSize: const Size.fromHeight(44),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          icon: const Icon(Icons.sync_alt_rounded, size: 18),
                          label: const Text('Authorize Inter-District Mutual Aid Transfer', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _executivePillarCard({
    required String title,
    required String value,
    required String subLine,
    required IconData icon,
    required Color color,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF131B38) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isDark ? const Color(0xFF1E294B) : AppColors.borderLight),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isDark ? const Color(0xFF94A3B8) : AppColors.textSecondary,
                    ),
                  ),
                ),
                Icon(icon, color: color, size: 18),
              ],
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: color,
                fontFamily: 'monospace',
              ),
            ),
            Text(
              subLine,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 9,
                color: isDark ? Colors.white60 : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _quickActionChip({
    required String label,
    required IconData icon,
    required bool isDark,
    required VoidCallback onTap,
    bool isEmergency = false,
  }) {
    return ActionChip(
      onPressed: onTap,
      avatar: Icon(
        icon,
        size: 16,
        color: isEmergency
            ? AppColors.emergencyRed
            : (isDark ? AppColors.secondarySaffron : AppColors.primaryNavy),
      ),
      label: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: isEmergency
              ? AppColors.emergencyRed
              : (isDark ? Colors.white : AppColors.primaryNavy),
        ),
      ),
      backgroundColor: isEmergency
          ? (isDark ? const Color(0xFF2A1215) : AppColors.redLight)
          : (isDark ? const Color(0xFF131B38) : Colors.white),
      side: BorderSide(
        color: isEmergency
            ? AppColors.emergencyRed
            : (isDark ? const Color(0xFF1E294B) : AppColors.borderLight),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }

  Widget _helplineTile(String label, String number, IconData icon, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF131B38) : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: isDark ? const Color(0xFF1E294B) : AppColors.borderLight),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.accentGreen, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : AppColors.textPrimary,
              ),
            ),
          ),
          Text(
            number,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.accentGreen,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }

  Widget _auditHeader(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: isDark ? AppColors.secondarySaffron : AppColors.primaryNavy,
        ),
      ),
    );
  }

  Widget _auditRow(String label, String value, bool isDark, {Color? valColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: isDark ? const Color(0xFF94A3B8) : AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: valColor ?? (isDark ? Colors.white : AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _forecastCard(String trade, String circle, String growth, String directive, bool isDark) {
    return Card(
      color: isDark ? const Color(0xFF131B38) : Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: isDark ? const Color(0xFF1E294B) : AppColors.borderLight),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  trade,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF0D251D) : AppColors.greenLight,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    growth,
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.accentGreen),
                  ),
                ),
              ],
            ),
            Text(
              circle,
              style: TextStyle(fontSize: 11, color: isDark ? const Color(0xFF94A3B8) : AppColors.textMuted),
            ),
            const SizedBox(height: 6),
            Text(
              directive,
              style: TextStyle(fontSize: 11, color: isDark ? Colors.white70 : AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGisDispatchSection(BuildContext context, bool isDark, AdminProvider aProv) {
    final hubs = [
      {
        'id': 'KHORDHA',
        'name': 'Khordha (Bhubaneswar Hub)',
        'lat': 20.2961,
        'lng': 85.8245,
        'artisans': 12,
        'dispatches': 3,
        'demand': 0.94,
        'demandText': 'Peak Demand (94%)',
        'status': 'HIGH DEMAND',
        'color': AppColors.secondarySaffron,
      },
      {
        'id': 'CUTTACK',
        'name': 'Cuttack District Society',
        'lat': 20.4625,
        'lng': 85.8830,
        'artisans': 6,
        'dispatches': 1,
        'demand': 0.65,
        'demandText': 'Surplus Pool (+4)',
        'status': 'SURPLUS AID',
        'color': const Color(0xFF0284C7),
      },
      {
        'id': 'PURI',
        'name': 'Puri Coastal Federation',
        'lat': 19.8135,
        'lng': 85.8312,
        'artisans': 4,
        'dispatches': 0,
        'demand': 0.58,
        'demandText': 'Tourism Load (58%)',
        'status': 'SEASONAL',
        'color': const Color(0xFF6366F1),
      },
    ];

    final currentHub = hubs.firstWhere(
      (h) => h['id'] == _selectedDistrictHub,
      orElse: () => hubs.first,
    );

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF131B38) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isDark ? const Color(0xFF1E294B) : AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header & GPS Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.location_on_rounded, size: 18, color: isDark ? AppColors.secondarySaffron : AppColors.primaryNavy),
                  const SizedBox(width: 8),
                  Text(
                    'Regional GIS Dispatch & Telemetry',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppColors.primaryNavy,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF0D251D) : AppColors.greenLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.accentGreen.withValues(alpha: 0.3)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(radius: 3, backgroundColor: AppColors.accentGreen),
                    SizedBox(width: 4),
                    Text(
                      'GPS Sync: OK',
                      style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.accentGreen),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Interactive tracking of active artisans, clusters, and emergency zones.',
            style: TextStyle(fontSize: 11, color: isDark ? const Color(0xFF94A3B8) : AppColors.textSecondary),
          ),
          const SizedBox(height: 12),

          // District Hub Selector Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: hubs.map((hub) {
                final isSelected = _selectedDistrictHub == hub['id'];
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(
                      '${hub['name']}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isSelected
                            ? (isDark ? Colors.black : Colors.white)
                            : (isDark ? Colors.white70 : AppColors.textPrimary),
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: isDark ? AppColors.secondarySaffron : AppColors.primaryNavy,
                    backgroundColor: isDark ? const Color(0xFF0A0F24) : AppColors.neutralBg,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => _selectedDistrictHub = hub['id'] as String);
                      }
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),

          // Selected Hub Status Card
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0A0F24) : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: isDark ? const Color(0xFF1E294B) : AppColors.borderLight),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      currentHub['name'] as String,
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.primaryNavy),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: (currentHub['color'] as Color).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        currentHub['demandText'] as String,
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: currentHub['color'] as Color),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      'Active Artisans: ',
                      style: TextStyle(fontSize: 11, color: isDark ? const Color(0xFF94A3B8) : AppColors.textSecondary),
                    ),
                    Text(
                      '${currentHub['artisans']}',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.textPrimary),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Dispatches: ',
                      style: TextStyle(fontSize: 11, color: isDark ? const Color(0xFF94A3B8) : AppColors.textSecondary),
                    ),
                    Text(
                      '${currentHub['dispatches']} Active',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.textPrimary),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.explore_outlined, size: 12, color: isDark ? AppColors.secondarySaffron : AppColors.primaryNavy),
                    const SizedBox(width: 4),
                    Text(
                      'GPS Ref: ${currentHub['lat']}° N, ${currentHub['lng']}° E',
                      style: const TextStyle(fontSize: 10, fontFamily: 'monospace', color: AppColors.accentGreen),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: currentHub['demand'] as double,
                    backgroundColor: isDark ? const Color(0xFF1E294B) : Colors.grey.shade300,
                    valueColor: AlwaysStoppedAnimation<Color>(currentHub['color'] as Color),
                    minHeight: 5,
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.sync_alt_rounded, size: 14),
                    label: const Text('Authorize Inter-Cooperative Surplus Rebalance', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: AppColors.accentGreen,
                          content: Text('Inter-Cooperative surplus capacity (+4) rebalanced toward ${currentHub['name']}!'),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: isDark ? AppColors.secondarySaffron : AppColors.primaryNavy,
                      side: BorderSide(color: isDark ? AppColors.secondarySaffron : AppColors.primaryNavy),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // High Demand Clusters
          Text(
            'Real-Time Demand Density Clusters',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: isDark ? const Color(0xFF94A3B8) : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          Column(
            children: [
              _clusterTile('Patia IT Corridor (Bhubaneswar)', 'Electrical & AC', 'HIGH (94%)', AppColors.secondarySaffron, isDark),
              const SizedBox(height: 4),
              _clusterTile('Jaydev Vihar Residential Hub', 'Plumbing & Deep Cleaning', 'HIGH (88%)', AppColors.secondarySaffron, isDark),
              const SizedBox(height: 4),
              _clusterTile('Saheed Nagar Commercial Cluster', 'Carpentry & Maintenance', 'MODERATE (72%)', const Color(0xFF0284C7), isDark),
            ],
          ),
          const SizedBox(height: 14),

          // Live On-Duty Artisans Telemetry & Quick Dispatch
          Text(
            'Live Field Artisans & Telemetry',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: isDark ? const Color(0xFF94A3B8) : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          Column(
            children: [
              _artisanTelemetryTile(
                name: 'Ramesh Mohapatra',
                code: 'WRK-2026-001',
                trade: 'Electrical & AC',
                lat: 20.2961,
                lng: 85.8245,
                rating: '4.9 ★',
                status: 'AVAILABLE',
                isDark: isDark,
                onDispatch: () => _openQuickDispatchModal(context, isDark, 'Ramesh Mohapatra', 'WRK-2026-001', 'Electrical & AC'),
              ),
              const SizedBox(height: 6),
              _artisanTelemetryTile(
                name: 'Bikash Das',
                code: 'WRK-2026-002',
                trade: 'Plumbing & Sanitation',
                lat: 20.3012,
                lng: 85.8310,
                rating: '4.8 ★',
                status: 'ON JOB',
                isDark: isDark,
                onDispatch: () => _openQuickDispatchModal(context, isDark, 'Bikash Das', 'WRK-2026-002', 'Plumbing & Sanitation'),
              ),
              const SizedBox(height: 6),
              _artisanTelemetryTile(
                name: 'Kailash Sahoo',
                code: 'WRK-2026-003',
                trade: 'Carpentry & Maintenance',
                lat: 20.2870,
                lng: 85.8450,
                rating: '5.0 ★',
                status: 'AVAILABLE',
                isDark: isDark,
                onDispatch: () => _openQuickDispatchModal(context, isDark, 'Kailash Sahoo', 'WRK-2026-003', 'Carpentry & Maintenance'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _clusterTile(String clusterName, String trade, String density, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0A0F24) : AppColors.neutralBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: isDark ? const Color(0xFF1E294B) : AppColors.borderLight),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  clusterName,
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.textPrimary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  trade,
                  style: TextStyle(fontSize: 10, color: isDark ? const Color(0xFF94A3B8) : AppColors.textMuted),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              density,
              style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _artisanTelemetryTile({
    required String name,
    required String code,
    required String trade,
    required double lat,
    required double lng,
    required String rating,
    required String status,
    required bool isDark,
    required VoidCallback onDispatch,
  }) {
    final isAvailable = status == 'AVAILABLE';
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0A0F24) : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isAvailable
              ? (isDark ? AppColors.accentGreen.withValues(alpha: 0.4) : AppColors.accentGreen.withValues(alpha: 0.3))
              : (isDark ? const Color(0xFF1E294B) : AppColors.borderLight),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: isDark ? const Color(0xFF1E294B) : AppColors.infoLight,
            child: Text(
              name.isNotEmpty ? name[0] : 'W',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: isDark ? AppColors.secondarySaffron : AppColors.primaryNavy,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      name,
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.textPrimary),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      rating,
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.secondarySaffron),
                    ),
                  ],
                ),
                Text(
                  '$code • $trade',
                  style: TextStyle(fontSize: 10, color: isDark ? const Color(0xFF94A3B8) : AppColors.textSecondary),
                ),
                Text(
                  'GPS: ${lat.toStringAsFixed(4)}° N, ${lng.toStringAsFixed(4)}° E',
                  style: const TextStyle(fontSize: 9, fontFamily: 'monospace', color: AppColors.accentGreen),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isAvailable
                      ? (isDark ? const Color(0xFF0D251D) : AppColors.greenLight)
                      : (isDark ? const Color(0xFF2A1C0A) : const Color(0xFFFEF3C7)),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: isAvailable ? AppColors.accentGreen : const Color(0xFFD97706),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              InkWell(
                onTap: onDispatch,
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.secondarySaffron : AppColors.primaryNavy,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    isAvailable ? '⚡ Dispatch' : 'Track Route',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.black : Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _openQuickDispatchModal(BuildContext context, bool isDark, String name, String code, String trade) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF131B38) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          border: Border.all(color: isDark ? const Color(0xFF1E294B) : AppColors.borderLight),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.flash_on_rounded, color: AppColors.secondarySaffron, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Quick Dispatch Terminal',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.primaryNavy),
                    ),
                  ],
                ),
                IconButton(
                  icon: Icon(Icons.close, color: isDark ? Colors.white70 : Colors.black54),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            Divider(color: isDark ? const Color(0xFF1E294B) : AppColors.borderLight),
            const SizedBox(height: 8),
            Text(
              'Artisan: $name ($code)',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.textPrimary),
            ),
            Text(
              'Trade: $trade • Background Verified',
              style: TextStyle(fontSize: 11, color: isDark ? const Color(0xFF94A3B8) : AppColors.textSecondary),
            ),
            const SizedBox(height: 14),
            Text(
              'Assign to Pending Citizen Order:',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isDark ? const Color(0xFF94A3B8) : AppColors.textSecondary),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0A0F24) : AppColors.neutralBg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: isDark ? const Color(0xFF1E294B) : AppColors.borderLight),
              ),
              child: Row(
                children: [
                  const Icon(Icons.receipt_long_rounded, size: 20, color: AppColors.secondarySaffron),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ORD-2026-101: AC Overhaul & Filter Service',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.textPrimary),
                        ),
                        Text(
                          'Patia IT Corridor, Bhubaneswar • Citizen: Ananya Mohanty',
                          style: TextStyle(fontSize: 10, color: isDark ? const Color(0xFF94A3B8) : AppColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: AppColors.accentGreen,
                      content: Text('Successfully dispatched $name to ORD-2026-101! Telemetry route activated.'),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? AppColors.secondarySaffron : AppColors.primaryNavy,
                  foregroundColor: isDark ? Colors.black : Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Confirm Dispatch & Activate Route', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
