import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/gov_app_bar.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.backgroundLight,
      appBar: const GovAppBar(title: 'About Prithvi Fix'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 80,
                height: 80,
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.1),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.asset('assets/images/logo_emblem.png', fit: BoxFit.contain),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Center(
              child: Text(
                'Prithvi Fix (ପୃଥିବୀ ଫିକ୍ସ)',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.primaryNavy),
              ),
            ),
            Center(
              child: Text(
                'Digital Public Goods Platform for Labour Cooperatives',
                style: TextStyle(fontSize: 12, color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
              ),
            ),
            const SizedBox(height: 24),

            Text(
              'Institutional Cooperative Mission',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.primaryNavy),
            ),
            const SizedBox(height: 8),
            Text(
              'Unlike profit-extracting private aggregators that levy 20-35% commission fees and treat workers as expendable gig laborers, Prithvi Fix establishes a digital cooperative model where:\n\n'
              '1. Workers are member-owners in their registered District Labour Cooperative Federations.\n'
              '2. Transparent 93-2-5 model guarantees 93% direct living wage, 5% dedicated social security (ESIC Accident Insurance, EPFO pensions), and 2% platform upkeep.\n'
              '3. Citizens receive certified, background-verified services at government-regulated tariffs with zero surge pricing.',
              style: TextStyle(fontSize: 13, height: 1.5, color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
            ),
            const SizedBox(height: 20),

            Card(
              color: isDark ? AppColors.darkCard : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.borderLight),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Statutory Authority & Framework', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.textPrimary)),
                    const SizedBox(height: 8),
                    _statItem('Department', 'Department of Cooperation, Govt. of Odisha', isDark),
                    _statItem('Governing Act', 'Odisha Cooperative Societies Act, 1962 & Rules 1965', isDark),
                    _statItem('Training Partner', 'National Council for Cooperative Training (NCCT)', isDark),
                    _statItem('Accreditation', 'Directorate of Technical Education & Training (DTET)', isDark),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statItem(String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isDark ? AppColors.darkTextMuted : AppColors.textMuted)),
          ),
          Expanded(
            child: Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary)),
          ),
        ],
      ),
    );
  }
}
