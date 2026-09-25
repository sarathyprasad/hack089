import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants/app_colors.dart';

class WelfareScreen extends StatelessWidget {
  const WelfareScreen({super.key});

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
          title: Text('Welfare Centre', style: GoogleFonts.outfit()),
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
      body: ListView(padding: const EdgeInsets.all(16), children: [
        _WelfareCard(title: 'ESIC Accident Insurance', desc: 'Govt. accident cover up to ₹5,00,000', icon: Icons.health_and_safety, color: AppColors.error, enrolled: true),
        _WelfareCard(title: 'EPFO Pension Scheme', desc: 'Monthly pension contribution via cooperative', icon: Icons.savings, color: AppColors.workerWage, enrolled: true),
        _WelfareCard(title: 'NSDC Skill Workshops', desc: 'Free vocational upskilling & certifications', icon: Icons.school, color: AppColors.primary, enrolled: false),
        _WelfareCard(title: 'Health Card Program', desc: 'Family health benefits through ESIC', icon: Icons.local_hospital, color: AppColors.accent, enrolled: false),
      ]),
    ),
  );
}
}

class _WelfareCard extends StatelessWidget {
  final String title, desc; final IconData icon; final Color color; final bool enrolled;
  const _WelfareCard({required this.title, required this.desc, required this.icon, required this.color, required this.enrolled});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.cardSurface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.borderDark)),
      child: Row(children: [
        Container(width: 48, height: 48, decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: color, size: 24)),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          const SizedBox(height: 4),
          Text(desc, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        ])),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: enrolled ? AppColors.successBg : AppColors.infoBg,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(enrolled ? 'Enrolled' : 'Enroll', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: enrolled ? AppColors.available : AppColors.info)),
        ),
      ]),
    );
  }
}
