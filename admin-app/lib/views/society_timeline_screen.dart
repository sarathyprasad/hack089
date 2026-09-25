import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/api_endpoints.dart';
import '../core/network/api_client.dart';

class SocietyTimelineScreen extends StatefulWidget {
  final int? initialSocietyId;

  const SocietyTimelineScreen({super.key, this.initialSocietyId});

  @override
  State<SocietyTimelineScreen> createState() => _SocietyTimelineScreenState();
}

class _SocietyTimelineScreenState extends State<SocietyTimelineScreen> {
  final _searchController = TextEditingController();
  bool _isLoading = false;
  int _currentStep = 3; // Step 3: DCO Inspection completed, awaiting charter

  String _societyName = 'Shramik Kalyan Labour Cooperative Samiti';
  String _trackingId = 'REG-2026-KHD-014';
  String _district = 'Khordha District';

  final List<Map<String, dynamic>> _milestones = [
    {
      'title': '1. Inception & Promoter Meeting',
      'subtitle': 'Passed by 15 founding artisan members at Saheed Nagar',
      'date': '12 Jan 2026',
      'officer': 'Chief Promoter Bikash Mohanty',
      'status': 'COMPLETED',
    },
    {
      'title': '2. Model Bye-Laws & NCCT Vetting',
      'subtitle': 'Statutory review and governance checks completed',
      'date': '28 Jan 2026',
      'officer': 'NCCT Regional Institute',
      'status': 'COMPLETED',
    },
    {
      'title': '3. DCO Field Inspection & Audit',
      'subtitle': 'On-site verification of tool inventory and founding rosters',
      'date': '15 Feb 2026',
      'officer': 'Shri Debendra Nayak (DCO Khordha)',
      'status': 'COMPLETED',
    },
    {
      'title': '4. Registration Charter & Bank Mandate',
      'subtitle': 'Official Society Certificate & statutory current account',
      'date': 'Awaiting Issuance',
      'officer': 'State Registrar',
      'status': 'IN_PROGRESS',
    },
    {
      'title': '5. Apex Dispatch & Live Platform Integration',
      'subtitle': 'Workforce enabled for booking dispatches & mutual aid',
      'date': 'Pending Stage 4',
      'officer': 'Apex Technical Committee',
      'status': 'PENDING',
    },
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialSocietyId != null) {
      _fetchTimelineForSociety(widget.initialSocietyId!);
    }
  }

  Future<void> _fetchTimelineForSociety(int id) async {
    setState(() => _isLoading = true);
    try {
      final res = await ApiClient().get('${ApiEndpoints.societies}/$id');
      if (res is Map && mounted) {
        setState(() {
          _societyName = res['name']?.toString() ?? _societyName;
          _district = res['district']?.toString() ?? _district;
          _trackingId = 'REG-2026-ID-$id';
          _isLoading = false;
        });
        return;
      }
    } catch (_) {}
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _advanceStage() async {
    if (_currentStep < 5) {
      setState(() {
        _currentStep++;
        _milestones[_currentStep - 1]['status'] = 'COMPLETED';
        _milestones[_currentStep - 1]['date'] = 'Today (${DateTime.now().day}/${DateTime.now().month})';
        if (_currentStep < 5) {
          _milestones[_currentStep]['status'] = 'IN_PROGRESS';
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.success,
          content: Text('Statutory stage advanced to Stage $_currentStep.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        title: Text(
          'Statutory Lifecycle Timeline',
          style: GoogleFonts.dmSans(fontWeight: FontWeight.bold, fontSize: 17),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search / Lookup bar
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.cardSurface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderDark),
              ),
              child: Row(
                children: [
                  const Icon(Icons.search, color: AppColors.textSecondary, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 13),
                      decoration: const InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        hintText: 'Enter Tracking ID (e.g. REG-2026-KHD-014)',
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (_searchController.text.trim().isNotEmpty) {
                        setState(() {
                          _trackingId = _searchController.text.trim();
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Loaded records for $_trackingId')),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      minimumSize: Size.zero,
                    ),
                    child: const Text('Track'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // Active Society Details Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.cardSurface, AppColors.gold.withAlpha(20)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.gold.withAlpha(80)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.gold.withAlpha(30),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          _trackingId,
                          style: GoogleFonts.dmSans(
                            color: AppColors.gold,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      Text(
                        'STAGE $_currentStep OF 5',
                        style: GoogleFonts.dmSans(
                          color: AppColors.primaryLight,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _societyName,
                    style: GoogleFonts.dmSans(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '$_district • Jurisdiction: RCS Odisha',
                    style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 11),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),

            // Milestone Stepper
            Text(
              'STATUTORY MILESTONES & AUDIT STEPS',
              style: GoogleFonts.dmSans(
                color: AppColors.primaryLight,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 14),

            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _milestones.length,
              itemBuilder: (context, index) {
                final m = _milestones[index];
                final isCompleted = m['status'] == 'COMPLETED';
                final isInProgress = m['status'] == 'IN_PROGRESS';
                final isLast = index == _milestones.length - 1;

                return IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Step line indicator
                      Column(
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isCompleted
                                  ? AppColors.success
                                  : (isInProgress ? AppColors.primary : AppColors.cardSurfaceAlt),
                              border: Border.all(
                                color: isCompleted
                                    ? AppColors.success
                                    : (isInProgress ? AppColors.primary : AppColors.borderDark),
                                width: 2,
                              ),
                            ),
                            child: Icon(
                              isCompleted ? Icons.check : (isInProgress ? Icons.hourglass_top : Icons.circle),
                              size: 14,
                              color: isCompleted || isInProgress ? Colors.black : AppColors.textMuted,
                            ),
                          ),
                          if (!isLast)
                            Expanded(
                              child: Container(
                                width: 2,
                                color: isCompleted ? AppColors.success : AppColors.borderDark,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(width: 14),
                      // Content Card
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.cardSurface,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isInProgress ? AppColors.primary.withAlpha(100) : AppColors.borderDark,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    m['title'],
                                    style: GoogleFonts.dmSans(
                                      color: AppColors.textPrimary,
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    m['date'],
                                    style: GoogleFonts.inter(
                                      color: isCompleted ? AppColors.success : AppColors.textMuted,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                m['subtitle'],
                                style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 11),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Icon(Icons.person_pin, color: AppColors.primary, size: 12),
                                  const SizedBox(width: 4),
                                  Text(
                                    m['officer'],
                                    style: GoogleFonts.inter(
                                      color: AppColors.primaryLight,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 14),

            // Statutory Advance Button for authorized DCOs
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.cardSurface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderDark),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'DCO REGISTRAR STATUTORY ACTIONS',
                    style: GoogleFonts.dmSans(
                      color: AppColors.primaryLight,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Authorized officers can certify compliance and advance this primary cooperative to the next regulatory milestone.',
                    style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 11),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: _currentStep < 5 ? _advanceStage : null,
                    icon: const Icon(Icons.verified, size: 16),
                    label: Text(
                      _currentStep < 5
                          ? 'Advance to Stage ${_currentStep + 1} & Endorse Compliance'
                          : 'All Statutory Milestones Completed',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
