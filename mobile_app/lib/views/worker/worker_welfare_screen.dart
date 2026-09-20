import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/gov_app_bar.dart';
import '../../providers/worker_portal_provider.dart';

class WorkerWelfareScreen extends StatefulWidget {
  const WorkerWelfareScreen({super.key});

  @override
  State<WorkerWelfareScreen> createState() => _WorkerWelfareScreenState();
}

class _WorkerWelfareScreenState extends State<WorkerWelfareScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WorkerPortalProvider>().fetchWelfare();
    });
  }

  @override
  Widget build(BuildContext context) {
    final wp = context.watch<WorkerPortalProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.backgroundLight,
      appBar: const GovAppBar(title: 'Social Welfare & Safety Net'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 5% Escrow Welfare Pool Banner
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.navyDark, AppColors.primaryNavy],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'COOPERATIVE MINI-PF WALLET',
                        style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: AppColors.secondarySaffron, borderRadius: BorderRadius.circular(4)),
                        child: const Text('ACTIVE', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.black)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '₹3,842.50',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Accumulated via statutory 5% welfare contribution on every completed work order.',
                    style: TextStyle(fontSize: 11, color: Colors.white70),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Text(
              'Enrolled Social Security Protections',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.primaryNavy),
            ),
            const SizedBox(height: 8),

            _welfareCard(
              title: 'ESIC Group Accident Insurance',
              subtitle: 'Coverage up to ₹2,00,000 for on-duty injury or disability',
              tag: 'COVERED',
              tagColor: isDark ? AppColors.darkGreenFg : AppColors.accentGreen,
              icon: Icons.shield,
              isDark: isDark,
            ),
            const SizedBox(height: 8),
            _welfareCard(
              title: 'EPFO Cooperative Pension Account',
              subtitle: 'Statutory retirement deposit managed by District Federation',
              tag: 'CONTRIBUTING',
              tagColor: isDark ? AppColors.darkBlueFg : AppColors.infoBlue,
              icon: Icons.savings_outlined,
              isDark: isDark,
            ),
            const SizedBox(height: 8),
            _welfareCard(
              title: 'Biju Swasthya Kalyan Yojana (BSKY)',
              subtitle: 'Universal health coverage linked with worker Aadhaar',
              tag: 'LINKED',
              tagColor: isDark ? AppColors.darkAmberFg : AppColors.warningAmber,
              icon: Icons.health_and_safety,
              isDark: isDark,
            ),

            const SizedBox(height: 24),

            Text(
              'Government Trade Upskilling & NCCT Workshops',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.primaryNavy),
            ),
            const SizedBox(height: 8),

            Card(
              color: isDark ? AppColors.darkCard : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.borderLight),
              ),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'National Solar Mission & Rooftop PV Wiring',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.textPrimary),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '3-Day certified training organized by DTET & NCCT Bhubaneswar. Daily stipend provided.',
                      style: TextStyle(fontSize: 12, color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () async {
                        final ok = await wp.enrollWelfare({'workshop': 'National Solar Mission', 'workerId': 7});
                        if (context.mounted && ok) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(backgroundColor: AppColors.accentGreen, content: Text('Enrolled in Solar PV Workshop successfully!')),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark ? AppColors.secondarySaffron : AppColors.primaryNavy,
                        foregroundColor: isDark ? Colors.black : Colors.white,
                      ),
                      child: const Text('1-Click Workshop Enrollment'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _welfareCard({
    required String title,
    required String subtitle,
    required String tag,
    required Color tagColor,
    required IconData icon,
    required bool isDark,
  }) {
    return Card(
      color: isDark ? AppColors.darkCard : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.borderLight),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: tagColor.withValues(alpha: isDark ? 0.2 : 0.1),
              child: Icon(icon, color: tagColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.textPrimary)),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: tagColor.withValues(alpha: isDark ? 0.2 : 0.1), borderRadius: BorderRadius.circular(4)),
                        child: Text(tag, style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: tagColor)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(subtitle, style: TextStyle(fontSize: 11, color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
