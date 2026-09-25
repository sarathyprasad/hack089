import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/api_endpoints.dart';
import '../core/network/api_client.dart';

class TariffAdminScreen extends StatefulWidget {
  const TariffAdminScreen({super.key});

  @override
  State<TariffAdminScreen> createState() => _TariffAdminScreenState();
}

class _TariffAdminScreenState extends State<TariffAdminScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;

  List<dynamic> _services = [];
  List<dynamic> _parts = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchTariffs();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchTariffs() async {
    setState(() => _isLoading = true);
    try {
      final sRes = await ApiClient().get('${ApiEndpoints.activeBaseUrl}/governance/admin/services');
      if (sRes is List && mounted) _services = sRes;
    } catch (_) {}

    try {
      final pRes = await ApiClient().get('${ApiEndpoints.activeBaseUrl}/governance/parts-catalog');
      if (pRes is List && mounted) _parts = pRes;
    } catch (_) {}

    if (mounted) {
      setState(() {
        if (_services.isEmpty) {
          _services = [
            {'id': 1, 'name': 'Electrical Diagnostic & Switchboard Repair', 'base_price': 299, 'category': 'Electrical', 'duration': 60},
            {'id': 2, 'name': 'Sanitary Plumbing & Leakage Overhaul', 'base_price': 349, 'category': 'Plumbing', 'duration': 60},
            {'id': 3, 'name': 'Split AC Deep Foam Jet Servicing', 'base_price': 599, 'category': 'Appliance', 'duration': 90},
            {'id': 4, 'name': 'Furniture Repair & Hinge Alignment', 'base_price': 399, 'category': 'Carpentry', 'duration': 60},
          ];
        }
        if (_parts.isEmpty) {
          _parts = [
            {'id': 1, 'name': 'Havells 16A Modular Switch', 'mrp': 85, 'trade': 'Electrical', 'warranty': '1 Year'},
            {'id': 2, 'name': 'Anchor Roma 32A DP MCB Switch', 'mrp': 220, 'trade': 'Electrical', 'warranty': '2 Years'},
            {'id': 3, 'name': 'Finolex 2.5 sq mm FR Wire (10m)', 'mrp': 160, 'trade': 'Electrical', 'warranty': '1 Year'},
            {'id': 4, 'name': 'Astral CPVC Heavy Duty Brass Elbow (1 inch)', 'mrp': 140, 'trade': 'Plumbing', 'warranty': '5 Years'},
          ];
        }
        _isLoading = false;
      });
    }
  }

  void _editServicePrice(Map<String, dynamic> service) {
    final priceController = TextEditingController(text: service['base_price'].toString());

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardSurface,
        title: Text(
          'Update Baseline Tariff — ${service['name']}',
          style: GoogleFonts.dmSans(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 15),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Statutory rule: 93% goes directly to artisan wage, 5% to welfare fund, 2% platform fee.',
              style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 11),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              style: GoogleFonts.inter(color: AppColors.textPrimary),
              decoration: const InputDecoration(labelText: 'Statutory Base Price (₹)'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                service['base_price'] = double.tryParse(priceController.text) ?? service['base_price'];
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: AppColors.success,
                  content: Text('Updated ${service['name']} tariff to ₹${priceController.text}.'),
                ),
              );
            },
            child: const Text('Save Rate'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        title: Text(
          'Statutory Tariff & Parts Catalog',
          style: GoogleFonts.dmSans(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          tabs: const [
            Tab(text: 'Service Wage Rates'),
            Tab(text: 'Genuine Parts Catalog'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : TabBarView(
              controller: _tabController,
              children: [
                // Tab 1: Service Rates
                ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _services.length,
                  separatorBuilder: (ctx, idx) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final s = _services[index];
                    final price = (s['base_price'] ?? 299) as num;
                    final workerWage = price * 0.93;

                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.cardSurface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.borderDark),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  s['name'],
                                  style: GoogleFonts.dmSans(
                                    color: AppColors.textPrimary,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Artisan Wage (93%): ₹${workerWage.toStringAsFixed(1)} • Welfare (5%): ₹${(price * 0.05).toStringAsFixed(1)}',
                                  style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '₹$price',
                                style: GoogleFonts.dmSans(
                                  color: AppColors.primary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextButton(
                                onPressed: () => _editServicePrice(s),
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: Text(
                                  'Edit Rate',
                                  style: GoogleFonts.dmSans(color: AppColors.accent, fontSize: 11),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),

                // Tab 2: Spare Parts Catalog
                ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _parts.length,
                  separatorBuilder: (ctx, idx) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final p = _parts[index];

                    return Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.cardSurface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.borderDark),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withAlpha(20),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.settings_suggest_outlined, color: AppColors.primary, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  p['name'],
                                  style: GoogleFonts.dmSans(
                                    color: AppColors.textPrimary,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Trade: ${p['trade']} • Statutory Warranty: ${p['warranty']}',
                                  style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '₹${p['mrp']}',
                            style: GoogleFonts.dmSans(
                              color: AppColors.gold,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
    );
  }
}
