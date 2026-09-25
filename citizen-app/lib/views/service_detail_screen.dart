import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants/app_colors.dart';
import '../core/network/api_client.dart';
import '../core/constants/api_endpoints.dart';

class ServiceDetailScreen extends StatefulWidget {
  final int serviceId;
  const ServiceDetailScreen({super.key, required this.serviceId});

  @override
  State<ServiceDetailScreen> createState() => _ServiceDetailScreenState();
}

class _ServiceDetailScreenState extends State<ServiceDetailScreen> {
  Map<String, dynamic>? _service;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadService();
  }

  Future<void> _loadService() async {
    try {
      final res = await ApiClient().get(ApiEndpoints.serviceDetail(widget.serviceId));
      if (res is Map && res['service'] is Map) {
        setState(() => _service = Map<String, dynamic>.from(res['service']));
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
          context.go('/services');
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
                context.go('/services');
              }
            },
          ),
          title: Text(_service?['name']?.toString() ?? 'Service Detail'),
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
            : _service == null
                ? const Center(child: Text('Service not found'))
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header Card
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(colors: [Color(0xFF0284C7), Color(0xFF0369A1)]),
                            borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_service!['name']?.toString() ?? '', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white)),
                            const SizedBox(height: 8),
                            Text(_service!['category']?.toString().replaceAll('_', ' ') ?? '', style: const TextStyle(color: Colors.white70, fontSize: 14)),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Text('₹${_service!['base_price'] ?? '—'}', style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white)),
                                const SizedBox(width: 8),
                                const Text('/ visit', style: TextStyle(color: Colors.white60, fontSize: 14)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Description
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.borderLight)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('About This Service', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 8),
                            Text(_service!['description']?.toString() ?? 'Professional cooperative service delivered by verified artisans.', style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.5)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Tariff Breakdown
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.borderLight)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Transparent Tariff (93-2-5)', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 12),
                            _TariffRow(label: 'Worker Direct Wage', pct: '93%', color: AppColors.workerWage),
                            _TariffRow(label: 'Platform Fee', pct: '2%', color: AppColors.platformFee),
                            _TariffRow(label: 'PF & Insurance', pct: '5%', color: AppColors.welfareFund),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Book CTA
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton.icon(
                          onPressed: () => context.go('/book-service?serviceId=${widget.serviceId}'),
                          icon: const Icon(Icons.calendar_today),
                          label: const Text('Book This Service', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
      ),
    );
  }
}

class _TariffRow extends StatelessWidget {
  final String label, pct;
  final Color color;
  const _TariffRow({required this.label, required this.pct, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(width: 12, height: 12, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
          const SizedBox(width: 10),
          Expanded(child: Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary))),
          Text(pct, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}
