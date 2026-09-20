import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../localization/language_provider.dart';

class TariffBreakdownCard extends StatelessWidget {
  final double totalAmount;
  final double? customWorkerWage;
  final double? customWelfare;
  final double? customPlatform;
  final double partsAmount;

  const TariffBreakdownCard({
    super.key,
    required this.totalAmount,
    this.customWorkerWage,
    this.customWelfare,
    this.customPlatform,
    this.partsAmount = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base = totalAmount - partsAmount;
    final workerWage = customWorkerWage ?? (base * 0.93);
    final welfare = customWelfare ?? (base * 0.05);
    final platform = customPlatform ?? (base * 0.02);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.shield_outlined,
                    size: 15,
                    color: isDark ? AppColors.secondarySaffron : AppColors.primaryNavy,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    lang.translate('escrow_model'),
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppColors.primaryNavy,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF064E3B) : AppColors.greenLight,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  lang.translate('zero_surge'),
                  style: TextStyle(
                    fontSize: 8.5,
                    fontWeight: FontWeight.w800,
                    color: isDark ? const Color(0xFF34D399) : AppColors.accentGreen,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Colored visual segmented bar
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: SizedBox(
              height: 6,
              child: Row(
                children: [
                  Expanded(
                    flex: 93,
                    child: Container(color: isDark ? const Color(0xFF38BDF8) : AppColors.primaryNavy),
                  ),
                  const SizedBox(width: 1.5),
                  Expanded(flex: 5, child: Container(color: AppColors.accentGreen)),
                  const SizedBox(width: 1.5),
                  Expanded(flex: 2, child: Container(color: AppColors.secondarySaffron)),
                ],
              ),
            ),
          ),

          const SizedBox(height: 10),

          // 3-Column Clean Micro-Metrics
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _metricColumn('₹${workerWage.toStringAsFixed(0)}', lang.translate('worker_take_home'), isDark ? Colors.white : AppColors.primaryNavy, isDark),
              Container(height: 22, width: 1, color: isDark ? AppColors.darkBorder : AppColors.borderLight),
              _metricColumn('₹${welfare.toStringAsFixed(0)}', lang.translate('welfare_fund'), isDark ? const Color(0xFF34D399) : AppColors.accentGreen, isDark),
              Container(height: 22, width: 1, color: isDark ? AppColors.darkBorder : AppColors.borderLight),
              _metricColumn('₹${platform.toStringAsFixed(0)}', lang.translate('platform_fee'), isDark ? AppColors.secondarySaffron : Colors.amber.shade800, isDark),
            ],
          ),
        ],
      ),
    );
  }

  static Widget _metricColumn(String amount, String label, Color color, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(amount, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color)),
        const SizedBox(height: 1),
        Text(
          label,
          style: TextStyle(
            fontSize: 9.5,
            color: isDark ? const Color(0xFF94A3B8) : AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
