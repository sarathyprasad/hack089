import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/api_endpoints.dart';
import '../core/network/api_client.dart';

class SkillsTrainingScreen extends StatefulWidget {
  const SkillsTrainingScreen({super.key});

  @override
  State<SkillsTrainingScreen> createState() => _SkillsTrainingScreenState();
}

class _SkillsTrainingScreenState extends State<SkillsTrainingScreen> {
  bool _isEnrolling = false;

  final List<Map<String, dynamic>> _trainingModules = [
    {
      'title': 'Level 4 Master EV & Inverter Installation',
      'institute': 'NCCT Regional Institute of Cooperative Management, BBSR',
      'duration': '2 Weeks (Part-time)',
      'stipend': '₹5,000 Govt Allowance',
      'skills': ['EV Fast Chargers', 'Solar Inverter Grid Tie', 'Three-Phase Safety'],
      'isEnrolled': false,
    },
    {
      'title': 'Commercial Multi-Split HVAC Overhaul',
      'institute': 'State Skill Development Authority (OSDA)',
      'duration': '3 Weeks',
      'stipend': '₹6,000 Govt Allowance',
      'skills': ['Variable Refrigerant Flow (VRF)', 'Leak Detection', 'Smart Thermostats'],
      'isEnrolled': true,
    },
    {
      'title': 'Precision Drainage & Trenchless Sewer Inspection',
      'institute': 'National Council for Cooperative Training',
      'duration': '10 Days',
      'stipend': '₹4,000 Govt Allowance',
      'skills': ['Camera Pipe Inspection', 'Electro-Fusion Jointing'],
      'isEnrolled': false,
    },
  ];

  Future<void> _enrollInCourse(Map<String, dynamic> course) async {
    setState(() => _isEnrolling = true);

    try {
      await ApiClient().post(
        ApiEndpoints.ncctApply,
        data: {'course_name': course['title']},
      );
    } catch (_) {}

    if (mounted) {
      setState(() {
        course['isEnrolled'] = true;
        _isEnrolling = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.success,
          content: Text('Nominated for ${course["title"]}! DCO Registrar endorsed.'),
        ),
      );
    }
  }

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
          title: Text(
            'NCCT Skill Upgrade & Certification',
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current Certificate Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.accent.withAlpha(100)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withAlpha(30),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.accent),
                        ),
                        child: Text(
                          'NSDC LEVEL 3 CERTIFIED',
                          style: GoogleFonts.outfit(
                            color: AppColors.accent,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Icon(Icons.workspace_premium, color: AppColors.accent, size: 28),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Certified Domestic Wireman & Diagnostic Artisan',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Cooperative Reg #OD-KHD-W-042 • Valid Thru: 2028',
                    style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 11),
                  ),
                  const SizedBox(height: 14),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: const LinearProgressIndicator(
                      value: 0.65,
                      backgroundColor: AppColors.cardSurfaceAlt,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent),
                      minHeight: 6,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '65% Progress toward Level 4 Master Artisan Qualification (+25% wage band)',
                    style: GoogleFonts.inter(color: AppColors.accentLight, fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),

            Text(
              'FREE STATE COOPERATIVE UPSKILLING COURSES',
              style: GoogleFonts.outfit(
                color: AppColors.primary,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 10),

            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _trainingModules.length,
              separatorBuilder: (ctx, idx) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final c = _trainingModules[index];
                final isEnrolled = c['isEnrolled'] == true;

                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.cardSurface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isEnrolled ? AppColors.success.withAlpha(120) : AppColors.borderDark,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              c['title'],
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: isEnrolled ? AppColors.successBg : AppColors.cardSurfaceAlt,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              isEnrolled ? 'ENROLLED' : c['duration'],
                              style: GoogleFonts.outfit(
                                color: isEnrolled ? AppColors.success : AppColors.textSecondary,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        c['institute'],
                        style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 11),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.cardSurfaceAlt,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.monetization_on_outlined, color: AppColors.warning, size: 16),
                            const SizedBox(width: 6),
                            Text(
                              'Govt Stipend: ${c['stipend']}',
                              style: GoogleFonts.outfit(
                                color: AppColors.warning,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: (c['skills'] as List<String>).map((s) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.scaffoldBg,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: AppColors.borderDark),
                            ),
                            child: Text(
                              s,
                              style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 10),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 14),
                      if (!isEnrolled)
                        ElevatedButton.icon(
                          onPressed: _isEnrolling ? null : () => _enrollInCourse(c),
                          icon: const Icon(Icons.school, size: 16),
                          label: const Text('Apply for Free NCCT Nomination'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                        )
                      else
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.successBg,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              'Nomination Active • Next Batch: 01 Nov 2026',
                              style: GoogleFonts.outfit(
                                color: AppColors.success,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    ),
  );
}
}
