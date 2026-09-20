import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/gov_app_bar.dart';
import '../../core/widgets/gov_loading_indicator.dart';
import '../../providers/service_provider.dart';
import '../../providers/location_provider.dart';

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ServiceProvider>().fetchServices();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final serviceProv = context.watch<ServiceProvider>();
    final locProv = context.watch<LocationProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final unsupp = locProv.unsupportedLocation;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (context.canPop()) {
          context.pop();
        } else {
          context.go('/');
        }
      },
      child: Scaffold(
        backgroundColor: isDark ? AppColors.darkBackground : AppColors.backgroundLight,
        appBar: const GovAppBar(title: 'Services Catalog'),
        body: Column(
          children: [
            // Out-of-Coverage / Berhampur Notice Banner
            if (unsupp != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                color: isDark ? AppColors.darkAmberBg : AppColors.amber50,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.access_time_filled_rounded, color: AppColors.amber600, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '📍 Services Coming Soon to ${unsupp.name} (${unsupp.district})',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: AppColors.amber700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Our cooperative network is currently active across Khordha, Cuttack, and Puri (~${unsupp.distanceKm} km away). Showing standard regulated rates from the Bhubaneswar cooperative hub.',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? AppColors.slate300 : AppColors.slate700,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: () => locProv.changeLocation(1),
                      icon: const Icon(Icons.arrow_forward_rounded, size: 14),
                      label: const Text('Browse Active Bhubaneswar Hub'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryNavy,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      ),
                    ),
                  ],
                ),
              ),

            // Search & Filter Header
            Container(
              color: isDark ? AppColors.darkCard : Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                children: [
                  TextField(
                    controller: _searchController,
                    style: TextStyle(color: isDark ? Colors.white : AppColors.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Search service (e.g. Fan, Tap, Switchboard)...',
                      hintStyle: TextStyle(color: isDark ? AppColors.darkTextMuted : AppColors.textMuted),
                      prefixIcon: Icon(Icons.search, color: isDark ? AppColors.secondarySaffron : AppColors.primaryNavy),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: Icon(Icons.clear, color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
                              onPressed: () {
                                _searchController.clear();
                                serviceProv.search('');
                              },
                            )
                          : null,
                      contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                      filled: true,
                      fillColor: isDark ? AppColors.darkBackground : Colors.white,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.borderLight),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: isDark ? AppColors.secondarySaffron : AppColors.primaryNavy, width: 2),
                      ),
                    ),
                    onChanged: (val) => serviceProv.search(val),
                  ),
                  const SizedBox(height: 10),
                  // Category Chips Carousel
                  SizedBox(
                    height: 36,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: serviceProv.categories.length,
                      itemBuilder: (context, index) {
                        final cat = serviceProv.categories[index];
                        final isSelected = cat.toUpperCase() == serviceProv.selectedCategory.toUpperCase();
                        return Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: ChoiceChip(
                            label: Text(cat, style: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              color: isSelected ? Colors.white : (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
                            )),
                            selected: isSelected,
                            onSelected: (_) => serviceProv.selectCategory(cat),
                            selectedColor: isDark ? AppColors.secondarySaffron : AppColors.primaryNavy,
                            backgroundColor: isDark ? AppColors.darkCardAlt : null,
                            side: isSelected ? null : BorderSide(color: isDark ? AppColors.darkBorder : AppColors.borderLight),
                            labelStyle: TextStyle(color: isSelected ? (isDark ? Colors.black : Colors.white) : (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary)),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Services List
            Expanded(
              child: serviceProv.isLoading
                  ? const GovLoadingIndicator.card(
                      title: 'Loading Regulated Services...',
                      subtitle: 'Fetching statutory rates & transparent tariffs',
                    )
                  : serviceProv.services.isEmpty
                      ? Center(
                          child: Text(
                            'No services found matching your criteria.',
                            style: TextStyle(color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: serviceProv.services.length,
                          itemBuilder: (context, index) {
                            final service = serviceProv.services[index];
                            final adjustedPrice = locProv.calculateAreaPrice(service.basePrice);

                            return Card(
                              color: isDark ? AppColors.darkCard : Colors.white,
                              margin: const EdgeInsets.only(bottom: 12),
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
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: isDark ? AppColors.darkCardAlt : const Color(0xFFF1F5F9),
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                                child: Text(
                                                  service.category.toUpperCase(),
                                                  style: TextStyle(
                                                    fontSize: 9,
                                                    fontWeight: FontWeight.bold,
                                                    color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                service.name,
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                  color: isDark ? Colors.white : AppColors.primaryNavy,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              '₹$adjustedPrice',
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w900,
                                                color: isDark ? AppColors.darkGreenFg : AppColors.accentGreen,
                                              ),
                                            ),
                                            Text(
                                              locProv.multiplier != 1.0
                                                  ? '${locProv.selectedLocation.shortName} (${locProv.selectedLocation.label.split('(').last.replaceAll(')', '')})'
                                                  : 'Base Tariff',
                                              style: TextStyle(fontSize: 10, color: isDark ? AppColors.darkTextMuted : AppColors.textMuted),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      service.description,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        Icon(Icons.schedule, size: 14, color: isDark ? AppColors.darkTextMuted : AppColors.textMuted),
                                        const SizedBox(width: 4),
                                        Text('${service.durationMinutes} mins', style: TextStyle(fontSize: 11, color: isDark ? AppColors.darkTextMuted : AppColors.textMuted)),
                                        const SizedBox(width: 12),
                                        Icon(Icons.people_outline, size: 14, color: isDark ? AppColors.darkTextMuted : AppColors.textMuted),
                                        const SizedBox(width: 4),
                                        Text('${service.activeWorkersCount} on-duty artisans', style: TextStyle(fontSize: 11, color: isDark ? AppColors.darkTextMuted : AppColors.textMuted)),
                                        const Spacer(),
                                        OutlinedButton(
                                          onPressed: () => context.push('/services/${service.id}'),
                                          style: OutlinedButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                            minimumSize: Size.zero,
                                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                            foregroundColor: isDark ? AppColors.secondarySaffron : AppColors.primaryNavy,
                                            side: BorderSide(color: isDark ? AppColors.secondarySaffron.withValues(alpha: 0.5) : AppColors.primaryNavy),
                                          ),
                                          child: const Text('View & Book', style: TextStyle(fontSize: 12)),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
