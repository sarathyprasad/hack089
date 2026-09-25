import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/api_endpoints.dart';
import '../core/network/api_client.dart';

class ApplianceLineageScreen extends StatefulWidget {
  const ApplianceLineageScreen({super.key});

  @override
  State<ApplianceLineageScreen> createState() => _ApplianceLineageScreenState();
}

class _ApplianceLineageScreenState extends State<ApplianceLineageScreen> {
  bool _isLoading = true;
  List<dynamic> _appliances = [];

  @override
  void initState() {
    super.initState();
    _fetchLineage();
  }

  Future<void> _fetchLineage() async {
    try {
      final res = await ApiClient().get(ApiEndpoints.applianceLineage);
      if (res is List && mounted) {
        setState(() {
          _appliances = res;
          _isLoading = false;
        });
        return;
      }
    } catch (_) {}

    // Fallback demo appliances
    if (mounted) {
      setState(() {
        _appliances = [
          {
            'id': 1,
            'brand': 'Voltas 1.5 Ton Split AC',
            'serial_no': 'OD-APL-2024-8841',
            'room': 'Master Bedroom',
            'last_serviced': '15 Aug 2026',
            'technician': 'Ramesh Patel (Master Electrician)',
            'parts_replaced': 'Compressor Capacitor (50uF) & Filter Jet Clean',
            'warranty_days_remaining': 19,
            'health_score': 94,
          },
          {
            'id': 2,
            'brand': 'Havells 25L Storage Geyser',
            'serial_no': 'OD-APL-2025-1029',
            'room': 'Common Bathroom',
            'last_serviced': '10 Jan 2026',
            'technician': 'Suresh Kumar Das (Sanitary Plumber)',
            'parts_replaced': 'Magnesium Anode Rod & Thermostat Calibration',
            'warranty_days_remaining': 0,
            'health_score': 78,
          },
          {
            'id': 3,
            'brand': 'Kent Grand Plus RO Water Purifier',
            'serial_no': 'OD-APL-2025-4491',
            'room': 'Kitchen',
            'last_serviced': '02 Jul 2026',
            'technician': 'Priyaranjan Nayak (Water Works Specialist)',
            'parts_replaced': 'Sediment Filter & Carbon Block',
            'warranty_days_remaining': 112,
            'health_score': 98,
          },
        ];
        _isLoading = false;
      });
    }
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
          title: Text(
            'Appliance Digital Passport',
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 17),
          ),
        ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Passport Header Banner
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.primary, const Color(0xFF047857)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.qr_code_2_rounded, color: Colors.white, size: 28),
                            const SizedBox(width: 10),
                            Text(
                              'COOPERATIVE APPLIANCE LINEAGE',
                              style: GoogleFonts.outfit(
                                color: Colors.white70,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Verified Service History & Warranty',
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Every genuine part replaced and service conducted by cooperative artisans is cryptographically timestamped in your digital home ledger.',
                          style: GoogleFonts.inter(color: Colors.white.withAlpha(200), fontSize: 11),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  Text(
                    'REGISTERED HOUSEHOLD APPLIANCES',
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSecondary,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 10),

                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _appliances.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final a = _appliances[index];
                      final remaining = a['warranty_days_remaining'] ?? 0;
                      final hasWarranty = remaining > 0;

                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.borderLight),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    a['brand'],
                                    style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: hasWarranty ? AppColors.success.withAlpha(25) : AppColors.borderMedium.withAlpha(50),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    hasWarranty ? '$remaining Days Warranty' : 'Warranty Expired',
                                    style: GoogleFonts.inter(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: hasWarranty ? AppColors.success : AppColors.textMuted,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Tag: ${a['serial_no']} • Location: ${a['room']}',
                              style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.scaffoldBg,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.history, size: 14, color: AppColors.primary),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Last Serviced: ${a['last_serviced']}',
                                        style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Artisan: ${a['technician']}',
                                    style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary),
                                  ),
                                  Text(
                                    'Work/Parts: ${a['parts_replaced']}',
                                    style: GoogleFonts.inter(fontSize: 11, color: AppColors.textPrimary),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.favorite, color: AppColors.primary, size: 16),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Health Score: ${a['health_score']}%',
                                      style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
                                    ),
                                  ],
                                ),
                                ElevatedButton.icon(
                                  onPressed: () => context.push('/book'),
                                  icon: const Icon(Icons.build_circle_outlined, size: 14),
                                  label: const Text('Book Maintenance'),
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    textStyle: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.bold),
                                    minimumSize: Size.zero,
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
      ),
    );
  }
}
