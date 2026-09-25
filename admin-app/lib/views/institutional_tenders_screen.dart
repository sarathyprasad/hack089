import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/api_endpoints.dart';
import '../core/network/api_client.dart';

class InstitutionalTendersScreen extends StatefulWidget {
  const InstitutionalTendersScreen({super.key});

  @override
  State<InstitutionalTendersScreen> createState() => _InstitutionalTendersScreenState();
}

class _InstitutionalTendersScreenState extends State<InstitutionalTendersScreen> {
  bool _isLoading = true;
  List<dynamic> _tenders = [];

  @override
  void initState() {
    super.initState();
    _fetchTenders();
  }

  Future<void> _fetchTenders() async {
    setState(() => _isLoading = true);
    try {
      final res = await ApiClient().get(ApiEndpoints.tenders);
      if (res is List && mounted) {
        setState(() {
          _tenders = res;
          _isLoading = false;
        });
        return;
      }
    } catch (_) {}

    // Fallback Institutional Tenders
    if (mounted) {
      setState(() {
        _tenders = [
          {
            'id': 'TND-2026-BMC-041',
            'title': 'BMC Ward 34-40 Sanitation & Electrical Infrastructure Overhaul',
            'client': 'Bhubaneswar Municipal Corporation (Govt of Odisha)',
            'value': 2450000,
            'workers_demanded': 38,
            'trades': 'Electrical, Drainage & Plumbing',
            'deadline': '30 Oct 2026',
            'status': 'OPEN_FOR_BID',
            'location': 'Khordha District',
          },
          {
            'id': 'TND-2026-RVNL-018',
            'title': 'New Bhubaneswar Railway Terminal Station Facility Maintenance',
            'client': 'Rail Vikas Nigam Limited (RVNL)',
            'value': 4200000,
            'workers_demanded': 60,
            'trades': 'HVAC, Electrical, Masonry',
            'deadline': '15 Nov 2026',
            'status': 'AWARDED_TO_FEDERATION',
            'location': 'Khordha District',
          },
          {
            'id': 'TND-2026-OSEPA-102',
            'title': 'District School Electrical Safety Audit & Appliance Servicing',
            'client': 'Odisha School Education Programme Authority (OSEPA)',
            'value': 1680000,
            'workers_demanded': 25,
            'trades': 'Electrical Specialists',
            'deadline': '05 Nov 2026',
            'status': 'OPEN_FOR_BID',
            'location': 'Cuttack & Puri Districts',
          },
        ];
        _isLoading = false;
      });
    }
  }

  void _showBidDialog(Map<String, dynamic> tender) {
    int allocatedWorkers = 20;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: AppColors.cardSurface,
          title: Text(
            'Submit Cooperative Consortium Bid',
            style: GoogleFonts.dmSans(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 16),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tender['title'],
                style: GoogleFonts.dmSans(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                'Tender Value: ₹${((tender['value'] ?? 0) / 100000).toStringAsFixed(1)} Lakhs',
                style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 12),
              ),
              const SizedBox(height: 14),
              Text(
                'Workforce Units to Allocate from Primary Cooperatives:',
                style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 12, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline, color: AppColors.primary),
                    onPressed: () {
                      if (allocatedWorkers > 5) {
                        setDialogState(() => allocatedWorkers -= 5);
                      }
                    },
                  ),
                  Text(
                    '$allocatedWorkers Workers',
                    style: GoogleFonts.dmSans(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline, color: AppColors.primary),
                    onPressed: () {
                      setDialogState(() => allocatedWorkers += 5);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.cardSurfaceAlt,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Consortium breakdown: 93% directly into worker wage accounts • 5% Apex welfare reserve • 2% contingency pool.',
                  style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 11),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                setState(() {
                  tender['status'] = 'BID_SUBMITTED';
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: AppColors.success,
                    content: Text('Consortium bid of $allocatedWorkers workers lodged with ${tender["client"]}.'),
                  ),
                );
              },
              child: const Text('Submit Consortium Bid'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        title: Text(
          'Institutional & Govt Tenders',
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
                  // Statutory Tender Overview Banner
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF292524), Color(0xFF3B1D11)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.accent.withAlpha(80)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.business_center, color: AppColors.accent, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'COOPERATIVE PREFERENTIAL PROCUREMENT',
                              style: GoogleFonts.dmSans(
                                color: AppColors.accentLight,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Public Works & Commercial Procurement Bids',
                          style: GoogleFonts.dmSans(
                            color: AppColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Under State Cooperative Procurement Policy, labor cooperatives receive 15% price preference on municipal & departmental maintenance contracts.',
                          style: GoogleFonts.inter(
                            color: AppColors.textSecondary,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  Text(
                    'ACTIVE PROCUREMENT TENDERS',
                    style: GoogleFonts.dmSans(
                      color: AppColors.primaryLight,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 10),

                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _tenders.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final t = _tenders[index];
                      final id = t['id'];
                      final title = t['title'];
                      final client = t['client'];
                      final value = t['value'] ?? 0;
                      final workers = t['workers_demanded'] ?? 0;
                      final trades = t['trades'] ?? '';
                      final deadline = t['deadline'] ?? '';
                      final status = t['status'] ?? 'OPEN_FOR_BID';
                      final location = t['location'] ?? 'Odisha';

                      final isAwarded = status == 'AWARDED_TO_FEDERATION';
                      final isSubmitted = status == 'BID_SUBMITTED';

                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.cardSurface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isAwarded ? AppColors.success.withAlpha(120) : AppColors.borderDark,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: AppColors.cardSurfaceAlt,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    id,
                                    style: GoogleFonts.dmSans(
                                      color: AppColors.primary,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: isAwarded
                                        ? AppColors.successBg
                                        : (isSubmitted ? AppColors.infoBg : AppColors.warningBg),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: isAwarded
                                          ? AppColors.success
                                          : (isSubmitted ? AppColors.info : AppColors.warning),
                                    ),
                                  ),
                                  child: Text(
                                    isAwarded ? 'AWARDED' : (isSubmitted ? 'BID SUBMITTED' : 'OPEN'),
                                    style: GoogleFonts.dmSans(
                                      color: isAwarded
                                          ? AppColors.success
                                          : (isSubmitted ? AppColors.info : AppColors.warning),
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              title,
                              style: GoogleFonts.dmSans(
                                color: AppColors.textPrimary,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              client,
                              style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 11),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.cardSurfaceAlt,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Contract Value',
                                        style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 10),
                                      ),
                                      Text(
                                        '₹${(value / 100000).toStringAsFixed(1)} Lakhs',
                                        style: GoogleFonts.dmSans(
                                          color: AppColors.primary,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Workforce Needed',
                                        style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 10),
                                      ),
                                      Text(
                                        '$workers Personnel',
                                        style: GoogleFonts.dmSans(
                                          color: AppColors.textPrimary,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Bid Deadline',
                                        style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 10),
                                      ),
                                      Text(
                                        deadline,
                                        style: GoogleFonts.inter(
                                          color: AppColors.accent,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Trades: $trades • $location',
                              style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 11),
                            ),
                            const SizedBox(height: 14),
                            if (!isAwarded && !isSubmitted)
                              ElevatedButton.icon(
                                onPressed: () => _showBidDialog(t),
                                icon: const Icon(Icons.handshake_outlined, size: 16),
                                label: const Text('Mobilize Cooperative Consortium Bid'),
                              )
                            else if (isAwarded)
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                decoration: BoxDecoration(
                                  color: AppColors.successBg,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: Text(
                                    'Contract Awarded • Workforce Deployed & Active',
                                    style: GoogleFonts.dmSans(
                                      color: AppColors.success,
                                      fontSize: 12,
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
    );
  }
}
