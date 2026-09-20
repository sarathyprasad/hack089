import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/gov_app_bar.dart';
import '../../providers/society_provider.dart';

class InstitutionalTendersScreen extends StatefulWidget {
  const InstitutionalTendersScreen({super.key});

  @override
  State<InstitutionalTendersScreen> createState() => _InstitutionalTendersScreenState();
}

class _InstitutionalTendersScreenState extends State<InstitutionalTendersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SocietyProvider>().fetchFederationConsoles();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final sProv = context.watch<SocietyProvider>();
    final tenders = sProv.tenders;

    return Scaffold(
      appBar: const GovAppBar(title: 'Institutional Service Tenders'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkInfoBg.withValues(alpha: 0.35) : AppColors.infoLight, 
                borderRadius: BorderRadius.circular(8), 
                border: Border.all(
                  color: isDark 
                      ? AppColors.darkInfoFg.withValues(alpha: 0.4) 
                      : AppColors.infoBlue.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.gavel, color: isDark ? AppColors.darkInfoFg : AppColors.infoBlue, size: 24),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Government departments & institutions reserve cooperative quota contracts for registered federations.',
                      style: TextStyle(
                        fontSize: 12, 
                        color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Open Procurement Opportunities', 
              style: TextStyle(
                fontSize: 15, 
                fontWeight: FontWeight.bold, 
                color: isDark ? AppColors.darkTextPrimary : AppColors.primaryNavy,
              ),
            ),
            const SizedBox(height: 10),

            if (tenders.isEmpty) ...[
              _tenderCard(
                no: 'TDR-OD-2026-084',
                title: 'Annual Electrical & HVAC Maintenance for Capital Hospital',
                dept: 'Health & Family Welfare Dept, Govt of Odisha',
                value: '₹14,50,000',
                deadline: '28 Oct 2026',
                trades: '18 Electricians, 6 HVAC Techs',
                isDark: isDark,
              ),
              const SizedBox(height: 10),
              _tenderCard(
                no: 'TDR-OD-2026-092',
                title: 'Bhubaneswar Smart City Street Lighting & Panel Overhaul',
                dept: 'Housing & Urban Development Department',
                value: '₹22,00,000',
                deadline: '15 Nov 2026',
                trades: '24 Master Linemen & Electricians',
                isDark: isDark,
              ),
            ] else
              ...tenders.map((t) => _tenderCard(
                    no: t.tenderNo,
                    title: t.title,
                    dept: t.department,
                    value: '₹${t.estimatedValue.toStringAsFixed(0)}',
                    deadline: t.submissionDeadline,
                    trades: '${t.tradesRequired} Cooperative Artisans',
                    isDark: isDark,
                  )),
          ],
        ),
      ),
    );
  }

  Widget _tenderCard({
    required String no,
    required String title,
    required String dept,
    required String value,
    required String deadline,
    required String trades,
    required bool isDark,
  }) {
    return Card(
      color: isDark ? AppColors.darkCard : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.borderLight),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.navyLight : AppColors.primaryNavy, 
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(no, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
                Text(
                  'Deadline: $deadline', 
                  style: TextStyle(
                    fontSize: 11, 
                    color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              title, 
              style: TextStyle(
                fontSize: 14, 
                fontWeight: FontWeight.bold, 
                color: isDark ? AppColors.darkTextPrimary : AppColors.primaryNavy,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              dept, 
              style: TextStyle(
                fontSize: 11, 
                color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
              ),
            ),
            const Divider(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Estimated Contract Value', 
                      style: TextStyle(
                        fontSize: 10, 
                        color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                      ),
                    ),
                    Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.accentGreen)),
                  ],
                ),
                ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(backgroundColor: AppColors.accentGreen, content: Text('Expression of Interest submitted for $no')),
                    );
                  },
                  child: const Text('Submit Federation Bid'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
