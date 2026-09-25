import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants/app_colors.dart';

class DemandHeatmapScreen extends StatefulWidget {
  const DemandHeatmapScreen({super.key});

  @override
  State<DemandHeatmapScreen> createState() => _DemandHeatmapScreenState();
}

class _DemandHeatmapScreenState extends State<DemandHeatmapScreen> {
  String _selectedDistrict = 'All Clusters';
  String _preferredZone = 'Patia - Infocity Cluster';
  bool _isDetectingGps = false;

  final List<Map<String, dynamic>> _hotspots = [
    {
      'id': 1,
      'cluster': 'Patia - Infocity Cluster',
      'district': 'Khordha',
      'lat': 20.3540,
      'lng': 85.8190,
      'demand_level': 'VERY HIGH',
      'surge_bonus': '+20% Peak Incentive',
      'active_requests': 28,
      'avg_distance': '1.4 km',
      'primary_trades': 'AC Servicing • Electrical Overhaul',
      'depot_name': 'KIIT Square Co-op Tool Bank',
      'depot_contact': '+91 94370 55112',
      'intensity': 0.95,
      'color': Color(0xFFEF4444),
    },
    {
      'id': 2,
      'cluster': 'Saheed Nagar - Unit 9 Cluster',
      'district': 'Khordha',
      'lat': 20.2885,
      'lng': 85.8436,
      'demand_level': 'HIGH',
      'surge_bonus': '+15% Rush Bonus',
      'active_requests': 19,
      'avg_distance': '2.2 km',
      'primary_trades': 'Plumbing Leakage • Carpentry',
      'depot_name': 'Vani Vihar Regional Depot',
      'depot_contact': '+91 94370 55113',
      'intensity': 0.80,
      'color': Color(0xFFF59E0B),
    },
    {
      'id': 3,
      'cluster': 'CDA Sector 6 to 11 Cluster',
      'district': 'Cuttack',
      'lat': 20.4850,
      'lng': 85.8350,
      'demand_level': 'HIGH',
      'surge_bonus': '+15% Rush Bonus',
      'active_requests': 16,
      'avg_distance': '3.1 km',
      'primary_trades': 'Deep Cleaning • Electrical',
      'depot_name': 'Biju Patnaik Chowk Tool Hub',
      'depot_contact': '+91 94370 55114',
      'intensity': 0.75,
      'color': Color(0xFFF59E0B),
    },
    {
      'id': 4,
      'cluster': 'Badambadi - Link Road Cluster',
      'district': 'Cuttack',
      'lat': 20.4578,
      'lng': 85.8756,
      'demand_level': 'MODERATE',
      'surge_bonus': '+5% Fuel Aid',
      'active_requests': 11,
      'avg_distance': '2.8 km',
      'primary_trades': 'Appliance Repair • Painting',
      'depot_name': 'Badambadi Co-op Centre',
      'depot_contact': '+91 94370 55115',
      'intensity': 0.55,
      'color': Color(0xFF3B82F6),
    },
    {
      'id': 5,
      'cluster': 'Grand Road - VIP Road Temple Zone',
      'district': 'Puri',
      'lat': 19.8120,
      'lng': 85.8280,
      'demand_level': 'HIGH',
      'surge_bonus': '+15% Pilgrim Rush',
      'active_requests': 14,
      'avg_distance': '1.8 km',
      'primary_trades': 'Sanitary Plumbing • Masonry',
      'depot_name': 'Jagannath Ballav Artisan Centre',
      'depot_contact': '+91 94370 55116',
      'intensity': 0.78,
      'color': Color(0xFFF59E0B),
    },
  ];

  @override
  Widget build(BuildContext context) {
    final filtered = _selectedDistrict == 'All Clusters'
        ? _hotspots
        : _hotspots.where((h) => h['district'] == _selectedDistrict).toList();

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        if (context.canPop()) {
          context.pop();
        } else {
          context.go('/dashboard');
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
                context.go('/dashboard');
              }
            },
          ),
          title: Text(
            'Live Demand Heatmap & Surge',
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Radar Visual Header
            _buildHeatmapRadarHero(),

            const SizedBox(height: 16),

            // District Filter Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['All Clusters', 'Khordha', 'Cuttack', 'Puri'].map((d) {
                  final isSelected = _selectedDistrict == d;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(d),
                      selected: isSelected,
                      selectedColor: AppColors.primary,
                      backgroundColor: AppColors.cardSurface,
                      labelStyle: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? Colors.white : AppColors.textSecondary,
                      ),
                      onSelected: (val) {
                        if (val) setState(() => _selectedDistrict = d);
                      },
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 16),

            // List of Clusters
            Text(
              'ACTIVE DEMAND CLUSTERS (${filtered.length})',
              style: GoogleFonts.outfit(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.8,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 10),

            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filtered.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final h = filtered[index];
                final isPreferred = _preferredZone == h['cluster'];

                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.cardSurface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isPreferred ? AppColors.accent : AppColors.borderDark,
                      width: isPreferred ? 2 : 1,
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
                              color: (h['color'] as Color).withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(Icons.whatshot, color: h['color'] as Color, size: 20),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  h['cluster'] as String,
                                  style: GoogleFonts.outfit(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  '${h['district']} District • ${h['avg_distance']} away',
                                  style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: (h['color'] as Color).withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: h['color'] as Color),
                            ),
                            child: Text(
                              h['surge_bonus'] as String,
                              style: GoogleFonts.outfit(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: h['color'] as Color,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Metrics strip
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.cardSurfaceAlt,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildClusterMetric('WAITING JOBS', '${h['active_requests']}', AppColors.accent),
                            _buildClusterMetric('PRIMARY SKILLS', h['primary_trades'] as String, Colors.white),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Nearest Tool & Parts Depot
                      Row(
                        children: [
                          const Icon(Icons.handyman_outlined, size: 14, color: AppColors.textSecondary),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Depot: ${h['depot_name']} (${h['depot_contact']})',
                              style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Set preferred zone
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (isPreferred)
                            Row(
                              children: [
                                const Icon(Icons.check_circle, color: AppColors.accent, size: 16),
                                const SizedBox(width: 6),
                                Text(
                                  'Active Preferred Dispatch Area',
                                  style: GoogleFonts.inter(fontSize: 11, color: AppColors.accent, fontWeight: FontWeight.bold),
                                ),
                              ],
                            )
                          else
                            const SizedBox.shrink(),
                          ElevatedButton.icon(
                            onPressed: () {
                              setState(() => _preferredZone = h['cluster'] as String);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Priority dispatch set to ${h['cluster']}! You will receive high-surge pings first.'),
                                ),
                              );
                            },
                            icon: const Icon(Icons.my_location, size: 14),
                            label: Text(isPreferred ? 'Current' : 'Select Cluster'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isPreferred ? AppColors.accent.withValues(alpha: 0.3) : AppColors.primary,
                              foregroundColor: isPreferred ? AppColors.accent : Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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

  Widget _buildHeatmapRadarHero() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: AppColors.available,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'LIVE DEMAND DISPATCH RADAR',
                style: GoogleFonts.outfit(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                  color: AppColors.accent,
                ),
              ),
              const Spacer(),
              Text(
                'Auto-refreshed (30s)',
                style: GoogleFonts.inter(fontSize: 10, color: AppColors.textMuted),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '88 Unfulfilled Bookings Across Greater Bhubaneswar-Cuttack',
            style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 6),
          Text(
            'Move towards orange and red clusters to unlock automatic +15% to +20% cooperative peak surge bonuses.',
            style: GoogleFonts.inter(fontSize: 11.5, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isDetectingGps ? null : _detectWorkerGps,
              icon: _isDetectingGps
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.gps_fixed_rounded, size: 16),
              label: Text(
                _isDetectingGps
                    ? 'Detecting Satellite GPS...'
                    : 'Auto-Locate Nearest Hotspot via GPS',
                style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 11),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _detectWorkerGps() async {
    setState(() => _isDetectingGps = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please enable GPS location service on your device.')),
          );
        }
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Location permission denied.')),
            );
          }
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permission is permanently denied.')),
          );
        }
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 8),
        ),
      );

      Map<String, dynamic>? closest;
      double minKm = double.infinity;
      for (final h in _hotspots) {
        final lat = (h['lat'] as num).toDouble();
        final lng = (h['lng'] as num).toDouble();
        final km = _calcKm(position.latitude, position.longitude, lat, lng);
        if (km < minKm) {
          minKm = km;
          closest = h;
        }
      }

      if (closest != null && mounted) {
        setState(() {
          _preferredZone = closest!['cluster'] as String;
          _selectedDistrict = 'All Clusters';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.available,
            content: Text(
              '📍 GPS Locked! Matched nearest surge hotspot: ${closest['cluster']} (${minKm.toStringAsFixed(1)} km away)',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not get GPS location: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isDetectingGps = false);
    }
  }

  double _calcKm(double lat1, double lon1, double lat2, double lon2) {
    const r = 6371.0;
    final dLat = (lat2 - lat1) * (math.pi / 180.0);
    final dLon = (lon2 - lon1) * (math.pi / 180.0);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1 * (math.pi / 180.0)) *
            math.cos(lat2 * (math.pi / 180.0)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return r * c;
  }

  Widget _buildClusterMetric(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(fontSize: 9, color: AppColors.textMuted, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }
}
