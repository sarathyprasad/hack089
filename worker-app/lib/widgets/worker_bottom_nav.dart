import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants/app_colors.dart';
import '../core/localization/app_localizations.dart';

class WorkerBottomNavBar extends StatelessWidget {
  final int currentIndex;
  const WorkerBottomNavBar({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final items = [
      {
        'route': '/dashboard',
        'icon': Icons.dashboard_rounded,
        'label': context.tr('dashboardBtn', 'Dashboard'),
      },
      {
        'route': '/earnings',
        'icon': Icons.account_balance_wallet_rounded,
        'label': context.tr('earningsOverview', 'Earnings'),
      },
      {
        'route': '/welfare',
        'icon': Icons.health_and_safety_rounded,
        'label': context.tr('welfare', 'Welfare Shield'),
      },
      {
        'route': '/profile',
        'icon': Icons.person_rounded,
        'label': context.tr('profile', 'Profile'),
      },
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        border: Border(
          top: BorderSide(
            color: AppColors.border(context),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (index) {
              final isSelected = currentIndex == index;
              final item = items[index];

              return Expanded(
                child: InkWell(
                  onTap: () {
                    if (!isSelected) {
                      context.go(item['route'] as String);
                    }
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? (isDark
                              ? AppColors.accent.withValues(alpha: 0.15)
                              : AppColors.primary.withValues(alpha: 0.10))
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(14),
                      border: isSelected
                          ? Border.all(
                              color: isDark
                                  ? AppColors.accent.withValues(alpha: 0.35)
                                  : AppColors.primary.withValues(alpha: 0.25),
                              width: 1,
                            )
                          : Border.all(color: Colors.transparent),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          item['icon'] as IconData,
                          size: 21,
                          color: isSelected
                              ? (isDark ? AppColors.accentLight : AppColors.primary)
                              : AppColors.muted(context),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item['label'] as String,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontSize: 10.5,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            color: isSelected
                                ? (isDark ? AppColors.accentLight : AppColors.primary)
                                : AppColors.muted(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
