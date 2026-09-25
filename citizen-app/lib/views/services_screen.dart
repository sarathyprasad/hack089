import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants/app_colors.dart';
import '../core/network/api_client.dart';
import '../core/constants/api_endpoints.dart';

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  List<dynamic> _services = [];
  bool _loading = true;
  String _selectedCategory = 'ALL';

  final _categories = ['ALL', 'ELECTRICAL', 'PLUMBING', 'CARPENTRY', 'PAINTING', 'CLEANING', 'GARDENING', 'CAREGIVING', 'DRIVING', 'APPLIANCE_REPAIR', 'DOMESTIC', 'IT_CCTV', 'EMERGENCY'];

  @override
  void initState() {
    super.initState();
    _loadServices();
  }

  Future<void> _loadServices() async {
    setState(() => _loading = true);
    try {
      final params = <String, dynamic>{};
      if (_selectedCategory != 'ALL') params['category'] = _selectedCategory;
      final res = await ApiClient().get(ApiEndpoints.services, queryParameters: params);
      if (res is Map && res['services'] is List) {
        setState(() => _services = res['services']);
      }
    } catch (_) {}
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        if (context.canPop()) {
          context.pop();
        } else {
          context.go('/home');
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.scaffoldBg,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            tooltip: 'Back',
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/home');
              }
            },
          ),
          title: const Text('Services Catalog'),
        ),
      body: Column(
        children: [
          // Category Filter
          SizedBox(
            height: 48,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: _categories.length,
              itemBuilder: (context, i) {
                final cat = _categories[i];
                final selected = cat == _selectedCategory;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(cat == 'ALL' ? 'All' : cat.replaceAll('_', ' ').toLowerCase().split(' ').map((w) => '${w[0].toUpperCase()}${w.substring(1)}').join(' ')),
                    selected: selected,
                    onSelected: (_) {
                      setState(() => _selectedCategory = cat);
                      _loadServices();
                    },
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(color: selected ? Colors.white : AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                );
              },
            ),
          ),

          // Services List
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : _services.isEmpty
                    ? const Center(child: Text('No services found'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _services.length,
                        itemBuilder: (context, i) {
                          final s = _services[i];
                          return GestureDetector(
                            onTap: () => context.push('/services/${s['id']}'),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: AppColors.borderLight),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 48, height: 48,
                                    decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                                    child: const Icon(Icons.build_circle, color: AppColors.primary),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(s['name']?.toString() ?? '', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600)),
                                        const SizedBox(height: 4),
                                        Text(s['category']?.toString().replaceAll('_', ' ') ?? '', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text('₹${s['base_price'] ?? s['basePrice'] ?? '—'}', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.primary)),
                                      const Text('per visit', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
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
