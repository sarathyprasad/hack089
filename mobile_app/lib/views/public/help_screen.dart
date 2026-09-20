import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/gov_app_bar.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  Future<void> _callHelpline() async {
    final uri = Uri.parse('tel:18003456789');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final List<Map<String, String>> faqs = [
      {
        'q': 'How does the 93-2-5 escrow model protect me?',
        'a': 'Every payment is deposited into an official cooperative escrow account. 93% goes directly to the artisan upon entering the completion OTP. 5% is remitted to state welfare funds (ESIC & EPFO) for worker safety nets, and 2% covers platform upkeep.'
      },
      {
        'q': 'What is the 30-Day Workmanship Guarantee?',
        'a': 'All completed jobs are covered by a statutory 30-day rework warranty. If any defect arises within 30 days, the cooperative society dispatches a senior master artisan for complimentary rectification.'
      },
      {
        'q': 'Why are OTP handshakes required?',
        'a': 'The 4-digit Arrival OTP guarantees the worker arrived at the registered address before work begins. The 4-digit Completion OTP ensures the citizen has inspected and approved the repairs before payment escrow is released.'
      },
      {
        'q': 'How are artisan spare parts prices regulated?',
        'a': 'Artisans can only charge up to the government-approved maximum ceiling rates for parts from our locked catalog. Overcharging results in immediate suspension from the cooperative directory.'
      }
    ];

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.backgroundLight,
      appBar: const GovAppBar(title: 'Help & Grievance Centre'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Helpline Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : AppColors.primaryNavy,
                borderRadius: BorderRadius.circular(10),
                border: isDark ? Border.all(color: AppColors.darkBorder) : null,
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.support_agent, color: isDark ? AppColors.secondarySaffron : Colors.white, size: 28),
                      const SizedBox(width: 10),
                      Text(
                        'Odisha State Cooperative Helpline',
                        style: TextStyle(color: isDark ? Colors.white : Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Available 24/7 for citizen grievances, artisan emergencies, and statutory inquiries.',
                    style: TextStyle(color: isDark ? AppColors.darkTextSecondary : Colors.white70, fontSize: 12),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: _callHelpline,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondarySaffron,
                      foregroundColor: Colors.black,
                      minimumSize: const Size.fromHeight(40),
                    ),
                    icon: const Icon(Icons.phone, size: 18),
                    label: const Text('Dial Toll-Free: 1800-345-6789', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Text(
              'Frequently Asked Questions (FAQ)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.primaryNavy),
            ),
            const SizedBox(height: 8),

            ...faqs.map((faq) => Card(
                  color: isDark ? AppColors.darkCard : Colors.white,
                  margin: const EdgeInsets.only(bottom: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.borderLight),
                  ),
                  child: ExpansionTile(
                    title: Text(
                      faq['q']!,
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isDark ? Colors.white : AppColors.textPrimary),
                    ),
                    iconColor: isDark ? AppColors.secondarySaffron : AppColors.primaryNavy,
                    collapsedIconColor: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: Text(
                          faq['a']!,
                          style: TextStyle(fontSize: 12, color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary, height: 1.4),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
