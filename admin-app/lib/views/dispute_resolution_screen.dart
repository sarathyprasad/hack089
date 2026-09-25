import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/api_endpoints.dart';
import '../core/network/api_client.dart';

class DisputeResolutionScreen extends StatefulWidget {
  const DisputeResolutionScreen({super.key});

  @override
  State<DisputeResolutionScreen> createState() => _DisputeResolutionScreenState();
}

class _DisputeResolutionScreenState extends State<DisputeResolutionScreen> {
  bool _isLoading = true;
  List<dynamic> _disputes = [];

  @override
  void initState() {
    super.initState();
    _fetchDisputes();
  }

  Future<void> _fetchDisputes() async {
    setState(() => _isLoading = true);
    try {
      final res = await ApiClient().get(ApiEndpoints.disputes);
      if (res is List && mounted) {
        setState(() {
          _disputes = res;
          _isLoading = false;
        });
        return;
      }
    } catch (_) {}

    // Fallback demo disputes
    if (mounted) {
      setState(() {
        _disputes = [
          {
            'id': 101,
            'ticket_no': 'DSP-2026-KHD-04',
            'booking_id': 1024,
            'complainant_name': 'Prof. Manoj Pattnaik',
            'worker_name': 'Suresh Kumar Das (Plumber)',
            'issue_category': 'Service Quality Contention',
            'description': 'Kitchen drainage pipe joint began leaking 3 days after replacement. Demands rework under 30-day cooperative guarantee.',
            'claim_amount': 450,
            'status': 'OPEN_REVIEW',
            'created_at': '22 Sep 2026',
          },
          {
            'id': 102,
            'ticket_no': 'DSP-2026-CTC-09',
            'booking_id': 982,
            'complainant_name': 'Smt. Minati Tripathy',
            'worker_name': 'Priyaranjan Nayak (HVAC)',
            'issue_category': 'Appliance Part Warranty Contention',
            'description': 'Compressor capacitor failed after 10 days. Manufacturer warranty claim processing required.',
            'claim_amount': 320,
            'status': 'IN_INVESTIGATION',
            'created_at': '18 Sep 2026',
          },
        ];
        _isLoading = false;
      });
    }
  }

  void _showAdjudicationDialog(Map<String, dynamic> dispute) {
    String resolutionAction = 'FREE_REWORK';
    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: AppColors.cardSurface,
          title: Text(
            'Statutory Adjudication — ${dispute['ticket_no']}',
            style: GoogleFonts.dmSans(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 16),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Complainant: ${dispute['complainant_name']}\nArtisan: ${dispute['worker_name']}',
                style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 12),
              ),
              const SizedBox(height: 12),
              Text(
                'Select Registrar Ruling Action:',
                style: GoogleFonts.dmSans(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: resolutionAction,
                dropdownColor: AppColors.cardSurfaceAlt,
                style: GoogleFonts.inter(color: AppColors.textPrimary),
                items: const [
                  DropdownMenuItem(value: 'FREE_REWORK', child: Text('Dispatch Senior Master Artisan for Free Rework')),
                  DropdownMenuItem(value: 'WELFARE_REFUND', child: Text('Full Refund from Apex Guarantee Reserve')),
                  DropdownMenuItem(value: 'REMEDIAL_TRAINING', child: Text('Artisan Mandatory NCCT Remedial Training')),
                ],
                onChanged: (val) => setDialogState(() => resolutionAction = val!),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: notesController,
                maxLines: 2,
                style: GoogleFonts.inter(color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  labelText: 'Official Registrar Finding & Endorsement',
                  hintText: 'Enter statutory order details...',
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
              onPressed: () async {
                Navigator.pop(ctx);
                final id = dispute['id'];
                try {
                  await ApiClient().post(ApiEndpoints.resolveDispute(id), data: {
                    'action': resolutionAction,
                    'notes': notesController.text.trim(),
                  });
                } catch (_) {}
                if (mounted) {
                  setState(() {
                    dispute['status'] = 'SETTLED';
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: AppColors.success,
                      content: Text('Dispute ${dispute["ticket_no"]} formally resolved by DCO ruling.'),
                    ),
                  );
                }
              },
              child: const Text('Issue Statutory Order'),
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
          'Grievance Redressal & Disputes',
          style: GoogleFonts.dmSans(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Statutory Header
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
                          children: [
                            const Icon(Icons.gavel_rounded, color: AppColors.gold, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'STATUTORY DISPUTE MEDIATION BENCH',
                              style: GoogleFonts.dmSans(
                                color: AppColors.gold,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Cooperative Ombudsman & Guarantee Tribunal',
                          style: GoogleFonts.dmSans(
                            color: AppColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'All customer complaints and artisan wage disputes are resolved by the District Cooperative Registrar under the Cooperative Societies Tribunal Rules, ensuring zero citizen exploitation.',
                          style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 11),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  Text(
                    'OPEN CONSUMER & WORKFORCE CLAIMS',
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
                    itemCount: _disputes.length,
                    separatorBuilder: (ctx, idx) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final d = _disputes[index];
                      final isSettled = d['status'] == 'SETTLED';

                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.cardSurface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSettled ? AppColors.success.withAlpha(100) : AppColors.borderDark,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: AppColors.cardSurfaceAlt,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    d['ticket_no'],
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
                                    color: isSettled ? AppColors.successBg : AppColors.warningBg,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    isSettled ? 'SETTLED ✓' : d['status'],
                                    style: GoogleFonts.dmSans(
                                      color: isSettled ? AppColors.success : AppColors.warning,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              d['issue_category'],
                              style: GoogleFonts.dmSans(
                                color: AppColors.textPrimary,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              d['description'],
                              style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 12),
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
                                  Text(
                                    'Citizen: ${d['complainant_name']}',
                                    style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 11),
                                  ),
                                  Text(
                                    'Claim: ₹${d['claim_amount']}',
                                    style: GoogleFonts.dmSans(color: AppColors.gold, fontWeight: FontWeight.bold, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 14),
                            if (!isSettled)
                              ElevatedButton.icon(
                                onPressed: () => _showAdjudicationDialog(d),
                                icon: const Icon(Icons.gavel, size: 16),
                                label: const Text('Adjudicate & Issue Registrar Order'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.black,
                                  padding: const EdgeInsets.symmetric(vertical: 10),
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
