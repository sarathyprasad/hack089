import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants/app_colors.dart';
import '../core/network/api_client.dart';
import '../core/constants/api_endpoints.dart';

class RateCardScreen extends StatefulWidget {
  const RateCardScreen({super.key});

  @override
  State<RateCardScreen> createState() => _RateCardScreenState();
}

class _RateCardScreenState extends State<RateCardScreen> {
  List<dynamic> _services = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadRateCard();
  }

  Future<void> _loadRateCard() async {
    try {
      final res = await ApiClient().get(ApiEndpoints.services);
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
          title: const Text('Official Rate Card'),
        ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : Column(
              children: [
                // Header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  color: AppColors.accent.withValues(alpha: 0.1),
                  child: Column(
                    children: [
                      const Icon(Icons.gavel, size: 32, color: AppColors.accent),
                      const SizedBox(height: 8),
                      Text('Government Standardized Tariff', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 4),
                      const Text('Zero surge pricing. Rates set by Labour Cooperative Federation.', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    ],
                  ),
                ),

                // Rate Table
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _services.length,
                    itemBuilder: (context, i) {
                      final s = _services[i];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.borderLight),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(s['name']?.toString() ?? '', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600)),
                                  Text(s['category']?.toString().replaceAll('_', ' ') ?? '', style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                                ],
                              ),
                            ),
                            Text('₹${s['base_price'] ?? '—'}', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.primary)),
                          ],
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
