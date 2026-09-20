import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/network/api_client.dart';
import '../../core/constants/api_endpoints.dart';

/// Shows a 30-day warranty claim and dispute filing bottom sheet.
/// Used from the Customer Booking Detail screen for completed orders.
void showDisputeDialog({
  required BuildContext context,
  required int bookingId,
  required String serviceName,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => _DisputeBottomSheet(
      bookingId: bookingId,
      serviceName: serviceName,
    ),
  );
}

class _DisputeBottomSheet extends StatefulWidget {
  final int bookingId;
  final String serviceName;

  const _DisputeBottomSheet({
    required this.bookingId,
    required this.serviceName,
  });

  @override
  State<_DisputeBottomSheet> createState() => _DisputeBottomSheetState();
}

class _DisputeBottomSheetState extends State<_DisputeBottomSheet> {
  String _disputeType = 'warranty';
  final _descCtrl = TextEditingController();
  bool _isSubmitting = false;
  bool _submitted = false;

  @override
  void dispose() {
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _submitDispute() async {
    if (_descCtrl.text.trim().isEmpty) return;

    setState(() => _isSubmitting = true);

    try {
      await ApiClient().post(
        ApiEndpoints.disputes,
        data: {
          'booking_id': widget.bookingId,
          'type': _disputeType,
          'description': _descCtrl.text.trim(),
        },
      );
      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _submitted = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.emergencyRed,
            content: Text('Failed to file dispute: $e'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBackground : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: SingleChildScrollView(
        child: _submitted ? _buildSuccessView(isDark) : _buildFormView(isDark),
      ),
    );
  }

  Widget _buildSuccessView(bool isDark) {
    return Column(
      children: [
        const SizedBox(height: 20),
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkGreenBg : AppColors.greenLight,
            shape: BoxShape.circle,
            border: Border.all(color: isDark ? AppColors.darkGreenFg : AppColors.accentGreen, width: 2),
          ),
          child: Icon(Icons.check, size: 36, color: isDark ? AppColors.darkGreenFg : AppColors.accentGreen),
        ),
        const SizedBox(height: 16),
        Text(
          'Dispute Filed Successfully',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.primaryNavy),
        ),
        const SizedBox(height: 8),
        Text(
          'Your grievance has been registered with the District Federation Cooperative Grievance Redressal Cell. You will receive updates within 48 working hours.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12, color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
        ),
        const SizedBox(height: 20),
        _InfoRow('Tracking Reference', 'GR-2026-XXXX', isDark),
        _InfoRow('Escalation Authority', 'Dist. Federation Cooperative Secretary', isDark),
        _InfoRow('Response SLA', '48 Working Hours', isDark),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: isDark ? AppColors.secondarySaffron : AppColors.primaryNavy,
            foregroundColor: isDark ? Colors.black : Colors.white,
            minimumSize: const Size.fromHeight(42),
          ),
          child: const Text('Close'),
        ),
      ],
    );
  }

  Widget _buildFormView(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '30-Day Warranty & Dispute Centre',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.primaryNavy),
            ),
            IconButton(
              icon: Icon(Icons.close, color: isDark ? Colors.white : null),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
        Divider(color: isDark ? AppColors.darkBorder : null),
        // Guarantee banner
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkGreenBg : AppColors.greenLight,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: isDark ? AppColors.darkGreenFg.withValues(alpha: 0.3) : AppColors.accentGreen.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Icon(Icons.shield, color: isDark ? AppColors.darkGreenFg : AppColors.accentGreen),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Cooperative 30-Day Quality Guarantee\nAll services are backed by a 30-day cooperative statutory workmanship guarantee at zero additional cost to the citizen.',
                  style: TextStyle(fontSize: 11, color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Booking reference
        Text(
          'Booking #${widget.bookingId} — ${widget.serviceName}',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.textPrimary),
        ),
        const SizedBox(height: 14),

        // Dispute Type
        Text('Dispute Category', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isDark ? AppColors.secondarySaffron : AppColors.primaryNavy)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: _disputeType,
          dropdownColor: isDark ? AppColors.darkCard : Colors.white,
          style: TextStyle(fontSize: 13, color: isDark ? Colors.white : AppColors.textPrimary),
          items: [
            DropdownMenuItem(value: 'warranty', child: Text('🔧 30-Day Warranty Defect Claim', style: TextStyle(color: isDark ? Colors.white : AppColors.textPrimary))),
            DropdownMenuItem(value: 'quality', child: Text('📋 Service Quality Complaint', style: TextStyle(color: isDark ? Colors.white : AppColors.textPrimary))),
            DropdownMenuItem(value: 'overcharge', child: Text('💰 Tariff / Overcharging Dispute', style: TextStyle(color: isDark ? Colors.white : AppColors.textPrimary))),
            DropdownMenuItem(value: 'safety', child: Text('⚠️ Safety / Property Damage', style: TextStyle(color: isDark ? Colors.white : AppColors.textPrimary))),
            DropdownMenuItem(value: 'conduct', child: Text('👤 Worker Conduct Grievance', style: TextStyle(color: isDark ? Colors.white : AppColors.textPrimary))),
          ],
          onChanged: (val) {
            if (val != null) setState(() => _disputeType = val);
          },
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.borderLight)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.borderLight)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: isDark ? AppColors.secondarySaffron : AppColors.primaryNavy, width: 2)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            filled: isDark,
            fillColor: isDark ? AppColors.darkCard : null,
          ),
        ),
        const SizedBox(height: 14),

        // Description
        Text('Describe Your Issue', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isDark ? AppColors.secondarySaffron : AppColors.primaryNavy)),
        const SizedBox(height: 8),
        TextField(
          controller: _descCtrl,
          maxLines: 5,
          style: TextStyle(color: isDark ? Colors.white : AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: 'Please describe the issue in detail. Include specific dates, defects observed, and any relevant information...',
            hintStyle: TextStyle(fontSize: 12, color: isDark ? AppColors.darkTextMuted : null),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.borderLight)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.borderLight)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: isDark ? AppColors.secondarySaffron : AppColors.primaryNavy, width: 2)),
            filled: isDark,
            fillColor: isDark ? AppColors.darkCard : null,
          ),
        ),
        const SizedBox(height: 16),

        // Photo attachment (simulated)
        OutlinedButton.icon(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Camera/gallery picker for evidence photo')),
            );
          },
          icon: const Icon(Icons.attach_file, size: 16),
          label: const Text('Attach Evidence Photo (Optional)'),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(38),
            foregroundColor: isDark ? AppColors.secondarySaffron : AppColors.primaryNavy,
            side: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.borderLight),
          ),
        ),
        const SizedBox(height: 16),

        // Submit
        ElevatedButton.icon(
          onPressed: _isSubmitting ? null : _submitDispute,
          icon: _isSubmitting
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Icon(Icons.gavel, size: 18),
          label: Text(_isSubmitting ? 'Filing Grievance...' : 'File Statutory Grievance'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.emergencyRed,
            minimumSize: const Size.fromHeight(44),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        const SizedBox(height: 10),
        Center(
          child: Text(
            'Grievances are heard by the District Federation Cooperative Grievance Redressal Cell under Odisha Cooperative Societies Act.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 10, color: isDark ? AppColors.darkTextMuted : AppColors.textMuted),
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isDark;
  const _InfoRow(this.label, this.value, this.isDark);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 12, color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary)),
          Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isDark ? AppColors.secondarySaffron : AppColors.primaryNavy)),
        ],
      ),
    );
  }
}
