import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants/app_colors.dart';

class EscrowSettlementScreen extends StatefulWidget {
  const EscrowSettlementScreen({super.key});

  @override
  State<EscrowSettlementScreen> createState() => _EscrowSettlementScreenState();
}

class _EscrowSettlementScreenState extends State<EscrowSettlementScreen> {
  bool _isProcessingBatch = false;
  double _pendingPayoutBatch = 40977.00;
  int _pendingArtisansCount = 28;

  final List<Map<String, dynamic>> _societySettlements = [
    {
      'id': 1,
      'name': 'Utkal Skilled Craftsmen Co-op Ltd.',
      'district': 'Khordha',
      'settled_gmv': 482000.0,
      'worker_payout_93': 448260.0,
      'welfare_5': 24100.0,
      'fed_infra_2': 9640.0,
      'pending_batch': 14850.0,
      'status': 'READY_FOR_DISPATCH',
    },
    {
      'id': 2,
      'name': 'Barabati Artisans Welfare Society',
      'district': 'Cuttack',
      'settled_gmv': 365400.0,
      'worker_payout_93': 339822.0,
      'welfare_5': 18270.0,
      'fed_infra_2': 7308.0,
      'pending_batch': 16120.0,
      'status': 'READY_FOR_DISPATCH',
    },
    {
      'id': 3,
      'name': 'Puri Heritage Plumbers Co-op Ltd.',
      'district': 'Puri',
      'settled_gmv': 245000.0,
      'worker_payout_93': 227850.0,
      'welfare_5': 12250.0,
      'fed_infra_2': 4900.0,
      'pending_batch': 10007.0,
      'status': 'READY_FOR_DISPATCH',
    },
  ];

  final List<Map<String, dynamic>> _auditLogs = [
    {
      'batch_id': 'BATCH-OD-2026-SEP-W3',
      'date': '21 Sep 2026, 06:00 PM',
      'total_disbursed': 86420.00,
      'workers_count': 64,
      'clearing_bank': 'State Bank of India (Odisha State Co-op Apex Branch)',
      'status': 'CLEARED_NEFT',
    },
    {
      'batch_id': 'BATCH-OD-2026-SEP-W2',
      'date': '14 Sep 2026, 06:00 PM',
      'total_disbursed': 92150.00,
      'workers_count': 71,
      'clearing_bank': 'Odisha State Cooperative Bank (OSCB)',
      'status': 'CLEARED_NEFT',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        title: Text(
          'Cooperative Escrow & Payout Clearing',
          style: GoogleFonts.dmSans(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Treasury Overview Card
            _buildTreasuryCard(),

            const SizedBox(height: 16),

            // Pending Batch Execution CTA
            _buildBatchSettlementActionCard(),

            const SizedBox(height: 20),

            // Society-Level Escrow Ledger
            Text(
              'PRIMARY SOCIETIES ESCROW BREAKDOWN',
              style: GoogleFonts.dmSans(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.8,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 10),

            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _societySettlements.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final s = _societySettlements[index];
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.cardSurface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.borderDark),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              s['name'] as String,
                              style: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.infoBg,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              s['district'] as String,
                              style: GoogleFonts.dmSans(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.info),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          _buildMiniStat('TOTAL GMV', '₹${(s['settled_gmv'] as num).toInt()}'),
                          _buildMiniStat('93% ARTISAN WAGE', '₹${(s['worker_payout_93'] as num).toInt()}'),
                          _buildMiniStat('5% WELFARE', '₹${(s['welfare_5'] as num).toInt()}'),
                          _buildMiniStat('PENDING NEFT', '₹${(s['pending_batch'] as num).toInt()}', isHighlight: true),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            // Past Batch Audit Log
            Text(
              'DISBURSEMENT CLEARING AUDIT LOG',
              style: GoogleFonts.dmSans(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.8,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 10),

            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _auditLogs.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final log = _auditLogs[index];
                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.cardSurfaceAlt,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.borderDark),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: AppColors.successBg,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.check, color: AppColors.success, size: 18),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              log['batch_id'] as String,
                              style: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                            Text(
                              '${log['date']} • ${log['workers_count']} Artisans Credited',
                              style: GoogleFonts.inter(fontSize: 10, color: AppColors.textSecondary),
                            ),
                            Text(
                              log['clearing_bank'] as String,
                              style: GoogleFonts.inter(fontSize: 9.5, color: AppColors.textMuted),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '₹${(log['total_disbursed'] as num).toInt()}',
                        style: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.success),
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

  Widget _buildTreasuryCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryDark.withValues(alpha: 0.8),
            AppColors.scaffoldBg,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'STATEWIDE COOPERATIVE ESCROW TREASURY',
                style: GoogleFonts.dmSans(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                  color: AppColors.primaryLight,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.successBg,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '100% AUDIT COMPLIANT',
                  style: GoogleFonts.dmSans(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.success),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '₹12,48,900.00',
            style: GoogleFonts.dmSans(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          const Divider(height: 20, color: AppColors.borderDark),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Direct Worker Share (93%)', style: GoogleFonts.inter(fontSize: 10, color: AppColors.textSecondary)),
                    Text('₹11,61,477.00', style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.success)),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Prithvi Welfare Fund (5%)', style: GoogleFonts.inter(fontSize: 10, color: AppColors.textSecondary)),
                    Text('₹62,445.00', style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primary)),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('State Tech Fund (2%)', style: GoogleFonts.inter(fontSize: 10, color: AppColors.textSecondary)),
                    Text('₹24,978.00', style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.info)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBatchSettlementActionCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _pendingPayoutBatch > 0 ? AppColors.primary : AppColors.borderDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.outbox, color: AppColors.primary, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PENDING NEFT/IMPS DISBURSEMENT BATCH',
                      style: GoogleFonts.dmSans(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary),
                    ),
                    Text(
                      '$_pendingArtisansCount artisans waiting for completed job clearance (₹${_pendingPayoutBatch.toStringAsFixed(2)})',
                      style: GoogleFonts.inter(fontSize: 11.5, color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _pendingPayoutBatch > 0 && !_isProcessingBatch ? _executeBatchDisbursement : null,
              icon: _isProcessingBatch
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2),
                    )
                  : const Icon(Icons.flash_on, size: 18),
              label: Text(
                _isProcessingBatch
                    ? 'DISPATCHING OSCB BATCH SETTLEMENT...'
                    : 'TRIGGER ONE-CLICK STATEWIDE BATCH PAYOUT',
                style: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, String value, {bool isHighlight = false}) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.dmSans(fontSize: 8.5, color: AppColors.textMuted, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: GoogleFonts.dmSans(
              fontSize: 11.5,
              fontWeight: FontWeight.bold,
              color: isHighlight ? AppColors.warning : Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _executeBatchDisbursement() {
    setState(() => _isProcessingBatch = true);
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _auditLogs.insert(0, {
            'batch_id': 'BATCH-OD-2026-SEP-W4',
            'date': 'Today, Just Now',
            'total_disbursed': _pendingPayoutBatch,
            'workers_count': _pendingArtisansCount,
            'clearing_bank': 'Odisha State Cooperative Bank (OSCB - RTGS Core)',
            'status': 'CLEARED_NEFT',
          });
          _pendingPayoutBatch = 0.0;
          _pendingArtisansCount = 0;
          _isProcessingBatch = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: AppColors.success,
            content: Text('Statewide Payout Cleared! All 28 artisans credited via direct bank transfer.'),
          ),
        );
      }
    });
  }
}
