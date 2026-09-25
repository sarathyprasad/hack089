import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/api_endpoints.dart';
import '../core/network/api_client.dart';

class SocietyOperationsScreen extends StatefulWidget {
  const SocietyOperationsScreen({super.key});

  @override
  State<SocietyOperationsScreen> createState() => _SocietyOperationsScreenState();
}

class _SocietyOperationsScreenState extends State<SocietyOperationsScreen> {
  bool _isLoading = true;
  List<dynamic> _societies = [];
  String _selectedDistrict = 'ALL';

  @override
  void initState() {
    super.initState();
    _fetchSocieties();
  }

  Future<void> _fetchSocieties() async {
    setState(() => _isLoading = true);
    try {
      final res = await ApiClient().get(ApiEndpoints.societies);
      if (res is List && mounted) {
        setState(() {
          _societies = res;
          _isLoading = false;
        });
        return;
      }
    } catch (_) {}

    // Fallback societies list
    if (mounted) {
      setState(() {
        _societies = [
          {
            'id': 1,
            'name': 'Shramik Kalyan Labour Cooperative Samiti',
            'reg_no': 'CS-KHD-2023-014',
            'district': 'Khordha',
            'city': 'Bhubaneswar',
            'trade': 'Electrical & Plumbing',
            'members_count': 34,
            'audit_grade': 'Grade A',
            'agm_compliant': true,
            'status': 'OPERATIONAL',
          },
          {
            'id': 2,
            'name': 'Kalinga Shramik Seva Sahakari Samiti',
            'reg_no': 'CS-KHD-2023-019',
            'district': 'Khordha',
            'city': 'Khandagiri',
            'trade': 'Appliance & HVAC',
            'members_count': 22,
            'audit_grade': 'Grade A',
            'agm_compliant': true,
            'status': 'OPERATIONAL',
          },
          {
            'id': 3,
            'name': 'Utkal Shilpi Seva Sahakari Samiti',
            'reg_no': 'CS-CTC-2024-008',
            'district': 'Cuttack',
            'city': 'Badambadi',
            'trade': 'Carpentry & Woodwork',
            'members_count': 28,
            'audit_grade': 'Grade B+',
            'agm_compliant': true,
            'status': 'OPERATIONAL',
          },
          {
            'id': 4,
            'name': 'Jagannath Nirman Sahakari Federation',
            'reg_no': 'CS-PRI-2024-003',
            'district': 'Puri',
            'city': 'Puri Town',
            'trade': 'Civil & Masonry',
            'members_count': 19,
            'audit_grade': 'Grade A',
            'agm_compliant': true,
            'status': 'OPERATIONAL',
          },
        ];
        _isLoading = false;
      });
    }
  }

  void _showRosterDialog(Map<String, dynamic> society) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardSurface,
        title: Text(
          'Member Roster — ${society['name']}',
          style: GoogleFonts.dmSans(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Registration: ${society['reg_no']} • ${society['members_count']} Active Workers',
                style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 12),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.cardSurfaceAlt,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.borderDark),
                ),
                child: Column(
                  children: [
                    _RosterRow(name: 'Ramesh Patel', trade: 'Master Electrician', level: 'Level 4 (NSDC)'),
                    const Divider(color: AppColors.borderDark, height: 12),
                    _RosterRow(name: 'Suresh Kumar Das', trade: 'Sanitary Plumber', level: 'Level 3 (NSDC)'),
                    const Divider(color: AppColors.borderDark, height: 12),
                    _RosterRow(name: 'Priyaranjan Nayak', trade: 'HVAC Specialist', level: 'Level 4 (NSDC)'),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _selectedDistrict == 'ALL'
        ? _societies
        : _societies.where((s) => s['district']?.toString().toUpperCase() == _selectedDistrict).toList();

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        title: Text(
          'Primary Society Operations',
          style: GoogleFonts.dmSans(fontWeight: FontWeight.bold, fontSize: 17),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_business_outlined, color: AppColors.primary),
            tooltip: 'Register New Society',
            onPressed: () => context.go('/society-registration'),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : Column(
              children: [
                // Filter chips for District
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  color: AppColors.cardSurface,
                  child: Row(
                    children: [
                      Text(
                        'District Filter:',
                        style: GoogleFonts.dmSans(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: ['ALL', 'KHORDHA', 'CUTTACK', 'PURI'].map((d) {
                              final isSelected = _selectedDistrict == d;
                              return Padding(
                                padding: const EdgeInsets.only(right: 6),
                                child: ChoiceChip(
                                  label: Text(d),
                                  selected: isSelected,
                                  onSelected: (_) => setState(() => _selectedDistrict = d),
                                  selectedColor: AppColors.primary,
                                  backgroundColor: AppColors.cardSurfaceAlt,
                                  labelStyle: GoogleFonts.dmSans(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected ? Colors.black : AppColors.textPrimary,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: filtered.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final soc = filtered[index];
                      final id = soc['id'] ?? index + 1;
                      final name = soc['name'] ?? 'Society #$id';
                      final regNo = soc['reg_no'] ?? 'REG-PENDING';
                      final district = soc['district'] ?? 'Khordha';
                      final trade = soc['trade'] ?? 'Multi-Craft';
                      final members = soc['members_count'] ?? 15;
                      final grade = soc['audit_grade'] ?? 'Grade A';

                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.cardSurface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.borderDark),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withAlpha(25),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(Icons.groups, color: AppColors.primary, size: 22),
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
                                      const SizedBox(height: 2),
                                      Text(
                                        'Reg: $regNo • $district District',
                                        style: GoogleFonts.inter(
                                          color: AppColors.textSecondary,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: AppColors.successBg,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: AppColors.success),
                                  ),
                                  child: Text(
                                    grade,
                                    style: GoogleFonts.dmSans(
                                      color: AppColors.success,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            const Divider(color: AppColors.borderDark, height: 1),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Text(
                                  'Trade: ',
                                  style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 11),
                                ),
                                Text(
                                  trade,
                                  style: GoogleFonts.dmSans(
                                    color: AppColors.textPrimary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const Spacer(),
                                const Icon(Icons.badge_outlined, color: AppColors.primary, size: 14),
                                const SizedBox(width: 4),
                                Text(
                                  '$members Verified Members',
                                  style: GoogleFonts.inter(
                                    color: AppColors.primaryLight,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () => _showRosterDialog(soc),
                                    icon: const Icon(Icons.people_outline, size: 14),
                                    label: const Text('Member Roster'),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: AppColors.textPrimary,
                                      side: const BorderSide(color: AppColors.borderDark),
                                      padding: const EdgeInsets.symmetric(vertical: 8),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () => context.go('/society-timeline?id=$id'),
                                    icon: const Icon(Icons.timeline, size: 14),
                                    label: const Text('Statutory Audit'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      foregroundColor: Colors.black,
                                      padding: const EdgeInsets.symmetric(vertical: 8),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}

class _RosterRow extends StatelessWidget {
  final String name;
  final String trade;
  final String level;

  const _RosterRow({
    required this.name,
    required this.trade,
    required this.level,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.person, color: AppColors.primary, size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: GoogleFonts.dmSans(
                  color: AppColors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '$trade • $level',
                style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 11),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
