import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/gov_app_bar.dart';
import '../../core/widgets/gov_loading_indicator.dart';
import '../../core/widgets/tariff_breakdown_card.dart';
import '../../providers/service_provider.dart';

class ServiceDetailScreen extends StatefulWidget {
  final int serviceId;
  const ServiceDetailScreen({super.key, required this.serviceId});

  @override
  State<ServiceDetailScreen> createState() => _ServiceDetailScreenState();
}

class _ServiceDetailScreenState extends State<ServiceDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ServiceProvider>().fetchServiceById(widget.serviceId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final serviceProv = context.watch<ServiceProvider>();
    final service = serviceProv.selectedService;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.backgroundLight,
      appBar: GovAppBar(title: service?.name ?? 'Service Details'),
      bottomNavigationBar: service != null
          ? Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : Colors.white,
                border: Border(top: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.borderLight)),
              ),
              child: Row(
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Standard Base Tariff', style: TextStyle(fontSize: 10, color: isDark ? AppColors.darkTextMuted : AppColors.textMuted)),
                      Text(
                        '₹${service.basePrice.toStringAsFixed(0)}',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isDark ? AppColors.darkGreenFg : AppColors.accentGreen),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => context.go('/book-service?serviceId=${service.id}'),
                      icon: const Icon(Icons.calendar_month, size: 18),
                      label: const Text('Book This Service'),
                    ),
                  ),
                ],
              ),
            )
          : null,
      body: serviceProv.isLoading
          ? const GovLoadingIndicator.fullScreen(
              title: 'Loading Regulated Trade Details...',
              subtitle: 'Fetching statutory scope of work and certified warranty terms',
            )
          : service == null
              ? Center(child: Text('Service not found', style: TextStyle(color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary)))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkBlueBg : AppColors.primaryNavy.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          service.category.toUpperCase(),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppColors.darkBlueFg : AppColors.primaryNavy,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        service.name,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : AppColors.primaryNavy,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        service.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Service Meta Badges
                      Row(
                        children: [
                          _infoChip(Icons.schedule, '${service.durationMinutes} Minutes', isDark),
                          const SizedBox(width: 8),
                          _infoChip(Icons.verified_user_outlined, '30-Day Workmanship Guarantee', isDark),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Statutory 93-2-5 Escrow Breakdown
                      TariffBreakdownCard(totalAmount: service.basePrice),

                      const SizedBox(height: 20),

                      // Standard Operating Inclusions Checklist
                      Card(
                        color: isDark ? AppColors.darkCard : Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.borderLight),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.checklist_rtl, color: isDark ? AppColors.secondarySaffron : AppColors.primaryNavy, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Standard Operating Checklist (SOP)',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: isDark ? Colors.white : AppColors.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              if (service.checklist.isNotEmpty)
                                ...service.checklist.map((item) => Padding(
                                      padding: const EdgeInsets.only(bottom: 8),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Icon(Icons.check_circle, size: 16, color: isDark ? AppColors.darkGreenFg : AppColors.accentGreen),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              item,
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ))
                              else ...[
                                _checkItem('Complete safety diagnostic and pre-check', isDark),
                                _checkItem('Repairs performed using insulated ISI-certified tools', isDark),
                                _checkItem('Customer inspection & 4-digit completion handshake', isDark),
                              ],
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
    );
  }

  Widget _infoChip(IconData icon, String text, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCardAlt : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(6),
        border: isDark ? Border.all(color: AppColors.darkBorder) : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: isDark ? AppColors.secondarySaffron : AppColors.primaryNavy),
          const SizedBox(width: 4),
          Text(text, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary)),
        ],
      ),
    );
  }

  Widget _checkItem(String text, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle, size: 16, color: isDark ? AppColors.darkGreenFg : AppColors.accentGreen),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: TextStyle(fontSize: 13, color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary))),
        ],
      ),
    );
  }
}
