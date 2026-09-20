import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../../providers/location_provider.dart';

class LocationSelectionModal extends StatefulWidget {
  const LocationSelectionModal({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const LocationSelectionModal(),
    );
  }

  @override
  State<LocationSelectionModal> createState() => _LocationSelectionModalState();
}

class _LocationSelectionModalState extends State<LocationSelectionModal> {
  String _filterCity = 'ALL';

  @override
  Widget build(BuildContext context) {
    final locProv = context.watch<LocationProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final unsupp = locProv.unsupportedLocation;

    final filteredLocations = locProv.locations.where((l) {
      if (_filterCity == 'ALL') return true;
      return l.city.toUpperCase() == _filterCity.toUpperCase();
    }).toList();

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBackground : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 20, offset: Offset(0, -4)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 10, bottom: 6),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? Colors.white24 : Colors.black12,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 6, 12, 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryNavy.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.location_on_rounded, color: AppColors.primaryNavy, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Select Service Location',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white : AppColors.slate900,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Regulated cooperative hubs across Odisha',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppColors.slate400 : AppColors.slate500,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  color: isDark ? Colors.white70 : AppColors.slate600,
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              children: [
                // 1. GPS Auto-Detect Button
                InkWell(
                  onTap: locProv.isDetectingLocation
                      ? null
                      : () async {
                          await locProv.detectCurrentLocation();
                          if (context.mounted) {
                            Navigator.pop(context);
                          }
                        },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkCard : AppColors.blue50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark ? AppColors.darkBorder : AppColors.blue100,
                      ),
                    ),
                    child: Row(
                      children: [
                        if (locProv.isDetectingLocation)
                          const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.blue600),
                          )
                        else
                          const Icon(Icons.my_location_rounded, color: AppColors.blue600, size: 22),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                locProv.isDetectingLocation
                                    ? 'Detecting GPS coordinates...'
                                    : 'Use Current Location (GPS)',
                                style: TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : AppColors.blue700,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Auto-map to nearest active guild within 35 km',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isDark ? AppColors.slate400 : AppColors.slate600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (locProv.isUsingCurrentLocation && unsupp == null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.blue600,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'ACTIVE',
                              style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // 2. Coming Soon / Out of Coverage Notice (if active)
                if (unsupp != null) ...[
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkAmberBg : AppColors.amber50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark ? AppColors.darkAmberFg.withValues(alpha: 0.4) : AppColors.amber200,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.info_outline_rounded, color: AppColors.amber600, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '📍 ${unsupp.name} (${unsupp.district}) • Coming Soon',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: AppColors.amber700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Services are launching shortly in ${unsupp.name}. Active hubs are operating in Khordha, Cuttack & Puri (~${unsupp.distanceKm} km away).',
                          style: TextStyle(
                            fontSize: 11.5,
                            color: isDark ? AppColors.slate300 : AppColors.slate700,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton.icon(
                          onPressed: () {
                            locProv.changeLocation(1); // Saheed Nagar
                            Navigator.pop(context);
                          },
                          icon: const Icon(Icons.arrow_forward_rounded, size: 14),
                          label: const Text('Browse Active Bhubaneswar Hub'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryNavy,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            textStyle: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                // 3. Test Simulation Pill (Berhampur Coming Soon)
                Align(
                  alignment: Alignment.centerRight,
                  child: InkWell(
                    onTap: () async {
                      await locProv.setSimulatedBerhampur();
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.science_outlined, size: 14, color: isDark ? AppColors.slate400 : AppColors.slate500),
                          const SizedBox(width: 4),
                          Text(
                            'Test: Simulate Berhampur GPS (Coming Soon)',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: isDark ? AppColors.slate400 : AppColors.slate500,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // City filter chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: ['ALL', 'Bhubaneswar', 'Cuttack', 'Puri'].map((city) {
                      final isSel = _filterCity == city;
                      return Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: ChoiceChip(
                          label: Text(city == 'ALL' ? 'All Districts' : city),
                          selected: isSel,
                          onSelected: (_) => setState(() => _filterCity = city),
                          selectedColor: AppColors.primaryNavy,
                          labelStyle: TextStyle(
                            fontSize: 11.5,
                            fontWeight: isSel ? FontWeight.bold : FontWeight.w500,
                            color: isSel ? Colors.white : (isDark ? Colors.white70 : AppColors.slate700),
                          ),
                          backgroundColor: isDark ? AppColors.darkCard : AppColors.slate100,
                          side: BorderSide.none,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 12),

                // List of Hubs
                ...filteredLocations.map((loc) {
                  final isSelected = locProv.selectedAreaId == loc.id && unsupp == null;
                  final multPct = ((loc.multiplier - 1.0) * 100).round();
                  final multLabel = multPct > 0 ? '+$multPct%' : (multPct < 0 ? '$multPct%' : 'Base 0%');

                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkCard : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primaryNavy
                            : (isDark ? AppColors.darkBorder : AppColors.slate200),
                        width: isSelected ? 1.8 : 1.0,
                      ),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                      onTap: () {
                        locProv.changeLocation(loc.id);
                        Navigator.pop(context);
                      },
                      leading: CircleAvatar(
                        radius: 18,
                        backgroundColor: isSelected
                            ? AppColors.primaryNavy
                            : (isDark ? AppColors.slate800 : AppColors.slate100),
                        child: Icon(
                          Icons.apartment_rounded,
                          size: 18,
                          color: isSelected ? Colors.white : (isDark ? AppColors.slate300 : AppColors.slate600),
                        ),
                      ),
                      title: Row(
                        children: [
                          Expanded(
                            child: Text(
                              loc.shortName,
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                color: isDark ? Colors.white : AppColors.slate900,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: multPct > 0
                                  ? AppColors.blue50
                                  : (multPct < 0 ? AppColors.emerald50 : AppColors.slate100),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              multLabel,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: multPct > 0
                                    ? AppColors.blue700
                                    : (multPct < 0 ? AppColors.emerald700 : AppColors.slate600),
                              ),
                            ),
                          ),
                        ],
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 2),
                          Text(
                            '${loc.city} • PIN ${loc.pincode}',
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark ? AppColors.slate400 : AppColors.slate500,
                            ),
                          ),
                          if (loc.tag.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              loc.tag,
                              style: const TextStyle(
                                fontSize: 10,
                                fontStyle: FontStyle.italic,
                                color: AppColors.slate400,
                              ),
                            ),
                          ],
                        ],
                      ),
                      trailing: isSelected
                          ? const Icon(Icons.check_circle_rounded, color: AppColors.primaryNavy, size: 20)
                          : null,
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
