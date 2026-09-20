import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/gov_app_bar.dart';
import '../../providers/society_provider.dart';

class FederationPortalScreen extends StatefulWidget {
  const FederationPortalScreen({super.key});

  @override
  State<FederationPortalScreen> createState() => _FederationPortalScreenState();
}

class _FederationPortalScreenState extends State<FederationPortalScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SocietyProvider>().fetchFederationConsoles();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final sProv = context.watch<SocietyProvider>();
    final adminData = sProv.federationAdminData;
    final treasData = sProv.federationTreasurerData;

    return Scaffold(
      appBar: const GovAppBar(title: 'Federation Dual Consoles'),
      body: Column(
        children: [
          Container(
            color: isDark ? AppColors.darkCard : Colors.white,
            child: TabBar(
              controller: _tabController,
              indicatorColor: isDark ? AppColors.secondarySaffron : AppColors.primaryNavy,
              labelColor: isDark ? AppColors.secondarySaffron : AppColors.primaryNavy,
              unselectedLabelColor: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
              tabs: const [
                Tab(icon: Icon(Icons.admin_panel_settings, size: 18), text: 'Admin Console'),
                Tab(icon: Icon(Icons.account_balance, size: 18), text: 'Treasurer Console'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _adminConsoleView(adminData, isDark),
                _treasurerConsoleView(treasData, isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _adminConsoleView(Map data, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _metricTile('AFFILIATED SOCIETIES', '14', Icons.apartment, isDark ? AppColors.secondarySaffron : AppColors.primaryNavy, isDark),
              const SizedBox(width: 10),
              _metricTile('MEMBER ARTISANS', '284', Icons.groups, AppColors.accentGreen, isDark),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Primary Society Affiliation Roster', 
            style: TextStyle(
              fontSize: 15, 
              fontWeight: FontWeight.bold, 
              color: isDark ? AppColors.darkTextPrimary : AppColors.primaryNavy,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            color: isDark ? AppColors.darkCard : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.borderLight),
            ),
            child: Column(
              children: [
                _societyTile('Khordha Artisan Labour Cooperative Society', 'Bhubaneswar', '84 Artisans', 'Grade A', isDark),
                const Divider(height: 1),
                _societyTile('Cuttack City Trade Artisans Sahakari Samiti', 'Cuttack', '112 Artisans', 'Grade A', isDark),
                const Divider(height: 1),
                _societyTile('Puri District Heritage Artisans Cooperative', 'Puri', '68 Artisans', 'Grade B+', isDark),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => context.go('/federation/tenders'),
            icon: const Icon(Icons.gavel, size: 18),
            label: const Text('View Government Institutional Tenders'),
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark ? AppColors.primaryNavy : AppColors.primaryNavy,
              minimumSize: const Size.fromHeight(42),
            ),
          ),
        ],
      ),
    );
  }

  Widget _treasurerConsoleView(Map data, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [AppColors.navyDark, AppColors.primaryNavy]),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('STATUTORY WELFARE FUND RESERVES', style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold)),
                SizedBox(height: 6),
                Text('₹4,82,450.00', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Colors.white)),
                SizedBox(height: 4),
                Text('Audited Escrow Remittances under Section 43 of Odisha Cooperative Societies Act', style: TextStyle(color: Colors.white70, fontSize: 11)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _metricTile('5% ESIC LEVY POOL', '₹2.41 L', Icons.health_and_safety, AppColors.warningAmber, isDark),
              const SizedBox(width: 10),
              _metricTile('AUDIT SCORE', '98.4%', Icons.verified, AppColors.accentGreen, isDark),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Recent Statutory Remittances', 
            style: TextStyle(
              fontSize: 15, 
              fontWeight: FontWeight.bold, 
              color: isDark ? AppColors.darkTextPrimary : AppColors.primaryNavy,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            color: isDark ? AppColors.darkCard : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.borderLight),
            ),
            child: Column(
              children: [
                _remittanceTile('ESIC Accident Insurance Premium', '₹42,500', 'Disbursed to ESIC Odisha', isDark),
                const Divider(height: 1),
                _remittanceTile('Mini-PF Quarterly Interest Credit', '₹18,200', 'Credited to 284 Worker Wallets', isDark),
                const Divider(height: 1),
                _remittanceTile('NCCT Trade Workshop Subsidy', '₹25,000', 'Directorate of Technical Education', isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _metricTile(String title, String val, IconData icon, Color color, bool isDark) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : Colors.white, 
          borderRadius: BorderRadius.circular(8), 
          border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.borderLight),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 6),
            Text(val, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
            Text(
              title, 
              style: TextStyle(
                fontSize: 9, 
                fontWeight: FontWeight.bold, 
                color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _societyTile(String name, String district, String members, String grade, bool isDark) {
    return ListTile(
      dense: true,
      title: Text(
        name, 
        style: TextStyle(
          fontSize: 13, 
          fontWeight: FontWeight.w600,
          color: isDark ? AppColors.darkTextPrimary : null,
        ),
      ),
      subtitle: Text(
        '$district • $members', 
        style: TextStyle(
          fontSize: 11, 
          color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
        ),
      ),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkGreenBg.withValues(alpha: 0.4) : AppColors.greenLight, 
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(grade, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.accentGreen)),
      ),
    );
  }

  Widget _remittanceTile(String title, String amount, String desc, bool isDark) {
    return ListTile(
      dense: true,
      title: Text(
        title, 
        style: TextStyle(
          fontSize: 13, 
          fontWeight: FontWeight.w600,
          color: isDark ? AppColors.darkTextPrimary : null,
        ),
      ),
      subtitle: Text(
        desc, 
        style: TextStyle(
          fontSize: 11, 
          color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
        ),
      ),
      trailing: Text(amount, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.accentGreen)),
    );
  }
}
