import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants/app_colors.dart';
import '../core/localization/app_localizations.dart';

class PayoutWalletScreen extends StatefulWidget {
  const PayoutWalletScreen({super.key});

  @override
  State<PayoutWalletScreen> createState() => _PayoutWalletScreenState();
}

class _PayoutWalletScreenState extends State<PayoutWalletScreen> {
  double _availableBalance = 3840.50;
  final double _pendingEscrow = 1198.00;
  final double _welfareFundAccumulated = 4850.00;
  final double _dailyGoal = 2000.00;
  final double _todayEarned = 1450.00;
  bool _isWithdrawing = false;

  final List<Map<String, dynamic>> _ledger = [
    {
      'id': 'TXN-9021',
      'title': 'Job Payout: AC Jet Foam Servicing',
      'type': 'CREDIT_WAGE',
      'amount': 557.07,
      'date': 'Today, 02:45 PM',
      'booking_id': 104,
      'status': 'SETTLED',
    },
    {
      'id': 'TXN-9018',
      'title': 'Job Payout: Switchboard Diagnostic',
      'type': 'CREDIT_WAGE',
      'amount': 278.07,
      'date': 'Today, 11:20 AM',
      'booking_id': 103,
      'status': 'SETTLED',
    },
    {
      'id': 'TXN-9004',
      'title': 'Instant UPI Cashout to subhransu@oksbi',
      'type': 'WITHDRAWAL',
      'amount': -2500.00,
      'date': 'Yesterday, 08:30 PM',
      'booking_id': null,
      'status': 'SUCCESS',
    },
    {
      'id': 'TXN-8991',
      'title': 'Cooperative Welfare Health Match (Govt)',
      'type': 'WELFARE_BONUS',
      'amount': 250.00,
      'date': '22 Sep 2026',
      'booking_id': null,
      'status': 'LOCKED_RESERVE',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final goalPercent = (_todayEarned / _dailyGoal).clamp(0.0, 1.0);

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
            context.tr('walletCashout', 'Shramik Wallet & Cashout'),
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Daily Goal Visualizer
            _buildDailyGoalCard(goalPercent),

            const SizedBox(height: 16),

            // Balances Overview Cards
            _buildBalanceSummaryCard(),

            const SizedBox(height: 16),

            // Instant Cashout CTA
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _availableBalance > 0 && !_isWithdrawing ? _showCashoutSheet : null,
                icon: const Icon(Icons.flash_on, size: 20),
                label: Text(
                  _isWithdrawing ? context.tr('processing', 'PROCESSING INSTANT IMPS...') : context.tr('instantCashout', 'INSTANT CASHOUT VIA UPI (ZERO FEE)'),
                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Welfare & Pension Match Box
            _buildWelfareReserveBanner(),

            const SizedBox(height: 20),

            // Recent Transactions Ledger
            Text(
              'PAYOUT & ESCROW LEDGER',
              style: GoogleFonts.outfit(
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
              itemCount: _ledger.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final item = _ledger[index];
                final isCredit = (item['amount'] as num) > 0;
                final isWelfare = item['type'] == 'WELFARE_BONUS';

                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.cardSurface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.borderDark),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isWelfare
                              ? AppColors.welfareFund.withValues(alpha: 0.2)
                              : isCredit
                                  ? AppColors.success.withValues(alpha: 0.2)
                                  : AppColors.info.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isWelfare
                              ? Icons.health_and_safety
                              : isCredit
                                  ? Icons.arrow_downward
                                  : Icons.arrow_upward,
                          color: isWelfare
                              ? AppColors.welfareFund
                              : isCredit
                                  ? AppColors.success
                                  : AppColors.info,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['title'] as String,
                              style: GoogleFonts.outfit(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              '${item['date']} • Ref: ${item['id']}',
                              style: GoogleFonts.inter(fontSize: 10, color: AppColors.textMuted),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            isCredit ? '+₹${item['amount']}' : '₹${item['amount']}',
                            style: GoogleFonts.outfit(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: isCredit ? AppColors.success : Colors.white,
                            ),
                          ),
                          Text(
                            item['status'] as String,
                            style: GoogleFonts.outfit(
                              fontSize: 9,
                              color: isWelfare ? AppColors.welfareFund : AppColors.textMuted,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
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

  Widget _buildDailyGoalCard(double percent) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'TODAY\'S EARNINGS GOAL',
                style: GoogleFonts.outfit(
                  fontSize: 10.5,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                  color: AppColors.accent,
                ),
              ),
              Text(
                '${(percent * 100).toInt()}% Achieved',
                style: GoogleFonts.outfit(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppColors.success,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Text(
                '₹${_todayEarned.toInt()}',
                style: GoogleFonts.outfit(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                ' / ₹${_dailyGoal.toInt()} Target',
                style: GoogleFonts.outfit(fontSize: 14, color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: percent,
              minHeight: 10,
              backgroundColor: AppColors.cardSurfaceAlt,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accent),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Complete 1 more standard service to hit your daily ₹2,000 target and claim 100 bonus loyalty coins.',
            style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(16),
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
          Text(
            'READY FOR INSTANT WITHDRAWAL',
            style: GoogleFonts.outfit(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.8,
              color: AppColors.accent,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '₹${_availableBalance.toStringAsFixed(2)}',
            style: GoogleFonts.outfit(
              fontSize: 30,
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
                    Text('Escrow In-Transit (Unfinished)', style: GoogleFonts.inter(fontSize: 10, color: AppColors.textMuted)),
                    Text('₹${_pendingEscrow.toStringAsFixed(2)}', style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.warning)),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Cooperative Share (93%)', style: GoogleFonts.inter(fontSize: 10, color: AppColors.textMuted)),
                    Text('Zero Commission', style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.success)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWelfareReserveBanner() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.welfareFund.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.welfareFund.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.shield, color: AppColors.welfareFund, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ODISHA SHRAMIK WELFARE RESERVE',
                  style: GoogleFonts.outfit(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.welfareFund,
                  ),
                ),
                Text(
                  '₹${_welfareFundAccumulated.toStringAsFixed(2)} Accumulated',
                  style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                Text(
                  'Covers ESIC Health, Child Scholarships & ₹5L Accidental Insurance.',
                  style: GoogleFonts.inter(fontSize: 10, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showCashoutSheet() {
    final upiCtrl = TextEditingController(text: 'subhransu@oksbi');
    final amountCtrl = TextEditingController(text: _availableBalance.toInt().toString());

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.cardSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Instant UPI Cashout',
                  style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.textSecondary),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: upiCtrl,
              style: GoogleFonts.outfit(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Verified Virtual Payment Address (UPI)',
                hintText: 'worker@okhdfcbank',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: amountCtrl,
              keyboardType: TextInputType.number,
              style: GoogleFonts.outfit(color: Colors.white, fontSize: 18),
              decoration: const InputDecoration(
                labelText: 'Withdrawal Amount (₹)',
                prefixText: '₹ ',
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.cardSurfaceAlt,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_outline, color: AppColors.success, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Zero transaction deduction. 100% of your 93% wage directly credited.',
                      style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final amt = double.tryParse(amountCtrl.text) ?? 0;
                  Navigator.pop(ctx);
                  setState(() => _isWithdrawing = true);
                  Future.delayed(const Duration(milliseconds: 500), () {
                    if (mounted) {
                      setState(() {
                        _isWithdrawing = false;
                        _availableBalance -= amt;
                        _ledger.insert(0, {
                          'id': 'TXN-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
                          'title': 'Instant UPI Cashout to ${upiCtrl.text}',
                          'type': 'WITHDRAWAL',
                          'amount': -amt,
                          'date': 'Just now',
                          'booking_id': null,
                          'status': 'SUCCESS',
                        });
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: AppColors.success,
                          content: Text('Transferred ₹$amt instantly to ${upiCtrl.text} via IMPS!'),
                        ),
                      );
                    }
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('Confirm & Transfer Now'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
