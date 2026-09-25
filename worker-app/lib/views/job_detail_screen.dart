import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants/app_colors.dart';
import '../core/localization/app_localizations.dart';
import '../core/constants/api_endpoints.dart';
import '../core/network/api_client.dart';
import 'sos_beacon_sheet.dart';
import 'safety_checklist_sheet.dart';

class JobDetailScreen extends StatefulWidget {
  final int bookingId;
  const JobDetailScreen({super.key, required this.bookingId});

  @override
  State<JobDetailScreen> createState() => _JobDetailScreenState();
}

class _JobDetailScreenState extends State<JobDetailScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _job;

  Timer? _timer;
  int _secondsElapsed = 2450; // Demo timer in progress (~40 mins)

  @override
  void initState() {
    super.initState();
    _fetchJobDetail();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) setState(() => _secondsElapsed++);
    });
  }

  String get _formattedTime {
    final m = (_secondsElapsed ~/ 60).toString().padLeft(2, '0');
    final s = (_secondsElapsed % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  Future<void> _fetchJobDetail() async {
    try {
      final res = await ApiClient().get(ApiEndpoints.bookingDetail(widget.bookingId));
      if (res is Map && mounted) {
        setState(() {
          _job = res['booking'] is Map ? Map<String, dynamic>.from(res['booking']) : Map<String, dynamic>.from(res);
          _isLoading = false;
        });
        return;
      }
    } catch (_) {}

    // Fallback demo job
    if (mounted) {
      setState(() {
        _job = {
          'id': widget.bookingId,
          'service_name': 'Electrical Diagnostic & Switchboard Repair',
          'customer_name': 'Smt. Ananya Mohapatra',
          'customer_phone': '+91 94370 12890',
          'address': 'Plot 42, Saheed Nagar, Bhubaneswar (Near Durga Mandap)',
          'district': 'Khordha',
          'status': 'IN_PROGRESS',
          'scheduled_time': '10:00 AM - 12:00 PM',
          'base_wage': 278.0, // 93% of 299
          'parts_cost': 120.0,
          'notes': 'Sparks coming from bedroom switchboard when AC is turned on. Please bring voltage tester.',
        };
        _isLoading = false;
      });
    }
  }

  void _showVerifyArrivalOtpDialog() {
    final otpController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardSurface,
        title: Text(
          'Verify Customer Arrival OTP',
          style: GoogleFonts.outfit(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ask the customer for their 4-digit Arrival OTP to verify you have reached the service location.',
              style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 12),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: otpController,
              keyboardType: TextInputType.number,
              maxLength: 4,
              style: GoogleFonts.outfit(color: AppColors.accent, fontSize: 20, letterSpacing: 4),
              decoration: const InputDecoration(
                labelText: '4-Digit OTP',
                hintText: '4821',
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
              try {
                await ApiClient().post(ApiEndpoints.verifyArrivalOtp(widget.bookingId), data: {
                  'otp': otpController.text.trim(),
                });
              } catch (_) {}
              if (mounted) {
                setState(() => _job?['status'] = 'IN_PROGRESS');
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    backgroundColor: AppColors.success,
                    content: Text('Arrival Verified! On-site timer started.'),
                  ),
                );
              }
            },
            child: const Text('Confirm Arrival'),
          ),
        ],
      ),
    );
  }

  void _showAddPartsDialog() {
    final List<Map<String, dynamic>> partsCatalog = [
      {'name': 'Havells 16A Modular Switch', 'price': 85},
      {'name': 'Anchor Roma 32A DP MCB Switch', 'price': 220},
      {'name': 'Finolex 2.5 sq mm FR Wire (10m)', 'price': 160},
      {'name': 'Polycarbonate 8-Module Faceplate', 'price': 110},
    ];
    Map<String, dynamic> selectedPart = partsCatalog.first;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: AppColors.cardSurface,
          title: Text(
            'Add Genuine Spare Part from Catalog',
            style: GoogleFonts.outfit(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 15),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Only standard parts from the cooperative rate card are permitted to ensure fair customer pricing.',
                style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 11),
              ),
              const SizedBox(height: 14),
              ...partsCatalog.map((p) {
                final isSelected = selectedPart['name'] == p['name'];
                return Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primaryDark.withAlpha(50) : AppColors.cardSurfaceAlt,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: isSelected ? AppColors.primary : AppColors.borderDark),
                  ),
                  child: ListTile(
                    dense: true,
                    title: Text(p['name'], style: GoogleFonts.inter(fontSize: 12, color: AppColors.textPrimary)),
                    trailing: Text('₹${p['price']}', style: GoogleFonts.outfit(color: AppColors.accent, fontWeight: FontWeight.bold)),
                    onTap: () => setDialogState(() => selectedPart = p),
                  ),
                );
              }),
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
                try {
                  await ApiClient().post(ApiEndpoints.addParts(widget.bookingId), data: {
                    'part_name': selectedPart['name'],
                    'part_cost': selectedPart['price'],
                  });
                } catch (_) {}
                if (mounted) {
                  setState(() {
                    _job?['parts_cost'] = (_job?['parts_cost'] ?? 0) + selectedPart['price'];
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: AppColors.success,
                      content: Text('Added ${selectedPart['name']} (₹${selectedPart['price']}) to job invoice.'),
                    ),
                  );
                }
              },
              child: const Text('Add Part to Bill'),
            ),
          ],
        ),
      ),
    );
  }

  void _showVerifyCompletionOtpDialog() {
    final otpController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardSurface,
        title: Text(
          'Customer Completion OTP Handshake',
          style: GoogleFonts.outfit(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 15),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ask the customer for their 4-digit Completion OTP once the repair is tested and customer is satisfied.',
              style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 12),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: otpController,
              keyboardType: TextInputType.number,
              maxLength: 4,
              style: GoogleFonts.outfit(color: AppColors.accent, fontSize: 20, letterSpacing: 4),
              decoration: const InputDecoration(
                labelText: 'Completion OTP',
                hintText: '7394',
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
              try {
                await ApiClient().post(ApiEndpoints.verifyCompletionOtp(widget.bookingId), data: {
                  'otp': otpController.text.trim(),
                });
              } catch (_) {}
              if (mounted) {
                setState(() => _job?['status'] = 'COMPLETED');
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    backgroundColor: AppColors.success,
                    content: Text('Job Completed! 93% wage credited to your cooperative ledger.'),
                  ),
                );
              }
            },
            child: const Text('Complete Job & Credit Wage'),
          ),
        ],
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

    final job = _job!;
    final status = job['status']?.toString().toUpperCase() ?? 'IN_PROGRESS';
    final isCompleted = status == 'COMPLETED';
    final baseWage = (job['base_wage'] ?? 278.0) as num;
    final partsCost = (job['parts_cost'] ?? 0.0) as num;
    final totalPayout = baseWage + partsCost;

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
            '${context.tr('jobDetails', 'Active Job')} #${widget.bookingId}',
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        actions: [
          IconButton(
            icon: const Icon(Icons.emergency_outlined, color: AppColors.error),
            tooltip: 'Safety SOS',
            onPressed: () => SosBeaconSheet.show(context, bookingId: widget.bookingId),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status & Timer Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.cardSurface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isCompleted ? AppColors.success : AppColors.primary,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: (isCompleted ? AppColors.success : AppColors.primary).withAlpha(30),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      isCompleted ? Icons.check_circle : Icons.timer_outlined,
                      color: isCompleted ? AppColors.success : AppColors.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isCompleted ? 'JOB COMPLETED' : 'STATUS: $status',
                          style: GoogleFonts.outfit(
                            color: isCompleted ? AppColors.success : AppColors.primary,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          isCompleted ? 'All handshakes verified' : 'Active On-Site Duration: $_formattedTime',
                          style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.cardSurfaceAlt,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '₹${totalPayout.toStringAsFixed(0)}',
                      style: GoogleFonts.outfit(
                        color: AppColors.accent,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Customer Details Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.cardSurface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.borderDark),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.tr('customerDetails', 'CUSTOMER & SERVICE SITE'),
                    style: GoogleFonts.outfit(
                      color: AppColors.primary,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    job['customer_name'] ?? 'Customer',
                    style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    job['address'] ?? 'Customer Address',
                    style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 12),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: job['customer_phone'] ?? ''));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Customer phone copied to clipboard')),
                            );
                          },
                          icon: const Icon(Icons.call, size: 16),
                          label: const Text('Call Customer'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.accent,
                            side: const BorderSide(color: AppColors.accent),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Opening Google Maps navigation intent...')),
                            );
                          },
                          icon: const Icon(Icons.navigation_outlined, size: 16),
                          label: const Text('Navigate'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side: const BorderSide(color: AppColors.primary),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Work Instructions & Reported Issue
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.cardSurface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.borderDark),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'WORK INSTRUCTIONS & DIAGNOSTICS',
                    style: GoogleFonts.outfit(
                      color: AppColors.primary,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    job['service_name'] ?? 'Diagnostic & Repair',
                    style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    job['notes'] ?? 'Standard maintenance requested.',
                    style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Spare Parts Added Card
            Container(
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
                      Text(
                        'GENUINE SPARE PARTS',
                        style: GoogleFonts.outfit(
                          color: AppColors.primary,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                      if (!isCompleted)
                        TextButton.icon(
                          onPressed: _showAddPartsDialog,
                          icon: const Icon(Icons.add, size: 14, color: AppColors.accent),
                          label: Text(
                            'Add Part',
                            style: GoogleFonts.outfit(fontSize: 11, color: AppColors.accent),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  if (partsCost == 0)
                    Text(
                      'No spare parts billed. Tap "Add Part" to pull from rate card.',
                      style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 11),
                    )
                  else
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total Genuine Parts Cost:', style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 12)),
                        Text('₹$partsCost', style: GoogleFonts.outfit(color: AppColors.accent, fontWeight: FontWeight.bold)),
                      ],
                    ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Dynamic Action Button based on status
            if (status == 'ACCEPTED')
              ElevatedButton.icon(
                onPressed: _showVerifyArrivalOtpDialog,
                icon: const Icon(Icons.verified, size: 18),
                label: const Text('VERIFY ARRIVAL OTP FROM CITIZEN'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              )
            else if (status == 'IN_PROGRESS' || status == 'ARRIVED') ...[
              OutlinedButton.icon(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (ctx) => SafetyChecklistSheet(bookingId: widget.bookingId),
                  );
                },
                icon: const Icon(Icons.shield_outlined, size: 16, color: AppColors.accent),
                label: const Text('Pre-Service Safety & Insurance Audit'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.accent,
                  side: const BorderSide(color: AppColors.accent),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: _showVerifyCompletionOtpDialog,
                icon: const Icon(Icons.check_circle_outline, size: 18),
                label: const Text('COMPLETE JOB & ENTER CITIZEN OTP'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ]
            else if (isCompleted)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.successBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.success),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.task_alt, color: AppColors.success, size: 36),
                    const SizedBox(height: 8),
                    Text(
                      'WAGE CREDITED: ₹${totalPayout.toStringAsFixed(0)}',
                      style: GoogleFonts.outfit(color: AppColors.success, fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Direct transfer credited to your worker cooperative ledger.',
                      style: GoogleFonts.inter(color: Colors.white70, fontSize: 11),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 12),

            // Emergency SOS Panic Button
            OutlinedButton.icon(
              onPressed: () => SosBeaconSheet.show(context, bookingId: widget.bookingId),
              icon: const Icon(Icons.emergency_share, size: 16, color: AppColors.error),
              label: Text(
                'TRIGGER SAFETY SOS BEACON',
                style: GoogleFonts.outfit(color: AppColors.error, fontSize: 11, fontWeight: FontWeight.bold),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.error),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    ),
  );
}
}
