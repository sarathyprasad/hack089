import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants/app_colors.dart';

class SafetyChecklistSheet extends StatefulWidget {
  final int bookingId;
  final VoidCallback? onVerified;

  const SafetyChecklistSheet({
    super.key,
    required this.bookingId,
    this.onVerified,
  });

  @override
  State<SafetyChecklistSheet> createState() => _SafetyChecklistSheetState();
}

class _SafetyChecklistSheetState extends State<SafetyChecklistSheet> {
  final Map<String, bool> _checks = {
    '1000V Insulated Pliers & Screwdrivers': true,
    'Non-conductive ISI Certified Rubber Safety Shoes': true,
    'Digital Multimeter & Live Phase Neon Tester': true,
    'Official Cooperative Artisan Photo ID Badge Worn': true,
    'Protective Eye Goggles / Heavy Work Gloves': false,
    'Main Circuit Breaker (MCB) Lockout Protocol Followed': false,
  };

  bool _isSubmitting = false;

  bool get _allChecked => _checks.values.every((v) => v);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.health_and_safety, color: AppColors.warning, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'PRE-SERVICE SAFETY COMPLIANCE',
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.8,
                          color: AppColors.warning,
                        ),
                      ),
                      Text(
                        'Job #${widget.bookingId} • Mandatory Hazard Audit',
                        style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.textSecondary),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.cardSurfaceAlt,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.borderDark),
              ),
              child: Row(
                children: [
                  const Icon(Icons.verified_user, color: AppColors.accent, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Completing this checklist activates ₹5,00,000 active job accidental cover under the Odisha Prithvi Welfare Nidhi.',
                      style: GoogleFonts.inter(fontSize: 11, color: AppColors.textPrimary),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            Text(
              'EQUIPMENT & PROTOCOL VERIFICATION',
              style: GoogleFonts.outfit(
                fontSize: 10.5,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.8,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),

            ..._checks.keys.map((key) {
              final isChecked = _checks[key] ?? false;
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: isChecked ? AppColors.scaffoldBg : AppColors.cardSurfaceAlt,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isChecked ? AppColors.accent : AppColors.borderDark,
                  ),
                ),
                child: CheckboxListTile(
                  dense: true,
                  value: isChecked,
                  activeColor: AppColors.accent,
                  checkColor: Colors.black,
                  title: Text(
                    key,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: isChecked ? FontWeight.w600 : FontWeight.normal,
                      color: isChecked ? Colors.white : AppColors.textSecondary,
                    ),
                  ),
                  onChanged: (val) {
                    setState(() => _checks[key] = val ?? false);
                  },
                ),
              );
            }),

            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _allChecked && !_isSubmitting
                    ? () {
                        setState(() => _isSubmitting = true);
                        Navigator.pop(context);
                        widget.onVerified?.call();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            backgroundColor: AppColors.success,
                            content: Text('Safety compliance verified! ₹5L Prithvi Insurance Active.'),
                          ),
                        );
                      }
                    : null,
                icon: const Icon(Icons.shield, size: 18),
                label: Text(
                  _allChecked ? 'CONFIRM SAFETY & BEGIN DIAGNOSTICS' : 'CHECK ALL SAFETY ITEMS TO PROCEED',
                  style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.available,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
