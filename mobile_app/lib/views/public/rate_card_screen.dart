import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/gov_app_bar.dart';
import '../../core/widgets/tariff_breakdown_card.dart';
import '../../core/widgets/location_selection_modal.dart';
import '../../core/localization/language_provider.dart';
import '../../providers/service_provider.dart';
import '../../providers/location_provider.dart';

class RateCardScreen extends StatefulWidget {
  const RateCardScreen({super.key});

  @override
  State<RateCardScreen> createState() => _RateCardScreenState();
}

class _RateCardScreenState extends State<RateCardScreen> {
  double _customAmount = 249.0;
  String _selectedTradeFilter = 'ALL';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ServiceProvider>().fetchServices();
    });
  }

  @override
  Widget build(BuildContext context) {
    final serviceProv = context.watch<ServiceProvider>();
    final locProv = context.watch<LocationProvider>();
    final lang = context.watch<LanguageProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final unsupp = locProv.unsupportedLocation;

    final List<Map<String, dynamic>> spareParts = [
      {'part': 'Ceiling Fan Capacitor (2.5 mfd)', 'trade': 'Electrical', 'ceiling': 120.0},
      {'part': '16A Modular Switch & Socket', 'trade': 'Electrical', 'ceiling': 180.0},
      {'part': 'Brass Bib Tap 1/2 Inch', 'trade': 'Plumbing', 'ceiling': 290.0},
      {'part': 'PVC Waste Pipe & Washer Set', 'trade': 'Plumbing', 'ceiling': 95.0},
      {'part': 'Heavy SS Butt Hinges (Pair)', 'trade': 'Carpentry', 'ceiling': 160.0},
      {'part': 'Acrylic Distemper Primer (1 Ltr)', 'trade': 'Painting', 'ceiling': 210.0},
      {'part': 'R-32 Refrigerant Gas Refill (Per 100g)', 'trade': 'Appliance', 'ceiling': 350.0},
    ];

    final filteredServices = serviceProv.services.where((s) {
      if (_selectedTradeFilter == 'ALL') return true;
      return s.category.toUpperCase().contains(_selectedTradeFilter.toUpperCase());
    }).toList();

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
        appBar: GovAppBar(title: lang.translate('rate_card')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Location Calibration Banner
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: unsupp != null
                      ? (isDark ? AppColors.darkAmberBg : AppColors.amber50)
                      : (isDark ? AppColors.darkCard : Colors.white),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: unsupp != null
                        ? (isDark ? AppColors.darkAmberFg.withValues(alpha: 0.4) : AppColors.amber200)
                        : (isDark ? AppColors.darkBorder : AppColors.slate200),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.location_on_rounded,
                      color: unsupp != null ? AppColors.amber600 : AppColors.primaryNavy,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            unsupp != null
                                ? '📍 ${unsupp.name} (${unsupp.district}) • Coming Soon'
                                : '📍 Tariffs Calibrated for: ${locProv.selectedLocation.shortName}',
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.bold,
                              color: unsupp != null
                                  ? AppColors.amber700
                                  : (isDark ? Colors.white : AppColors.slate900),
                            ),
                          ),
                          Text(
                            unsupp != null
                                ? 'Showing standard Bhubaneswar benchmark rates'
                                : '${locProv.selectedLocation.label} • Active Hub',
                            style: TextStyle(
                              fontSize: 10.5,
                              color: isDark ? AppColors.slate400 : AppColors.slate500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () => LocationSelectionModal.show(context),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text('Change Hub', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // 2. Government Regulation Notice
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkInfoBg : AppColors.infoLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark
                        ? AppColors.darkInfoFg.withValues(alpha: 0.3)
                        : AppColors.infoBlue.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.gavel_rounded, color: isDark ? AppColors.darkInfoFg : AppColors.infoBlue, size: 26),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Statutory Standardized Tariffs',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: isDark ? AppColors.darkInfoFg : AppColors.infoBlue,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Published under the Odisha Cooperative Societies Act tariff schedule. Zero surge pricing at all times.',
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // 3. Interactive Escrow Split Calculator
              Text(
                'Interactive 93-2-5 Price Engine',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : AppColors.slate900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Slide budget to inspect exact statutory wage breakdown with zero middleman deductions.',
                style: TextStyle(fontSize: 11, color: isDark ? AppColors.slate400 : AppColors.slate600),
              ),
              const SizedBox(height: 10),

              Card(
                color: isDark ? AppColors.darkCard : Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.slate200),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Estimated Service Budget:',
                            style: TextStyle(fontSize: 13, color: isDark ? AppColors.darkTextSecondary : AppColors.slate700),
                          ),
                          Text(
                            '₹${_customAmount.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: isDark ? AppColors.secondarySaffron : AppColors.primaryNavy,
                            ),
                          ),
                        ],
                      ),
                      Slider(
                        value: _customAmount,
                        min: 100,
                        max: 2000,
                        divisions: 38,
                        label: '₹${_customAmount.toStringAsFixed(0)}',
                        activeColor: isDark ? AppColors.secondarySaffron : AppColors.primaryNavy,
                        inactiveColor: isDark ? AppColors.darkBorder : AppColors.slate200,
                        onChanged: (v) => setState(() => _customAmount = v),
                      ),
                      TariffBreakdownCard(totalAmount: _customAmount),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 22),

              // 4. Published Standard Tariffs by Trade
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Published Standard Tariffs',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : AppColors.slate900,
                    ),
                  ),
                  Text(
                    '${filteredServices.length} Services',
                    style: const TextStyle(fontSize: 11, color: AppColors.slate500),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Trade Filter Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: ['ALL', 'Electrical', 'Plumbing', 'Carpentry', 'Painting', 'Appliance'].map((trade) {
                    final isSel = _selectedTradeFilter == trade;
                    return Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: ChoiceChip(
                        label: Text(trade == 'ALL' ? 'All Trades' : trade),
                        selected: isSel,
                        onSelected: (_) => setState(() => _selectedTradeFilter = trade),
                        selectedColor: AppColors.primaryNavy,
                        labelStyle: TextStyle(
                          fontSize: 11,
                          fontWeight: isSel ? FontWeight.bold : FontWeight.w500,
                          color: isSel ? Colors.white : (isDark ? Colors.white70 : AppColors.slate700),
                        ),
                        backgroundColor: isDark ? AppColors.darkCard : AppColors.slate100,
                        side: BorderSide.none,
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 10),

              Card(
                color: isDark ? AppColors.darkCard : Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.slate200),
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filteredServices.take(10).length,
                  separatorBuilder: (context, index) => Divider(
                    height: 1,
                    color: isDark ? AppColors.darkBorder : AppColors.slate100,
                  ),
                  itemBuilder: (context, idx) {
                    final s = filteredServices[idx];
                    final adjustedPrice = locProv.calculateAreaPrice(s.basePrice);

                    return ListTile(
                      dense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                      title: Text(
                        s.name,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : AppColors.slate900,
                        ),
                      ),
                      subtitle: Text(
                        '${s.category} • ${s.durationMinutes} mins • 30d Warranty',
                        style: TextStyle(
                          fontSize: 10.5,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.slate500,
                        ),
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '₹$adjustedPrice',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              color: isDark ? AppColors.darkGreenFg : AppColors.accentGreen,
                            ),
                          ),
                          if (locProv.multiplier != 1.0)
                            Text(
                              locProv.selectedLocation.shortName,
                              style: const TextStyle(fontSize: 9, color: AppColors.slate400),
                            ),
                        ],
                      ),
                      onTap: () => context.push('/services/${s.id}'),
                    );
                  },
                ),
              ),

              const SizedBox(height: 22),

              // 5. Locked Spare Parts Ceiling Catalog
              Text(
                'Locked Spare Parts Price Ceiling',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : AppColors.slate900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Artisans cannot charge above these government-approved ceiling rates for spare parts.',
                style: TextStyle(fontSize: 11, color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
              ),
              const SizedBox(height: 8),

              Card(
                color: isDark ? AppColors.darkCard : Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.slate200),
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: spareParts.length,
                  separatorBuilder: (context, index) => Divider(
                    height: 1,
                    color: isDark ? AppColors.darkBorder : AppColors.slate100,
                  ),
                  itemBuilder: (context, idx) {
                    final p = spareParts[idx];
                    return ListTile(
                      dense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                      leading: Icon(
                        Icons.shield_rounded,
                        color: isDark ? AppColors.darkGreenFg : AppColors.accentGreen,
                        size: 18,
                      ),
                      title: Text(
                        p['part'],
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : AppColors.slate900,
                        ),
                      ),
                      subtitle: Text(
                        p['trade'],
                        style: const TextStyle(fontSize: 10, color: AppColors.slate500),
                      ),
                      trailing: Text(
                        'Max ₹${(p['ceiling'] as double).toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.secondarySaffron : AppColors.primaryNavy,
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
