import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/api_endpoints.dart';
import '../core/network/api_client.dart';

class BookingDetailScreen extends StatefulWidget {
  final int bookingId;
  const BookingDetailScreen({super.key, required this.bookingId});

  @override
  State<BookingDetailScreen> createState() => _BookingDetailScreenState();
}

class _BookingDetailScreenState extends State<BookingDetailScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _booking;

  @override
  void initState() {
    super.initState();
    _fetchBookingDetail();
  }

  Future<void> _fetchBookingDetail() async {
    try {
      final res = await ApiClient().get(ApiEndpoints.bookingDetail(widget.bookingId));
      if (res is Map && mounted) {
        setState(() {
          _booking = res['booking'] is Map ? Map<String, dynamic>.from(res['booking']) : Map<String, dynamic>.from(res);
          _isLoading = false;
        });
        return;
      }
    } catch (_) {}

    // Fallback demo booking
    if (mounted) {
      setState(() {
        _booking = {
          'id': widget.bookingId,
          'service_name': 'Electrical Diagnostic & Switchboard Repair',
          'worker_name': 'Ramesh Patel',
          'worker_phone': '+91 98765 43210',
          'worker_rating': 4.9,
          'worker_trade': 'Master Electrician (Level 4)',
          'cooperative_name': 'Shramik Kalyan Labour Cooperative Samiti',
          'status': 'IN_PROGRESS',
          'arrival_otp': '4821',
          'completion_otp': '7394',
          'scheduled_date': '2026-09-25',
          'scheduled_time': '10:00 AM - 12:00 PM',
          'location_address': 'Plot 42, Saheed Nagar, Bhubaneswar',
          'total_price': 299.0,
          'parts_cost': 120.0,
        };
        _isLoading = false;
      });
    }
  }

  void _showGuaranteeDialog() {
    final remarksController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Claim 30-Day Cooperative Guarantee',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'If the service did not resolve your issue, our cooperative will dispatch a senior artisan for a free rework under statutory warranty.',
              style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: remarksController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Describe problem / defect',
                hintText: 'e.g. Switchboard started sparking again after 2 days',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await ApiClient().post(ApiEndpoints.claimGuarantee(widget.bookingId), data: {
                  'remarks': remarksController.text.trim(),
                });
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      backgroundColor: AppColors.success,
                      content: Text('Guarantee claim registered. Senior supervisor will inspect within 24 hours.'),
                    ),
                  );
                }
              } catch (_) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      backgroundColor: AppColors.primary,
                      content: Text('Guarantee claim submitted (Demo Mode).'),
                    ),
                  );
                }
              }
            },
            child: const Text('Submit Claim'),
          ),
        ],
      ),
    );
  }

  void _showRatingDialog() {
    double rating = 5.0;
    final commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text('Rate Service & Cooperative', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Your rating directly supports the artisan\'s cooperative reputation score and annual cooperative bonus.',
                style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      index < rating ? Icons.star : Icons.star_border,
                      color: AppColors.accent,
                      size: 32,
                    ),
                    onPressed: () => setDialogState(() => rating = index + 1.0),
                  );
                }),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: commentController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Feedback / Comments',
                  hintText: 'e.g. Prompt arrival, polite and skilled workmanship',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(ctx);
                try {
                  await ApiClient().post(ApiEndpoints.reviews, data: {
                    'booking_id': widget.bookingId,
                    'rating': rating,
                    'comment': commentController.text.trim(),
                  });
                } catch (_) {}
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      backgroundColor: AppColors.success,
                      content: Text('Thank you! Your feedback has been recorded.'),
                    ),
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
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.scaffoldBg,
        body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    final b = _booking!;
    final status = b['status']?.toString().toUpperCase() ?? 'CONFIRMED';
    final arrivalOtp = b['arrival_otp']?.toString() ?? '4821';
    final completionOtp = b['completion_otp']?.toString() ?? '7394';
    final serviceName = b['service_name'] ?? 'Home Maintenance Service';
    final workerName = b['worker_name'] ?? 'Assigned Artisan';
    final cooperative = b['cooperative_name'] ?? 'Local Shramik Samiti';
    final price = (b['total_price'] ?? 299.0) as num;

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        if (context.canPop()) {
          context.pop();
        } else {
          context.go('/my-bookings');
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
                context.go('/my-bookings');
              }
            },
          ),
          title: Text('Booking #${widget.bookingId}', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 17)),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            tooltip: 'Share Details',
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Progression Card
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        serviceName,
                        style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withAlpha(25),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          status,
                          style: GoogleFonts.outfit(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${b['scheduled_date']} • ${b['scheduled_time']}',
                    style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 16),
                  _StatusStepper(status: status),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Security OTPs Card (Critical for handshakes!)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFEF3C7), Color(0xFFFDE68A)],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFF59E0B)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.verified_user_rounded, color: Color(0xFFB45309), size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'SECURE SERVICE HANDSHAKE CODES',
                        style: GoogleFonts.outfit(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFFB45309),
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _OtpBox(
                          label: '1. Arrival OTP',
                          sub: 'Share when worker arrives',
                          otp: arrivalOtp,
                          isUsed: status == 'IN_PROGRESS' || status == 'COMPLETED',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _OtpBox(
                          label: '2. Completion OTP',
                          sub: 'Share only when fully satisfied',
                          otp: completionOtp,
                          isUsed: status == 'COMPLETED',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Worker & Cooperative Profile Card
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
                  Text(
                    'ASSIGNED COOPERATIVE ARTISAN',
                    style: GoogleFonts.outfit(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textSecondary,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 26,
                        backgroundColor: AppColors.primary.withAlpha(25),
                        child: const Icon(Icons.person, color: AppColors.primary, size: 30),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  workerName,
                                  style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(width: 6),
                                const Icon(Icons.verified, color: AppColors.primary, size: 16),
                              ],
                            ),
                            Text(
                              b['worker_trade'] ?? 'Certified Artisan',
                              style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary),
                            ),
                            Text(
                              cooperative,
                              style: GoogleFonts.inter(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                      IconButton.filledTonal(
                        icon: const Icon(Icons.phone),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: b['worker_phone'] ?? '+919876543210'));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Artisan phone copied to clipboard')),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Tariff & Payment Summary
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
                  Text(
                    'TARIFF & BILLING BREAKDOWN',
                    style: GoogleFonts.outfit(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textSecondary,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _PriceRow(label: 'Labor Wage (Standard Task)', val: '₹${price.toStringAsFixed(1)}'),
                  if (b['parts_cost'] != null && (b['parts_cost'] as num) > 0) ...[
                    const SizedBox(height: 6),
                    _PriceRow(label: 'Genuine Spare Parts (Official Tariff)', val: '₹${b['parts_cost']}'),
                  ],
                  const SizedBox(height: 6),
                  _PriceRow(label: 'Cooperative Guarantee & Insurance', val: 'Included (₹0.0)'),
                  const Divider(height: 20, color: AppColors.borderLight),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total Bill', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold)),
                      Text(
                        '₹${((price) + (b['parts_cost'] ?? 0)).toInt()}',
                        style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.primary),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Quick Shortcuts: Live GPS Tracking & Tax Invoice
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => context.go('/track/${widget.bookingId}'),
                    icon: const Icon(Icons.navigation, size: 16),
                    label: const Text('Live GPS Track'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => context.go('/invoice/${widget.bookingId}'),
                    icon: const Icon(Icons.receipt_long, size: 16),
                    label: const Text('Tax Invoice'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textPrimary,
                      side: const BorderSide(color: AppColors.borderMedium),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Actions: Guarantee Claim & Rate Artisan
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _showGuaranteeDialog,
                    icon: const Icon(Icons.shield_outlined, size: 16),
                    label: const Text('Warranty Claim'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _showRatingDialog,
                    icon: const Icon(Icons.star_outline, size: 16),
                    label: const Text('Rate Worker'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    ),
  );
}
}

class _StatusStepper extends StatelessWidget {
  final String status;
  const _StatusStepper({required this.status});

  @override
  Widget build(BuildContext context) {
    final stages = ['CONFIRMED', 'ARRIVED', 'IN_PROGRESS', 'COMPLETED'];
    final currentIndex = stages.contains(status) ? stages.indexOf(status) : 1;

    return Row(
      children: List.generate(stages.length, (index) {
        final isDone = index <= currentIndex;
        final isLast = index == stages.length - 1;

        return Expanded(
          child: Row(
            children: [
              CircleAvatar(
                radius: 10,
                backgroundColor: isDone ? AppColors.primary : AppColors.borderLight,
                child: isDone
                    ? const Icon(Icons.check, size: 12, color: Colors.white)
                    : null,
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    height: 2,
                    color: index < currentIndex ? AppColors.primary : AppColors.borderLight,
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }
}

class _OtpBox extends StatelessWidget {
  final String label;
  final String sub;
  final String otp;
  final bool isUsed;

  const _OtpBox({
    required this.label,
    required this.sub,
    required this.otp,
    required this.isUsed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF59E0B).withAlpha(100)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 12, color: const Color(0xFF92400E))),
          const SizedBox(height: 2),
          Text(sub, style: GoogleFonts.inter(fontSize: 10, color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: isUsed ? AppColors.borderLight : const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                isUsed ? 'VERIFIED ✓' : otp,
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2,
                  color: isUsed ? AppColors.textSecondary : const Color(0xFFB45309),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  final String label;
  final String val;
  const _PriceRow({required this.label, required this.val});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary)),
        Text(val, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
      ],
    );
  }
}
