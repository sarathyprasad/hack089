import 'package:flutter/material.dart';

/// 🔵 Citizen App — Sky Blue + Slate White + Gold palette
class AppColors {
  // Primary Identity — Sky Blue
  static const Color primary = Color(0xFF0284C7);       // Vivid Sky Blue (Sky 600)
  static const Color primaryDark = Color(0xFF0369A1);   // Deep Sky Blue (Sky 700)
  static const Color primaryLight = Color(0xFF38BDF8);  // Bright Sky Blue (Sky 400)
  static const Color primarySubtle = Color(0xFFE0F2FE); // Soft Ice Sky (Sky 100)
  
  // Accent
  static const Color accent = Color(0xFFF59E0B);         // Warm Amber/Gold
  static const Color accentLight = Color(0xFFFEF3C7);
  static const Color skyAccent = Color(0xFF0EA5E9);      // Sky 500
  
  // Background
  static const Color scaffoldBg = Color(0xFFF8FAFC);     // Clean Slate Light
  static const Color background = scaffoldBg;
  static const Color cardSurface = Colors.white;
  
  // Text
  static const Color textPrimary = Color(0xFF0F172A);    // Slate 900
  static const Color textSecondary = Color(0xFF475569);  // Slate 600
  static const Color textMuted = Color(0xFF94A3B8);      // Slate 400
  
  // Borders
  static const Color borderLight = Color(0xFFE2E8F0);    // Slate 200
  static const Color borderMedium = Color(0xFFCBD5E1);   // Slate 300
  static const Color divider = Color(0xFFF1F5F9);
  
  // Status
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFEA580C);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF0284C7);
  
  // Status Badges
  static const Color successBg = Color(0xFFDCFCE7);
  static const Color warningBg = Color(0xFFFFF7ED);
  static const Color errorBg = Color(0xFFFEE2E2);
  static const Color infoBg = Color(0xFFE0F2FE);
  
  // Booking Status
  static const Color requested = Color(0xFFF59E0B);
  static const Color matched = Color(0xFF0284C7);
  static const Color accepted = Color(0xFF8B5CF6);
  static const Color inProgress = Color(0xFF0EA5E9);
  static const Color completed = Color(0xFF10B981);
  
  // Tariff Split
  static const Color workerWage = Color(0xFF10B981);    // 93%
  static const Color welfareFund = Color(0xFFF59E0B);   // 5%
  static const Color platformFee = Color(0xFF0284C7);   // 2%
}
