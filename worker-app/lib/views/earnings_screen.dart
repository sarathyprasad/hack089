import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants/app_colors.dart';
import '../core/localization/app_localizations.dart';

class EarningsScreen extends StatelessWidget {
  const EarningsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        if (context.canPop()) {
          context.pop();
        } else {
          context.go('/dashboard');
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.scaffoldBg,
        appBar: AppBar(
          title: Text(context.tr('earningsOverview', 'Earnings Ledger'), style: GoogleFonts.outfit()),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            tooltip: 'Back',
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/dashboard');
              }
            },
          ),
        ),
        body: Padding(padding: const EdgeInsets.all(16), child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Total Earnings Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF15803D), Color(0xFF16A34A)]),
                borderRadius: BorderRadius.circular(14),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(context.tr('totalEarnings', 'TOTAL EARNINGS'), style: GoogleFonts.outfit(fontSize: 11, color: Colors.white60, letterSpacing: 1.5)),
              const SizedBox(height: 8),
              Text('₹24,500', style: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.w700, color: Colors.white)),
              const SizedBox(height: 4),
              const Text('This month • 93% direct wage', style: TextStyle(fontSize: 12, color: Colors.white70)),
            ]),
          ),
          const SizedBox(height: 20),

          // Split Breakdown
          Text(context.tr('splitBreakdown', 'PAYOUT SPLIT'), style: GoogleFonts.outfit(fontSize: 12, color: AppColors.textSecondary, letterSpacing: 1.5)),
          const SizedBox(height: 12),
          _SplitRow(label: context.tr('coopShare', 'Worker Direct Wage (93%)'), value: '₹22,785', color: AppColors.workerWage),
          _SplitRow(label: context.tr('welfareFund', 'PF & Insurance (5%)'), value: '₹1,225', color: AppColors.welfareFund),
          _SplitRow(label: context.tr('platformFee', 'Platform Fee (2%)'), value: '₹490', color: AppColors.platformFee),
        ],
      )),
    ),
  );
}
}

class _SplitRow extends StatelessWidget {
  final String label, value; final Color color;
  const _SplitRow({required this.label, required this.value, required this.color});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.cardSurface, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.borderDark)),
      child: Row(children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
        const SizedBox(width: 10),
        Expanded(child: Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary))),
        Text(value, style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
      ]),
    );
  }
}
