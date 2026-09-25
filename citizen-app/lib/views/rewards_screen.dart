import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants/app_colors.dart';

class RewardsScreen extends StatefulWidget {
  const RewardsScreen({super.key});

  @override
  State<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends State<RewardsScreen> {
  final int _coinBalance = 450;

  final List<Map<String, dynamic>> _coupons = [
    {
      'code': 'COOP100',
      'discount': '₹100 FLAT OFF',
      'title': 'Cooperative First Service Welcome',
      'description': 'Applicable on Electrical Diagnostics, AC Deep Servicing & Carpentry.',
      'valid_till': '31 Dec 2026',
      'min_bill': 299,
      'is_coop_special': true,
    },
    {
      'code': 'ODISHA50',
      'discount': '₹50 FLAT OFF',
      'title': 'Monsoon Plumbing & Drain Special',
      'description': 'Valid on sanitary leak repairs, tap fitting, and overhead tank cleaning.',
      'valid_till': '15 Oct 2026',
      'min_bill': 199,
      'is_coop_special': false,
    },
    {
      'code': 'SENIORCARE',
      'discount': 'FREE INSPECTION',
      'title': 'Senior Citizen Support Initiative',
      'description': '100% waiver of basic call-out inspection charge for households with citizens 60+.',
      'valid_till': 'Statutory Perpetual',
      'min_bill': 0,
      'is_coop_special': true,
    },
    {
      'code': 'ECORECYCLE',
      'discount': '₹150 CASHBACK',
      'title': 'Green Scrap & Metal Recycling Credit',
      'description': 'Hand over damaged copper wires or scrap compressor coils to artisan for certified smelting.',
      'valid_till': '30 Nov 2026',
      'min_bill': 499,
      'is_coop_special': false,
    },
  ];

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
            'Coupons, Dividends & Rewards',
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Coin Balance Card
            _buildCoinHeroCard(),

            const SizedBox(height: 20),

            // Active Discount Vouchers Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'ACTIVE COOPERATIVE VOUCHERS',
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  '${_coupons.length} Available',
                  style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Coupons List
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _coupons.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final c = _coupons[index];
                final isSpecial = c['is_coop_special'] == true;

                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSpecial ? AppColors.accent.withValues(alpha: 0.6) : AppColors.borderLight,
                      width: isSpecial ? 1.5 : 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: isSpecial
                                    ? const Color(0xFFFEF3C7)
                                    : AppColors.primaryLight.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                isSpecial ? Icons.auto_awesome : Icons.local_offer,
                                color: isSpecial ? const Color(0xFFB45309) : AppColors.primary,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        c['discount'] as String,
                                        style: GoogleFonts.outfit(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w900,
                                          color: isSpecial ? const Color(0xFFB45309) : AppColors.primary,
                                        ),
                                      ),
                                      if (isSpecial) ...[
                                        const SizedBox(width: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFFEF3C7),
                                            borderRadius: BorderRadius.circular(4),
                                            border: Border.all(color: const Color(0xFFF59E0B)),
                                          ),
                                          child: Text(
                                            'STATE SUBSIDY',
                                            style: GoogleFonts.inter(
                                              fontSize: 9,
                                              fontWeight: FontWeight.bold,
                                              color: const Color(0xFF92400E),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    c['title'] as String,
                                    style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    c['description'] as String,
                                    style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.scaffoldBg,
                          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Code: ${c['code']} • Min: ₹${c['min_bill']}',
                              style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                            ),
                            InkWell(
                              onTap: () {
                                Clipboard.setData(ClipboardData(text: c['code'] as String));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    backgroundColor: AppColors.primary,
                                    content: Text('Coupon code "${c['code']}" copied to clipboard!'),
                                  ),
                                );
                              },
                              child: Row(
                                children: [
                                  const Icon(Icons.copy, size: 14, color: AppColors.primary),
                                  const SizedBox(width: 4),
                                  Text(
                                    'COPY CODE',
                                    style: GoogleFonts.outfit(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            // How it works card
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
                      const Icon(Icons.info_outline, color: AppColors.primary, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'How Prithvi Coins & Cooperative Dividends Work',
                        style: GoogleFonts.outfit(fontSize: 13.5, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _buildFaqRow('Earn 50 Coins for every completed service verified with Completion OTP.'),
                  _buildFaqRow('Earn 25 Coins for writing an honest star rating review for your artisan.'),
                  _buildFaqRow('1 Prithvi Coin = ₹1 Direct Discount at checkout on any cooperative booking.'),
                  _buildFaqRow('Odisha State Cooperative Federation shares 10% of annual surplus as citizen dividend coins.'),
                ],
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => context.go('/book-service'),
                icon: const Icon(Icons.flash_on),
                label: const Text('Book a Service & Apply Coupon'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

  Widget _buildCoinHeroCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFD4A843), Color(0xFFB45309)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD4A843).withValues(alpha: 0.35),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'YOUR PRITHVI COINS BALANCE',
                style: GoogleFonts.outfit(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                  color: Colors.white70,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '1 COIN = ₹1.00',
                  style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.monetization_on, color: Colors.white, size: 36),
              const SizedBox(width: 10),
              Text(
                '$_coinBalance',
                style: GoogleFonts.outfit(
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Coins (₹$_coinBalance value)',
                style: GoogleFonts.inter(fontSize: 13, color: Colors.white70, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const Divider(height: 20, color: Colors.white30),
          Row(
            children: [
              const Icon(Icons.redeem, color: Colors.white, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Auto-applied at checkout to reduce your total booking invoice.',
                  style: GoogleFonts.inter(fontSize: 11.5, color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFaqRow(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle_outline, color: AppColors.primary, size: 14),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.inter(fontSize: 11.5, color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}
