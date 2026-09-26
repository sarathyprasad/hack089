import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants/app_colors.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        if (context.canPop()) {
          context.pop();
        } else {
          context.go('/home');
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.scaffoldBg,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            tooltip: 'Back',
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/home');
              }
            },
          ),
          title: Text(
            'Citizen Help & Support',
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Contact Support Hero Banner
            _buildContactHero(context),

            const SizedBox(height: 20),

            // Emergency Support Quick Buttons
            Row(
              children: [
                Expanded(
                  child: _buildContactChannel(
                    context: context,
                    icon: Icons.phone_in_talk,
                    title: 'Toll-Free Helpline',
                    subtitle: '1800-345-FIX (349)',
                    color: AppColors.primary,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Dialing Toll-Free Cooperative Helpline: 1800-345-349...')),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildContactChannel(
                    context: context,
                    icon: Icons.chat,
                    title: 'WhatsApp Desk',
                    subtitle: '+91 94370 11222',
                    color: const Color(0xFF0D9488),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Opening Official WhatsApp Support Desk...')),
                      );
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Frequently Asked Questions
            Text(
              'FREQUENTLY ASKED QUESTIONS',
              style: GoogleFonts.outfit(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 12),

            _buildFaqTile(
              question: 'What is the 30-Day Free Rework Guarantee?',
              answer: 'Under the Odisha Cooperative Societies framework, any recurring defect reported within 30 days of service completion is revisited and corrected 100% free of charge by a certified master artisan.',
            ),
            _buildFaqTile(
              question: 'Why does Prithvi Fix have Zero Surge Pricing?',
              answer: 'Unlike private gig portals that charge 2x to 3x surge during heavy rains, festival seasons, or high demand, cooperative tariffs are statutory and strictly regulated by the District Cooperative Officer (DCO).',
            ),
            _buildFaqTile(
              question: 'How do Arrival and Completion OTPs protect me?',
              answer: 'The 4-digit Arrival OTP ensures work starts only after the artisan physically reaches your doorstep. The Completion OTP ensures funds are disbursed from escrow only after you inspect the work and confirm satisfaction.',
            ),
            _buildFaqTile(
              question: 'How does the 93-2-5 fair wage formula work?',
              answer: '93% of every rupee paid goes directly to the artisan as their take-home wage. 5% is deposited into the Odisha Prithvi Welfare Fund for family healthcare, child education, and pensions. 2% maintains state technology servers.',
            ),

            const SizedBox(height: 20),

            // Dispute / Grievance Escalation Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.gavel, color: AppColors.warning, size: 20),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Statutory Grievance Redressal',
                        style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'If you have an unresolved dispute with an artisan or society, you have a statutory right to submit an appeal to the District Cooperative Dispute Tribunal.',
                    style: GoogleFonts.inter(fontSize: 11.5, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _showGrievanceDialog(context),
                      icon: const Icon(Icons.rate_review_outlined),
                      label: const Text('File Formal Grievance with Registrar'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.warning,
                        side: const BorderSide(color: AppColors.warning),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    ),
  );
}

  Widget _buildContactHero(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0284C7), Color(0xFF0369A1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.support_agent, color: Colors.white, size: 28),
              const SizedBox(width: 10),
              Text(
                '24/7 Citizen Seva Support',
                style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'We are here to assist with booking questions, emergency repairs, invoice clarifications, and artisan disputes.',
            style: GoogleFonts.inter(fontSize: 12, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildContactChannel({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(title, style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold)),
            Text(subtitle, style: GoogleFonts.inter(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _buildFaqTile({required String question, required String answer}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: ExpansionTile(
        title: Text(
          question,
          style: GoogleFonts.outfit(fontSize: 13.5, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          Text(
            answer,
            style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary, height: 1.4),
          ),
        ],
      ),
    );
  }

  void _showGrievanceDialog(BuildContext context) {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Register Tribunal Grievance', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Your grievance will be forwarded directly to the District Cooperative Officer (DCO) Tribunal under the Odisha Cooperative Societies Act.',
              style: GoogleFonts.inter(fontSize: 11.5, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: titleCtrl,
              decoration: const InputDecoration(labelText: 'Grievance Subject / Booking ID'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: descCtrl,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Detailed Explanation'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  backgroundColor: AppColors.primary,
                  content: Text('Grievance registered. Tracking ID: GRV-2026-OD-092'),
                ),
              );
            },
            child: const Text('Submit to Tribunal'),
          ),
        ],
      ),
    );
  }
}
