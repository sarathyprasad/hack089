import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/gov_app_bar.dart';
import '../../core/widgets/gov_loading_indicator.dart';
import '../../providers/society_provider.dart';

class SocietyTimelineScreen extends StatefulWidget {
  final String? initialTrackingId;
  const SocietyTimelineScreen({super.key, this.initialTrackingId});

  @override
  State<SocietyTimelineScreen> createState() => _SocietyTimelineScreenState();
}

class _SocietyTimelineScreenState extends State<SocietyTimelineScreen> {
  final _trackController = TextEditingController(text: 'OD-COOP-2026-001');

  @override
  void initState() {
    super.initState();
    if (widget.initialTrackingId != null) {
      _trackController.text = widget.initialTrackingId!;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SocietyProvider>().trackSociety(_trackController.text.trim());
    });
  }

  @override
  void dispose() {
    _trackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final sProv = context.watch<SocietyProvider>();
    final society = sProv.trackedSociety;

    final stages = [
      {'title': 'Application Submitted & Promoter Dossier Uploaded', 'desc': 'Section 6 compliant with 10 founding artisan members'},
      {'title': 'Scrutiny by ARCS Circle Office', 'desc': 'Legal scrutiny of model bylaws and authorized share capital'},
      {'title': 'Field Verification & Artisan Tooling Audit', 'desc': 'Cooperative Inspector on-site inspection in Khordha Sadar'},
      {'title': 'Statutory Bylaws Registration under Section 7', 'desc': 'Odisha Cooperative Societies Act certification and numbering'},
      {'title': 'Certificate of Registration & Seal Issuance', 'desc': 'Official statutory operating license issued'},
    ];

    final currentStage = society?.currentStage ?? 2;

    return Scaffold(
      appBar: const GovAppBar(title: 'Society Formation Tracker'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : Colors.white, 
                borderRadius: BorderRadius.circular(10), 
                border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.borderLight),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _trackController,
                      decoration: InputDecoration(
                        labelText: 'Enter Tracking ID',
                        hintText: 'OD-COOP-2026-XXXX',
                        prefixIcon: Icon(
                          Icons.search, 
                          color: isDark ? AppColors.secondarySaffron : AppColors.primaryNavy,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => sProv.trackSociety(_trackController.text.trim()),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark ? AppColors.primaryNavy : AppColors.primaryNavy,
                    ),
                    child: const Text('Track'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            if (sProv.isLoading)
              const GovLoadingIndicator.card(
                title: 'Tracking Statutory Progression...',
                subtitle: 'Auditing state gazette filings and registrar clearance',
              )
            else if (society != null) ...[
              // Society Summary Card
              Card(
                color: isDark ? AppColors.darkCard : Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.borderLight),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.navyLight : AppColors.primaryNavy, 
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(society.trackingId, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.darkAmberBg.withValues(alpha: 0.5) : AppColors.amberLight, 
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'STAGE $currentStage OF 5', 
                              style: TextStyle(
                                fontSize: 10, 
                                fontWeight: FontWeight.bold, 
                                color: isDark ? AppColors.darkAmberFg : AppColors.warningAmber,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        society.name, 
                        style: TextStyle(
                          fontSize: 16, 
                          fontWeight: FontWeight.bold, 
                          color: isDark ? AppColors.darkTextPrimary : AppColors.primaryNavy,
                        ),
                      ),
                      Text(
                        '${society.blockPanchayat ?? "Bhubaneswar Sadar"}, ${society.district}', 
                        style: TextStyle(fontSize: 12, color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
                      ),
                      const Divider(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _infoStat('PROMOTERS', '${society.membersCount} Members', isDark),
                          _infoStat('CAPITAL', '₹${society.authorizedCapital.toStringAsFixed(0)}', isDark),
                          _infoStat('STATUS', society.status, isDark),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Text(
                'Official Statutory Formation Timeline', 
                style: TextStyle(
                  fontSize: 15, 
                  fontWeight: FontWeight.bold, 
                  color: isDark ? AppColors.darkTextPrimary : AppColors.primaryNavy,
                ),
              ),
              const SizedBox(height: 12),

              // 5-Stage Stepper Visualization
              ...stages.asMap().entries.map((entry) {
                final idx = entry.key + 1;
                final data = entry.value;
                final isDone = idx < currentStage;
                final isCurrent = idx == currentStage;

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        CircleAvatar(
                          radius: 14,
                          backgroundColor: isDone
                              ? AppColors.accentGreen
                              : isCurrent
                                  ? AppColors.secondarySaffron
                                  : (isDark ? AppColors.darkCardAlt : const Color(0xFFCBD5E1)),
                          child: Icon(
                            isDone ? Icons.check : Icons.circle,
                            size: isDone ? 16 : 8,
                            color: isDone ? Colors.white : (isDark ? AppColors.navyDark : Colors.black),
                          ),
                        ),
                        if (idx < stages.length)
                          Container(
                            width: 2,
                            height: 48,
                            color: isDone 
                                ? AppColors.accentGreen 
                                : (isDark ? AppColors.darkBorder : const Color(0xFFCBD5E1)),
                          ),
                      ],
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data['title']!,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: isCurrent 
                                    ? (isDark ? AppColors.secondarySaffron : AppColors.primaryNavy) 
                                    : (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              data['desc']!, 
                              style: TextStyle(
                                fontSize: 11, 
                                color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              }),
            ],
          ],
        ),
      ),
    );
  }

  Widget _infoStat(String label, String value, bool isDark) {
    return Column(
      children: [
        Text(
          value, 
          style: TextStyle(
            fontSize: 13, 
            fontWeight: FontWeight.bold, 
            color: isDark ? AppColors.secondarySaffron : AppColors.primaryNavy,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label, 
          style: TextStyle(
            fontSize: 10, 
            fontWeight: FontWeight.w600, 
            color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
          ),
        ),
      ],
    );
  }
}
