import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/api_endpoints.dart';
import '../core/network/api_client.dart';

class FederationOverviewScreen extends StatefulWidget {
  const FederationOverviewScreen({super.key});

  @override
  State<FederationOverviewScreen> createState() => _FederationOverviewScreenState();
}

class _FederationOverviewScreenState extends State<FederationOverviewScreen> {
  bool _isLoading = true;
  List<dynamic> _districts = [];
  final Map<String, dynamic> _stats = {
    'totalSocieties': 14,
    'totalDistricts': 3,
    'welfareReserve': 548200,
    'totalWorkers': 156,
  };

  @override
  void initState() {
    super.initState();
    _fetchFederationData();
  }

  Future<void> _fetchFederationData() async {
    setState(() => _isLoading = true);
    try {
      final res = await ApiClient().get(ApiEndpoints.districts);
      if (res is List && mounted) {
        setState(() {
          _districts = res;
          _stats['totalDistricts'] = res.length;
          _isLoading = false;
        });
        return;
      }
    } catch (_) {}

    // Mock districts if backend returns empty or during offline demo
    if (mounted) {
      setState(() {
        _districts = [
          {
            'id': 1,
            'name': 'Khordha (Bhubaneswar Urban)',
            'code': 'KHD-01',
            'active': true,
            'societies_count': 6,
            'workers_count': 78,
            'monthly_gmv': 1450000,
          },
          {
            'id': 2,
            'name': 'Cuttack (Heritage & Crafts)',
            'code': 'CTC-02',
            'active': true,
            'societies_count': 5,
            'workers_count': 52,
            'monthly_gmv': 980000,
          },
          {
            'id': 3,
            'name': 'Puri (Coastal & Pilgrim Guild)',
            'code': 'PRI-03',
            'active': true,
            'societies_count': 3,
            'workers_count': 26,
            'monthly_gmv': 415600,
          },
        ];
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleDistrict(int districtId, bool currentStatus) async {
    try {
      await ApiClient().patch(ApiEndpoints.toggleDistrict(districtId));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.success,
            content: Text('District status updated successfully.'),
          ),
        );
        _fetchFederationData();
      }
    } catch (e) {
      // Local toggle for demo resilience
      setState(() {
        final idx = _districts.indexWhere((d) => d['id'] == districtId);
        if (idx != -1) {
          _districts[idx]['active'] = !currentStatus;
        }
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.primary,
            content: Text('District ${!currentStatus ? "activated" : "deactivated"} (Demo Mode)'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        title: Text(
          'Federation & District Hierarchy',
          style: GoogleFonts.dmSans(fontWeight: FontWeight.bold, fontSize: 17),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.textSecondary),
            onPressed: _fetchFederationData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // State Apex Hierarchy Header Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.cardSurface,
                          AppColors.accent.withAlpha(20),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.borderDark),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.account_tree_outlined, color: AppColors.primary, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'APEX FEDERATION GOVERNANCE',
                              style: GoogleFonts.dmSans(
                                color: AppColors.primaryLight,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Odisha State Federation of Labour Cooperatives',
                          style: GoogleFonts.dmSans(
                            color: AppColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Apex Body Reg: MSCS/CR/2026/OD-001 • Statutory Oversight by Registrar of Cooperative Societies (RCS)',
                          style: GoogleFonts.inter(
                            color: AppColors.textSecondary,
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.cardSurfaceAlt,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.borderDark),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _StatMini(label: 'Districts', val: '${_districts.length}'),
                              Container(height: 24, width: 1, color: AppColors.borderDark),
                              _StatMini(label: 'Societies', val: '${_stats["totalSocieties"] ?? 14}'),
                              Container(height: 24, width: 1, color: AppColors.borderDark),
                              _StatMini(
                                label: 'Welfare Fund',
                                val: '₹${((_stats["welfareReserve"] ?? 548200) / 1000).toStringAsFixed(0)}K',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 22),

                  // District Portals & Controls Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'OPERATIONAL DISTRICTS REGISTRY',
                        style: GoogleFonts.dmSans(
                          color: AppColors.primaryLight,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () => context.go('/society-registration'),
                        icon: const Icon(Icons.add, color: AppColors.primary, size: 16),
                        label: Text(
                          'Register Society',
                          style: GoogleFonts.dmSans(
                            color: AppColors.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _districts.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final dist = _districts[index];
                      final id = dist['id'] ?? index + 1;
                      final name = dist['name'] ?? 'District $id';
                      final code = dist['code'] ?? 'DIST-$id';
                      final active = dist['active'] == true;
                      final societies = dist['societies_count'] ?? 4;
                      final workers = dist['workers_count'] ?? 30;
                      final gmv = dist['monthly_gmv'] ?? 800000;

                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.cardSurface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: active ? AppColors.borderDark : AppColors.error.withAlpha(80),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: active ? AppColors.primary.withAlpha(25) : AppColors.errorBg,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    active ? Icons.location_city : Icons.location_off,
                                    color: active ? AppColors.primary : AppColors.error,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        name.toString(),
                                        style: GoogleFonts.dmSans(
                                          color: AppColors.textPrimary,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        'District Code: $code',
                                        style: GoogleFonts.inter(
                                          color: AppColors.textSecondary,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Transform.scale(
                                      scale: 0.8,
                                      child: Switch(
                                        value: active,
                                        activeThumbColor: AppColors.success,
                                        inactiveThumbColor: AppColors.textMuted,
                                        onChanged: (val) => _toggleDistrict(id, active),
                                      ),
                                    ),
                                    Text(
                                      active ? 'OPERATIONAL' : 'SUSPENDED',
                                      style: GoogleFonts.dmSans(
                                        color: active ? AppColors.success : AppColors.error,
                                        fontSize: 9,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            const Divider(color: AppColors.borderDark, height: 1),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _DistMetric(label: 'Societies', val: '$societies'),
                                _DistMetric(label: 'Active Workers', val: '$workers'),
                                _DistMetric(label: 'Monthly Volume', val: '₹${(gmv / 100000).toStringAsFixed(1)}L'),
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
    );
  }
}

class _StatMini extends StatelessWidget {
  final String label;
  final String val;

  const _StatMini({required this.label, required this.val});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          val,
          style: GoogleFonts.dmSans(
            color: AppColors.primary,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.inter(
            color: AppColors.textSecondary,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}

class _DistMetric extends StatelessWidget {
  final String label;
  final String val;

  const _DistMetric({required this.label, required this.val});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 10),
        ),
        Text(
          val,
          style: GoogleFonts.dmSans(
            color: AppColors.textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
