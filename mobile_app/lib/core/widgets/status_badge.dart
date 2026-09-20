import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  final bool isEmergency;

  const StatusBadge({
    super.key,
    required this.status,
    this.isEmergency = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (isEmergency) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.emergencyRed,
          borderRadius: BorderRadius.circular(6),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.bolt, color: Colors.white, size: 12),
            SizedBox(width: 4),
            Text(
              '24/7 EMERGENCY',
              style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
    }

    Color bg;
    Color fg;
    String label = status.toUpperCase();

    switch (status.toUpperCase()) {
      case 'REQUESTED':
        bg = isDark ? AppColors.darkBlueBg : const Color(0xFFEFF6FF);
        fg = isDark ? AppColors.darkBlueFg : const Color(0xFF1D4ED8);
        label = 'REQUESTED';
        break;
      case 'MATCHED':
        bg = isDark ? AppColors.darkPurpleBg : const Color(0xFFF5F3FF);
        fg = isDark ? AppColors.darkPurpleFg : const Color(0xFF6D28D9);
        label = 'MATCHED';
        break;
      case 'ACCEPTED':
        bg = isDark ? AppColors.darkAmberBg : const Color(0xFFFEF3C7);
        fg = isDark ? AppColors.darkAmberFg : const Color(0xFFB45309);
        label = 'ACCEPTED';
        break;
      case 'IN_PROGRESS':
        bg = isDark ? AppColors.darkBlueBg : const Color(0xFFE0E7FF);
        fg = isDark ? AppColors.darkBlueFg : const Color(0xFF3730A3);
        label = 'IN PROGRESS';
        break;
      case 'COMPLETED':
        bg = isDark ? AppColors.darkGreenBg : AppColors.greenLight;
        fg = isDark ? AppColors.darkGreenFg : AppColors.accentGreen;
        label = 'COMPLETED';
        break;
      case 'CANCELLED':
        bg = isDark ? AppColors.darkRedBg : AppColors.redLight;
        fg = isDark ? AppColors.darkRedFg : AppColors.emergencyRed;
        label = 'CANCELLED';
        break;
      case 'VERIFIED':
        bg = isDark ? AppColors.darkGreenBg : AppColors.greenLight;
        fg = isDark ? AppColors.darkGreenFg : AppColors.accentGreen;
        label = '✓ VERIFIED';
        break;
      case 'PENDING':
        bg = isDark ? AppColors.darkAmberBg : AppColors.amberLight;
        fg = isDark ? AppColors.darkAmberFg : AppColors.warningAmber;
        label = '⏳ PENDING';
        break;
      case 'REJECTED':
        bg = isDark ? AppColors.darkRedBg : AppColors.redLight;
        fg = isDark ? AppColors.darkRedFg : AppColors.emergencyRed;
        label = '✕ REJECTED';
        break;
      case 'BROADCAST':
        bg = isDark ? AppColors.darkAmberBg : const Color(0xFFFEF3C7);
        fg = isDark ? AppColors.darkAmberFg : AppColors.secondarySaffron;
        label = '📡 BROADCAST';
        break;
      default:
        bg = isDark ? AppColors.darkCardAlt : const Color(0xFFF1F5F9);
        fg = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: fg.withValues(alpha: isDark ? 0.4 : 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(color: fg, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.3),
      ),
    );
  }
}
