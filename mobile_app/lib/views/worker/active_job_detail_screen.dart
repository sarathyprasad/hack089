import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/gov_app_bar.dart';
import '../../core/widgets/status_badge.dart';
import '../../core/widgets/tariff_breakdown_card.dart';
import '../../models/booking_model.dart';
import '../../providers/worker_portal_provider.dart';

class ActiveJobDetailScreen extends StatefulWidget {
  final int bookingId;
  const ActiveJobDetailScreen({super.key, required this.bookingId});

  @override
  State<ActiveJobDetailScreen> createState() => _ActiveJobDetailScreenState();
}

class _ActiveJobDetailScreenState extends State<ActiveJobDetailScreen> {
  final _otpCtrl = TextEditingController();
  final _partNameCtrl = TextEditingController();
  final _partPriceCtrl = TextEditingController();
  bool _photoUploaded = false;
  bool _beforePhoto = false;
  bool _afterPhoto = false;

  @override
  void dispose() {
    _otpCtrl.dispose();
    _partNameCtrl.dispose();
    _partPriceCtrl.dispose();
    super.dispose();
  }

  BookingModel? _findBooking(WorkerPortalProvider prov) {
    try {
      return prov.activeOrders.firstWhere((b) => b.id == widget.bookingId);
    } catch (_) {
      try {
        return prov.incomingQueue.firstWhere((b) => b.id == widget.bookingId);
      } catch (_) {
        return null;
      }
    }
  }

  void _showOtpDialog(String type) {
    final isArrival = type == 'arrival';
    _otpCtrl.clear();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          isArrival ? 'Verify Citizen Arrival OTP' : 'Verify Citizen Completion OTP',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryNavy),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isArrival
                  ? 'Request the citizen\'s 4-digit Arrival OTP before starting any work. This protects both parties.'
                  : 'Request the citizen\'s 4-digit Completion OTP after they have inspected the completed repair.',
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _otpCtrl,
              decoration: InputDecoration(
                labelText: '4-Digit OTP',
                hintText: '••••',
                prefixIcon: const Icon(Icons.lock, size: 18),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              keyboardType: TextInputType.number,
              maxLength: 4,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 10),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_otpCtrl.text.length != 4) return;
              final prov = context.read<WorkerPortalProvider>();
              await prov.handleJobAction(
                widget.bookingId,
                isArrival ? 'verify_arrival_otp' : 'verify_completion_otp',
              );
              if (ctx.mounted) Navigator.pop(ctx);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: AppColors.accentGreen,
                    content: Text(isArrival ? 'Arrival OTP verified! Work authorized.' : 'Completion OTP verified! Job completed.'),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryNavy),
            child: const Text('Verify OTP'),
          ),
        ],
      ),
    );
  }

  void _showAddPartDialog() {
    _partNameCtrl.clear();
    _partPriceCtrl.clear();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Spare Part from Cooperative Catalog', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.primaryNavy)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Parts are sourced from locked cooperative catalog at government-controlled ceiling prices. No market markup allowed.',
              style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _partNameCtrl,
              decoration: InputDecoration(
                labelText: 'Part Name',
                hintText: 'e.g., 5A MCB Switch, 3-Pin Socket',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _partPriceCtrl,
              decoration: InputDecoration(
                labelText: 'Cooperative Ceiling Price (₹)',
                hintText: '0',
                prefixText: '₹ ',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (_partNameCtrl.text.isNotEmpty && _partPriceCtrl.text.isNotEmpty) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: AppColors.accentGreen,
                    content: Text('Added "${_partNameCtrl.text}" — ₹${_partPriceCtrl.text} (Cooperative price locked)'),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryNavy),
            child: const Text('Add Part'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final prov = context.watch<WorkerPortalProvider>();
    final booking = _findBooking(prov);

    return Scaffold(
      appBar: const GovAppBar(title: 'Active Work Order'),
      body: booking == null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.assignment_outlined, 
                    size: 52, 
                    color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Work order not found', 
                    style: TextStyle(color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status Header
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [AppColors.primaryNavy, AppColors.navyDark]),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Work Order #${booking.id}',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                            StatusBadge(status: booking.status),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          booking.serviceName,
                          style: const TextStyle(fontSize: 14, color: AppColors.secondarySaffron, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.person, size: 14, color: Colors.white70),
                            const SizedBox(width: 4),
                            Text(
                              'Citizen: ${booking.customerName}',
                              style: const TextStyle(fontSize: 12, color: Colors.white70),
                            ),
                          ],
                        ),
                        if (booking.locationAddress.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              const Icon(Icons.location_on, size: 14, color: Colors.white70),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  booking.locationAddress,
                                  style: const TextStyle(fontSize: 12, color: Colors.white70),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 5-Step Lifecycle Progress
                  Text(
                    'Service Lifecycle Progress', 
                    style: TextStyle(
                      fontSize: 13, 
                      fontWeight: FontWeight.bold, 
                      color: isDark ? AppColors.darkTextPrimary : AppColors.primaryNavy,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildLifecycleTracker(booking.status, isDark),
                  const SizedBox(height: 16),

                  // Tariff Breakdown
                  TariffBreakdownCard(
                    totalAmount: booking.totalAmount,
                  ),
                  const SizedBox(height: 16),

                  // Action Cards based on current status
                  ..._buildActionCards(booking, isDark),
                ],
              ),
            ),
    );
  }

  Widget _buildLifecycleTracker(String currentStatus, bool isDark) {
    final steps = ['REQUESTED', 'MATCHED', 'ACCEPTED', 'IN_PROGRESS', 'COMPLETED'];
    final currentIdx = steps.indexOf(currentStatus.toUpperCase());

    return Row(
      children: List.generate(steps.length, (i) {
        final isCompleted = i <= currentIdx;
        final isCurrent = i == currentIdx;
        final label = steps[i].replaceAll('_', '\n');

        return Expanded(
          child: Column(
            children: [
              Row(
                children: [
                  if (i > 0) 
                    Expanded(
                      child: Container(
                        height: 2, 
                        color: isCompleted 
                            ? AppColors.accentGreen 
                            : (isDark ? AppColors.darkBorder : AppColors.borderLight),
                      ),
                    ),
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isCompleted 
                          ? AppColors.accentGreen 
                          : (isDark ? AppColors.darkCardAlt : AppColors.borderLight),
                      border: isCurrent 
                          ? Border.all(color: isDark ? AppColors.secondarySaffron : AppColors.primaryNavy, width: 2) 
                          : null,
                    ),
                    child: isCompleted
                        ? const Icon(Icons.check, size: 13, color: Colors.white)
                        : Center(
                            child: Text(
                              '${i + 1}', 
                              textAlign: TextAlign.center, 
                              style: TextStyle(
                                fontSize: 10, 
                                color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                              ),
                            ),
                          ),
                  ),
                  if (i < steps.length - 1) 
                    Expanded(
                      child: Container(
                        height: 2, 
                        color: (i < currentIdx) 
                            ? AppColors.accentGreen 
                            : (isDark ? AppColors.darkBorder : AppColors.borderLight),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                label, 
                textAlign: TextAlign.center, 
                style: TextStyle(
                  fontSize: 8, 
                  fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal, 
                  color: isCompleted 
                      ? (isDark ? AppColors.secondarySaffron : AppColors.primaryNavy) 
                      : (isDark ? AppColors.darkTextMuted : AppColors.textMuted),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  List<Widget> _buildActionCards(BookingModel booking, bool isDark) {
    final status = booking.status.toUpperCase();
    final widgets = <Widget>[];

    // Arrival OTP verification
    if (status == 'ACCEPTED') {
      widgets.add(_actionCard(
        icon: Icons.login_rounded,
        title: 'Step 1: Verify Citizen Arrival OTP',
        subtitle: 'Request the citizen\'s 4-digit Arrival OTP to begin authorized work. Do NOT start any work without OTP.',
        buttonText: '🔐 Enter Arrival OTP',
        buttonColor: isDark ? AppColors.primaryNavy : AppColors.primaryNavy,
        onPressed: () => _showOtpDialog('arrival'),
        isDark: isDark,
      ));
    }

    // In-Progress actions
    if (status == 'IN_PROGRESS') {
      // Photo Proof Upload
      widgets.add(_actionCard(
        icon: Icons.camera_alt,
        title: 'Step 2: Upload Before/After Photo Proof',
        subtitle: 'Capture photographic evidence of the repair. Before photo (pre-repair state) and After photo (completed state).',
        isDark: isDark,
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => setState(() => _beforePhoto = true),
                    icon: Icon(_beforePhoto ? Icons.check_circle : Icons.camera_alt, size: 16),
                    label: Text(_beforePhoto ? 'Before: ✓ Captured' : 'Before Photo'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _beforePhoto 
                          ? AppColors.accentGreen 
                          : (isDark ? AppColors.secondarySaffron : AppColors.primaryNavy),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => setState(() => _afterPhoto = true),
                    icon: Icon(_afterPhoto ? Icons.check_circle : Icons.camera_alt, size: 16),
                    label: Text(_afterPhoto ? 'After: ✓ Captured' : 'After Photo'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _afterPhoto 
                          ? AppColors.accentGreen 
                          : (isDark ? AppColors.secondarySaffron : AppColors.primaryNavy),
                    ),
                  ),
                ),
              ],
            ),
            if (_photoUploaded) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkGreenBg.withValues(alpha: 0.35) : AppColors.greenLight,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle, color: AppColors.accentGreen, size: 16),
                    SizedBox(width: 6),
                    Text(
                      'Photo Proof Verified on Cooperative Ledger',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.accentGreen),
                    ),
                  ],
                ),
              ),
            ] else if (_beforePhoto && _afterPhoto) ...[
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() => _photoUploaded = true);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(backgroundColor: AppColors.accentGreen, content: Text('Photo proof uploaded to cooperative ledger!')),
                  );
                },
                icon: const Icon(Icons.cloud_upload, size: 16),
                label: const Text('Submit Photo Proof to Ledger'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? AppColors.primaryNavy : AppColors.primaryNavy, 
                  minimumSize: const Size.fromHeight(38),
                ),
              ),
            ],
          ],
        ),
      ));

      // Add Spare Parts
      widgets.add(_actionCard(
        icon: Icons.build_circle,
        title: 'Step 3: Add Spare Parts (If Needed)',
        subtitle: 'Select parts from the locked cooperative catalog. Prices are government-controlled ceiling rates — no unauthorized markup.',
        buttonText: '➕ Add Part from Cooperative Catalog',
        buttonColor: AppColors.secondarySaffron,
        onPressed: _showAddPartDialog,
        isDark: isDark,
      ));

      // Complete Work
      widgets.add(_actionCard(
        icon: Icons.verified,
        title: 'Step 4: Mark Work Completed',
        subtitle: 'After the citizen inspects your work, request their 4-digit Completion OTP to finalize the service order. Your 93% direct wage will be credited immediately.',
        buttonText: '✓ Enter Completion OTP & Mark Done',
        buttonColor: AppColors.accentGreen,
        onPressed: () => _showOtpDialog('completion'),
        isDark: isDark,
      ));
    }

    // Completed state
    if (status == 'COMPLETED') {
      widgets.add(Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkGreenBg.withValues(alpha: 0.35) : AppColors.greenLight,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isDark ? AppColors.darkGreenFg.withValues(alpha: 0.4) : AppColors.accentGreen.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            const Icon(Icons.celebration, size: 36, color: AppColors.accentGreen),
            const SizedBox(height: 8),
            const Text('Work Order Successfully Completed!', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.accentGreen)),
            const SizedBox(height: 4),
            Text(
              'Your 93% direct wage has been credited to your bank account.\n2% allocated to Cooperative Welfare Fund. 5% for platform operations.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
            ),
          ],
        ),
      ));
    }

    return widgets;
  }

  Widget _actionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    String? buttonText,
    Color? buttonColor,
    VoidCallback? onPressed,
    Widget? child,
    required bool isDark,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: isDark ? AppColors.darkCard : Colors.white,
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.borderLight),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: isDark ? AppColors.secondarySaffron : AppColors.primaryNavy, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title, 
                    style: TextStyle(
                      fontSize: 13, 
                      fontWeight: FontWeight.bold, 
                      color: isDark ? AppColors.darkTextPrimary : AppColors.primaryNavy,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              subtitle, 
              style: TextStyle(
                fontSize: 11, 
                color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
              ),
            ),
            if (child != null) ...[
              const SizedBox(height: 10),
              child,
            ],
            if (buttonText != null) ...[
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: onPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: buttonColor ?? (isDark ? AppColors.primaryNavy : AppColors.primaryNavy),
                  minimumSize: const Size.fromHeight(40),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Text(buttonText, style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
