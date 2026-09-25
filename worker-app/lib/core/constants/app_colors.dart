import 'package:flutter/material.dart';

/// 🟢 Worker App — High-Performance Dark Slate + Light Slate + Artisan Green + Emerald
class AppColors {
  // Primary Identity — Green (consistent across light & dark)
  static const Color primary = Color(0xFF16A34A);        // Artisan Green
  static const Color primaryDark = Color(0xFF15803D);
  static const Color primaryLight = Color(0xFF4ADE80);

  // Accent
  static const Color accent = Color(0xFF22C55E);          // Vivid Emerald Green
  static const Color accentLight = Color(0xFF86EFAC);

  // Dark Palette
  static const Color darkScaffoldBg = Color(0xFF0F172A);       // Deep Slate
  static const Color darkCardSurface = Color(0xFF1E293B);
  static const Color darkCardSurfaceAlt = Color(0xFF334155);
  static const Color darkTextPrimary = Color(0xFFF1F5F9);
  static const Color darkTextSecondary = Color(0xFF94A3B8);
  static const Color darkTextMuted = Color(0xFF64748B);
  static const Color darkBorder = Color(0xFF334155);

  // Light Palette
  static const Color lightScaffoldBg = Color(0xFFF8FAFC);      // Crisp Slate 50
  static const Color lightCardSurface = Color(0xFFFFFFFF);     // Pure White
  static const Color lightCardSurfaceAlt = Color(0xFFF1F5F9);  // Slate 100
  static const Color lightTextPrimary = Color(0xFF0F172A);     // Deep Slate 900
  static const Color lightTextSecondary = Color(0xFF475569);   // Slate 600
  static const Color lightTextMuted = Color(0xFF94A3B8);       // Slate 400
  static const Color lightBorder = Color(0xFFE2E8F0);          // Slate 200

  // Default Fallbacks (for backwards compatibility)
  static const Color scaffoldBg = darkScaffoldBg;
  static const Color cardSurface = darkCardSurface;
  static const Color cardSurfaceAlt = darkCardSurfaceAlt;
  static const Color textPrimary = darkTextPrimary;
  static const Color textSecondary = darkTextSecondary;
  static const Color textMuted = darkTextMuted;
  static const Color borderDark = darkBorder;
  static const Color divider = Color(0xFF1E293B);

  // Dynamic Context-Aware Helper Getters
  static Color bg(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkScaffoldBg : lightScaffoldBg;
  static Color surface(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkCardSurface : lightCardSurface;
  static Color surfaceAlt(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkCardSurfaceAlt : lightCardSurfaceAlt;
  static Color text(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkTextPrimary : lightTextPrimary;
  static Color textSec(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkTextSecondary : lightTextSecondary;
  static Color muted(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkTextMuted : lightTextMuted;
  static Color border(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkBorder : lightBorder;

  // Status
  static const Color success = Color(0xFF22C55E);
  static const Color available = Color(0xFF22C55E);
  static const Color busy = Color(0xFFF59E0B);
  static const Color offline = Color(0xFF64748B);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF38BDF8);

  // Status Badge BGs
  static const Color successBg = Color(0xFF064E3B);
  static const Color warningBg = Color(0xFF451A03);
  static const Color errorBg = Color(0xFF450A0A);
  static const Color infoBg = Color(0xFF064E3B);

  // Status Badge BGs (Light Mode)
  static const Color lightSuccessBg = Color(0xFFDCFCE7);
  static const Color lightWarningBg = Color(0xFFFEF3C7);
  static const Color lightErrorBg = Color(0xFFFEE2E2);
  static const Color lightInfoBg = Color(0xFFE0F2FE);

  // Earnings
  static const Color workerWage = Color(0xFF22C55E);
  static const Color welfareFund = Color(0xFFF59E0B);
  static const Color platformFee = Color(0xFF16A34A);
}
