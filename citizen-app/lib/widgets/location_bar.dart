import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../core/localization/app_localizations.dart';
import '../providers/location_provider.dart';
import 'location_selection_sheet.dart';

class LocationBar extends StatelessWidget {
  final bool compact;
  final EdgeInsetsGeometry? margin;

  const LocationBar({
    super.key,
    this.compact = false,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final locationProvider = context.watch<LocationProvider>();
    final loc = locationProvider.selectedLocation;
    final isGps = locationProvider.isUsingGps;

    return Container(
      margin: margin ?? const EdgeInsets.fromLTRB(16, 12, 16, 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isGps ? const Color(0xFF86EFAC) : const Color(0xFFE2E8F0),
          width: isGps ? 1.4 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: isGps
                ? const Color(0xFF10B981).withValues(alpha: 0.08)
                : Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () => LocationSelectionSheet.show(context),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 14,
              vertical: compact ? 10 : 12,
            ),
            child: Row(
              children: [
                // Location Icon with subtle gradient
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isGps
                          ? [const Color(0xFF10B981), const Color(0xFF059669)]
                          : [const Color(0xFF0284C7), const Color(0xFF0369A1)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: (isGps ? const Color(0xFF10B981) : const Color(0xFF0284C7))
                            .withValues(alpha: 0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    isGps ? Icons.gps_fixed_rounded : Icons.location_on_rounded,
                    color: Colors.white,
                    size: compact ? 16 : 18,
                  ),
                ),
                const SizedBox(width: 12),

                // Text Information
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              loc.name,
                              style: GoogleFonts.outfit(
                                fontSize: compact ? 13.5 : 14.5,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            size: 18,
                            color: AppColors.primary,
                          ),
                          if (isGps) ...[
                            const SizedBox(width: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                              decoration: BoxDecoration(
                                color: const Color(0xFFDCFCE7),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'GPS',
                                style: GoogleFonts.inter(
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF15803D),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${loc.city} (${loc.pincode}) • ${loc.artisanCount}+ ${context.tr('artisansNearby', 'artisans nearby')}',
                        style: GoogleFonts.inter(
                          fontSize: compact ? 10.5 : 11.5,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // Change Action Chip
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.2),
                      width: 0.8,
                    ),
                  ),
                  child: Text(
                    context.tr('change', 'Change'),
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
