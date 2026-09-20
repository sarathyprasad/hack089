import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/gov_app_bar.dart';
import '../../core/widgets/gov_loading_indicator.dart';
import '../../core/widgets/status_badge.dart';
import '../../core/widgets/tariff_breakdown_card.dart';
import '../../providers/booking_provider.dart';
import 'payment_bottom_sheet.dart';

class BookingDetailScreen extends StatefulWidget {
  final int bookingId;
  const BookingDetailScreen({super.key, required this.bookingId});

  @override
  State<BookingDetailScreen> createState() => _BookingDetailScreenState();
}

class _BookingDetailScreenState extends State<BookingDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BookingProvider>().fetchBookingDetail(widget.bookingId);
    });
  }

  Future<void> _makeCall(String? phone) async {
    if (phone == null || phone.isEmpty) return;
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _showPaymentModal(double amount) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => PaymentBottomSheet(bookingId: widget.bookingId, totalAmount: amount),
    );
  }

  void _showReviewDialog() {
    int rating = 5;
    final commentCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Artisan Rating & Feedback', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  5,
                  (i) => IconButton(
                    icon: Icon(
                      i < rating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 32,
                    ),
                    onPressed: () => setDialogState(() => rating = i + 1),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: commentCtrl,
                decoration: const InputDecoration(labelText: 'Citizen Comment', hintText: 'Punctual, professional repair...'),
                maxLines: 2,
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                final bProv = context.read<BookingProvider>();
                await bProv.submitReview({
                  'bookingId': widget.bookingId,
                  'workerId': bProv.currentBooking?.workerId ?? 1,
                  'rating': rating,
                  'comment': commentCtrl.text.trim(),
                  'tags': ['Punctual', 'Quality Workmanship', 'Fair Pricing'],
                });
                if (ctx.mounted) Navigator.pop(ctx);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Review submitted. Thank you!')),
                  );
                }
              },
              child: const Text('Submit Rating'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bProv = context.watch<BookingProvider>();
    final b = bProv.currentBooking;

    return Scaffold(
      appBar: GovAppBar(title: b?.bookingCode ?? 'Booking Details'),
      body: bProv.isLoading
          ? const GovLoadingIndicator.fullScreen(
              title: 'Synchronizing Booking Escrow...',
              subtitle: 'Fetching live dispatch status, security PIN and statutory receipt',
            )
          : b == null
              ? const Center(child: Text('Booking not found.'))
              : RefreshIndicator(
                  onRefresh: () => bProv.fetchBookingDetail(widget.bookingId),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header Summary
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              b.bookingCode, 
                              style: TextStyle(
                                fontSize: 13, 
                                fontWeight: FontWeight.bold, 
                                color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                              ),
                            ),
                            StatusBadge(status: b.status, isEmergency: b.isEmergency),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                b.serviceName, 
                                style: TextStyle(
                                  fontSize: 20, 
                                  fontWeight: FontWeight.bold, 
                                  color: isDark ? AppColors.darkTextPrimary : AppColors.primaryNavy,
                                ),
                              ),
                            ),
                            if (b.squadSize > 1)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF312E81) : const Color(0xFFE0E7FF),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: const Color(0xFF6366F1)),
                                ),
                                child: Text(
                                  '${b.squadSize} Artisans Squad',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF4338CA),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // 5-Step Visual Lifecycle Timeline
                        _lifecycleTimeline(b.status, isDark),

                        const SizedBox(height: 16),

                        // Arrival & Completion OTPs Banner
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: isDark 
                                ? AppColors.darkInfoBg.withValues(alpha: 0.35) 
                                : const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isDark 
                                  ? AppColors.darkInfoFg.withValues(alpha: 0.4) 
                                  : AppColors.infoBlue.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.vpn_key_outlined, 
                                    size: 18, 
                                    color: isDark ? AppColors.darkInfoFg : AppColors.infoBlue,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'STATUTORY OTP HANDSHAKE CODES',
                                    style: TextStyle(
                                      fontSize: 11, 
                                      fontWeight: FontWeight.bold, 
                                      color: isDark ? AppColors.darkInfoFg : AppColors.infoBlue, 
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Expanded(
                                    child: _otpCard(
                                      title: 'Arrival OTP',
                                      otp: b.arrivalOtp ?? '----',
                                      isVerified: b.arrivalOtpVerified,
                                      desc: 'Share only when worker arrives on-site',
                                      isDark: isDark,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: _otpCard(
                                      title: 'Completion OTP',
                                      otp: b.completionOtp ?? '----',
                                      isVerified: b.completionOtpVerified,
                                      desc: 'Share after inspecting completed work',
                                      isDark: isDark,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Assigned Worker Card & Live Route Tracking
                        Card(
                          color: isDark ? AppColors.darkCard : Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.borderLight),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Assigned Cooperative Artisan', 
                                  style: TextStyle(
                                    fontSize: 12, 
                                    fontWeight: FontWeight.bold, 
                                    color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 22,
                                      backgroundColor: isDark 
                                          ? AppColors.secondarySaffron.withValues(alpha: 0.2) 
                                          : AppColors.primaryNavy.withValues(alpha: 0.1),
                                      child: Icon(
                                        Icons.engineering, 
                                        color: isDark ? AppColors.secondarySaffron : AppColors.primaryNavy,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            b.workerName ?? 'Artisan assigned', 
                                            style: TextStyle(
                                              fontSize: 14, 
                                              fontWeight: FontWeight.bold,
                                              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                                            ),
                                          ),
                                          Text(
                                            b.workerTrade ?? 'Cooperative Specialist', 
                                            style: TextStyle(
                                              fontSize: 11, 
                                              color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (b.workerPhone != null)
                                      IconButton(
                                        icon: const Icon(Icons.phone, color: AppColors.accentGreen),
                                        onPressed: () => _makeCall(b.workerPhone),
                                      ),
                                  ],
                                ),
                                const Divider(height: 16),
                                ElevatedButton.icon(
                                  onPressed: () => context.go('/customer/bookings/${b.id}/map'),
                                  icon: const Icon(Icons.navigation_outlined, size: 16),
                                  label: const Text('View Live Route & Worker Telemetry'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: isDark ? AppColors.primaryNavy : AppColors.primaryNavy,
                                    minimumSize: const Size.fromHeight(38),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Tariff Breakdown with Cooperative Resolution Splits
                        TariffBreakdownCard(
                          totalAmount: b.totalAmount,
                          customWorkerWage: b.amount,
                          customWelfare: b.cooperativeFee,
                          customPlatform: b.platformFee,
                        ),

                        if (b.transitCompensationFee > 0) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.darkCard : const Color(0xFFFFF7ED),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFFFDBA74)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.two_wheeler, size: 16, color: Color(0xFFC2410C)),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Doorstep Transit Compensation of ₹${b.transitCompensationFee.toStringAsFixed(2)} credited to worker.',
                                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF9A3412)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        const SizedBox(height: 16),

                        // Payment & Form IV Invoice Actions
                        if (!b.isPaid)
                          ElevatedButton.icon(
                            onPressed: () => _showPaymentModal(b.totalAmount),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.accentGreen,
                              minimumSize: const Size.fromHeight(44),
                            ),
                            icon: const Icon(Icons.payment, size: 18),
                            label: Text('Pay ₹${b.totalAmount.toStringAsFixed(2)} via UPI / Card', style: const TextStyle(fontWeight: FontWeight.bold)),
                          )
                        else ...[
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isDark 
                                  ? AppColors.darkGreenBg.withValues(alpha: 0.3) 
                                  : AppColors.greenLight,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isDark ? AppColors.darkGreenFg.withValues(alpha: 0.5) : AppColors.greenBorder,
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.check_circle, color: AppColors.accentGreen),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('Payment Verified (₹ Escrow Released)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.accentGreen)),
                                      Text(
                                        'Statutory 30-day rework warranty active', 
                                        style: TextStyle(
                                          fontSize: 11, 
                                          color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                TextButton(
                                  onPressed: () => context.go('/customer/bookings/${b.id}/invoice'),
                                  child: const Text('Tax Invoice →'),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: _showReviewDialog,
                                  icon: const Icon(Icons.star_outline, size: 16),
                                  label: const Text('Rate Artisan'),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () async {
                                    final ok = await bProv.claimGuarantee(b.id);
                                    if (context.mounted && ok) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('30-Day Guarantee claim filed. Senior artisan dispatched.')),
                                      );
                                    }
                                  },
                                  icon: const Icon(Icons.shield_outlined, size: 16),
                                  label: const Text('Claim Warranty'),
                                ),
                              ),
                            ],
                          ),
                        ],

                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _lifecycleTimeline(String currentStatus, bool isDark) {
    final stages = ['REQUESTED', 'MATCHED', 'ACCEPTED', 'IN_PROGRESS', 'COMPLETED'];
    final currentIndex = stages.indexOf(currentStatus.toUpperCase());

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white, 
        borderRadius: BorderRadius.circular(8), 
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.borderLight),
      ),
      child: Row(
        children: stages.asMap().entries.map((entry) {
          final idx = entry.key;
          final name = entry.value;
          final isPastOrCurrent = idx <= currentIndex;
          final isCurrent = idx == currentIndex;

          return Expanded(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 12,
                  backgroundColor: isCurrent
                      ? (isDark ? AppColors.secondarySaffron : AppColors.primaryNavy)
                      : isPastOrCurrent
                          ? AppColors.accentGreen
                          : (isDark ? AppColors.darkCardAlt : const Color(0xFFCBD5E1)),
                  child: Text(
                    '${idx + 1}',
                    style: TextStyle(
                      fontSize: 10, 
                      fontWeight: FontWeight.bold, 
                      color: isCurrent && isDark ? AppColors.navyDark : Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  name.replaceAll('_', ' '),
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
                    color: isCurrent 
                        ? (isDark ? AppColors.secondarySaffron : AppColors.primaryNavy) 
                        : (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _otpCard({
    required String title, 
    required String otp, 
    required bool isVerified, 
    required String desc,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isVerified 
              ? AppColors.accentGreen 
              : (isDark ? AppColors.darkBorder : AppColors.borderLight),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title, 
                style: TextStyle(
                  fontSize: 11, 
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                ),
              ),
              if (isVerified)
                const Icon(Icons.check_circle, size: 14, color: AppColors.accentGreen),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            otp,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              letterSpacing: 3,
              color: isVerified 
                  ? AppColors.accentGreen 
                  : (isDark ? AppColors.secondarySaffron : AppColors.primaryNavy),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            desc, 
            style: TextStyle(
              fontSize: 9, 
              color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
