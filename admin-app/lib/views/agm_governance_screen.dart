import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants/app_colors.dart';

class AgmGovernanceScreen extends StatefulWidget {
  const AgmGovernanceScreen({super.key});

  @override
  State<AgmGovernanceScreen> createState() => _AgmGovernanceScreenState();
}

class _AgmGovernanceScreenState extends State<AgmGovernanceScreen> {
  final List<Map<String, dynamic>> _resolutions = [
    {
      'id': 'RES-2026-01',
      'title': 'Declaration of 7.5% Annual Cooperative Worker Dividend',
      'category': 'Financial Distribution',
      'summary': 'Distribution of ₹18,40,000 net operational surplus among 156 certified cooperative member-artisans based on completed service hours.',
      'votes_for': 122,
      'votes_against': 8,
      'abstain': 4,
      'status': 'PASSED_SUPERMAJORITY',
    },
    {
      'id': 'RES-2026-02',
      'title': 'Enhancement of Shramik Accidental Welfare Cover to ₹10 Lakhs',
      'category': 'Welfare & Social Security',
      'summary': 'Statutory expansion of group accidental death and disability coverage from ₹5,00,000 to ₹10,00,000, funded via the 5% cooperative welfare reserve.',
      'votes_for': 130,
      'votes_against': 1,
      'abstain': 3,
      'status': 'PASSED_UNANIMOUS',
    },
    {
      'id': 'RES-2026-03',
      'title': 'Establishment of 2 New Regional Tool Hubs in Rourkela & Berhampur',
      'category': 'Capital Expenditure',
      'summary': 'Allocation of ₹25 Lakhs from Federation Reserve Fund to procure wholesale tools and establish automated tool rental lockers.',
      'votes_for': 98,
      'votes_against': 24,
      'abstain': 12,
      'status': 'VOTING_OPEN',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        title: Text(
          'Statutory AGM & Member Governance',
          style: GoogleFonts.dmSans(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Statutory AGM Notice Header
            _buildAgmNoticeCard(),

            const SizedBox(height: 16),

            // Quorum Progress Indicator
            _buildQuorumCard(),

            const SizedBox(height: 20),

            // Resolutions List
            Text(
              'OFFICIAL STATUTORY RESOLUTIONS (ANNUAL GENERAL MEETING)',
              style: GoogleFonts.dmSans(
                fontSize: 10.5,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.8,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 10),

            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _resolutions.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final r = _resolutions[index];
                final totalVotes = (r['votes_for'] as int) + (r['votes_against'] as int) + (r['abstain'] as int);
                final forPercent = totalVotes > 0 ? (r['votes_for'] as int) / totalVotes : 0.0;
                final isOpen = r['status'] == 'VOTING_OPEN';

                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.cardSurface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isOpen ? AppColors.primary : AppColors.borderDark,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              r['id'] as String,
                              style: GoogleFonts.dmSans(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: isOpen ? AppColors.warningBg : AppColors.successBg,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              (r['status'] as String).replaceAll('_', ' '),
                              style: GoogleFonts.dmSans(
                                fontSize: 9.5,
                                fontWeight: FontWeight.bold,
                                color: isOpen ? AppColors.warning : AppColors.success,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        r['title'] as String,
                        style: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        r['summary'] as String,
                        style: GoogleFonts.inter(fontSize: 11.5, color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 14),

                      // Vote progress bar
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Support: ${(forPercent * 100).toInt()}% In Favor',
                            style: GoogleFonts.dmSans(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.success),
                          ),
                          Text(
                            '${r['votes_for']} Yes • ${r['votes_against']} No • ${r['abstain']} Abstain',
                            style: GoogleFonts.inter(fontSize: 10, color: AppColors.textMuted),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: forPercent,
                          minHeight: 8,
                          backgroundColor: AppColors.cardSurfaceAlt,
                          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.success),
                        ),
                      ),
                      if (isOpen) ...[
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  setState(() => r['votes_for'] = (r['votes_for'] as int) + 1);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      backgroundColor: AppColors.success,
                                      content: Text('Official Vote Recorded: IN FAVOR of Resolution.'),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.thumb_up, size: 14),
                                label: const Text('Vote In Favor'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.success,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  setState(() => r['votes_against'] = (r['votes_against'] as int) + 1);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      backgroundColor: AppColors.error,
                                      content: Text('Official Vote Recorded: AGAINST Resolution.'),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.thumb_down, size: 14),
                                label: const Text('Vote Against'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.error,
                                  side: const BorderSide(color: AppColors.error),
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAgmNoticeCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.gavel, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                '52ND STATUTORY ANNUAL GENERAL MEETING',
                style: GoogleFonts.dmSans(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Odisha Cooperative Societies Act (Section 28 Compliance)',
            style: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 4),
          Text(
            'Presided by Registrar of Cooperative Societies (RCS Odisha) & Apex Federation Governing Board. All certified worker-members possess 1 equal vote.',
            style: GoogleFonts.inter(fontSize: 11.5, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildQuorumCard() {
    const quorumPercent = 0.78; // 78%
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardSurfaceAlt,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'STATUTORY QUORUM STATUS',
                style: GoogleFonts.dmSans(fontSize: 10.5, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.successBg,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'QUORUM MET (78% > 60%)',
                  style: GoogleFonts.dmSans(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.success),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: quorumPercent,
              minHeight: 10,
              backgroundColor: AppColors.scaffoldBg,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '134 of 156 member delegates registered and voting. Statutory resolutions are legally binding under Odisha Law.',
            style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
