import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../core/storage/storage_service.dart';

class AppLocation {
  final int id;
  final String name;
  final String district;
  final String city;
  final String pincode;
  final double latitude;
  final double longitude;
  final double multiplier;
  final String label;
  final String tag;
  final int artisanCount;
  final bool isPopular;

  const AppLocation({
    required this.id,
    required this.name,
    required this.district,
    required this.city,
    required this.pincode,
    required this.latitude,
    required this.longitude,
    required this.multiplier,
    required this.label,
    required this.tag,
    required this.artisanCount,
    this.isPopular = false,
  });

  String get shortName => '$name ($pincode)';
  String get fullDisplayName => '$name, $city, $district ($pincode)';
  String get districtCity => '$district • $city';

  String get rateMultiplierText {
    if (multiplier == 1.0) return 'Standard Base Rate (0%)';
    final pct = ((multiplier - 1.0) * 100).round();
    return pct > 0 ? '+$pct% Urban Traffic Tariff' : '$pct% Grassroots Subsidy';
  }
}

class LocationProvider extends ChangeNotifier {
  static const List<AppLocation> defaultClusters = [
    // Khordha (Bhubaneswar)
    AppLocation(
      id: 1,
      name: 'Saheed Nagar / Master Canteen',
      district: 'Khordha',
      city: 'Bhubaneswar',
      pincode: '751001',
      latitude: 20.2885,
      longitude: 85.8436,
      multiplier: 1.04,
      label: 'Central Urban (+4%)',
      tag: 'High Commercial Traffic',
      artisanCount: 84,
      isPopular: true,
    ),
    AppLocation(
      id: 2,
      name: 'Khandagiri / Aiginia',
      district: 'Khordha',
      city: 'Bhubaneswar',
      pincode: '751030',
      latitude: 20.2588,
      longitude: 85.7865,
      multiplier: 1.00,
      label: 'Standard Base Rate (0%)',
      tag: 'Suburban Residential',
      artisanCount: 76,
      isPopular: true,
    ),
    AppLocation(
      id: 3,
      name: 'Old Town / Lingaraj Heritage',
      district: 'Khordha',
      city: 'Bhubaneswar',
      pincode: '751002',
      latitude: 20.2405,
      longitude: 85.8340,
      multiplier: 1.03,
      label: 'Heritage Conservation (+3%)',
      tag: 'Narrow Lane & Heritage Restorations',
      artisanCount: 68,
      isPopular: false,
    ),
    AppLocation(
      id: 4,
      name: 'Patia / Infocity IT Corridor',
      district: 'Khordha',
      city: 'Bhubaneswar',
      pincode: '751024',
      latitude: 20.3540,
      longitude: 85.8190,
      multiplier: 1.06,
      label: 'IT High-Rise Corridor (+6%)',
      tag: 'Multi-Story & Modern Gadgets',
      artisanCount: 92,
      isPopular: true,
    ),

    // Cuttack
    AppLocation(
      id: 5,
      name: 'Badambadi / Ranihat',
      district: 'Cuttack',
      city: 'Cuttack',
      pincode: '753012',
      latitude: 20.4578,
      longitude: 85.8756,
      multiplier: 1.00,
      label: 'Commercial Base Rate (0%)',
      tag: 'Trade & Wholesale Zone',
      artisanCount: 71,
      isPopular: true,
    ),
    AppLocation(
      id: 6,
      name: 'Madhupatna / OMP / Jagatpur',
      district: 'Cuttack',
      city: 'Cuttack',
      pincode: '753010',
      latitude: 20.4490,
      longitude: 85.8920,
      multiplier: 0.98,
      label: 'Industrial Artisan (-2%)',
      tag: 'High-Volume Fabrication Hub',
      artisanCount: 53,
      isPopular: false,
    ),
    AppLocation(
      id: 7,
      name: 'CDA Sectors 1-14 / Cantonment',
      district: 'Cuttack',
      city: 'Cuttack',
      pincode: '753014',
      latitude: 20.4850,
      longitude: 85.8350,
      multiplier: 1.04,
      label: 'Planned Urban (+4%)',
      tag: 'Gated Societies & High-Rises',
      artisanCount: 59,
      isPopular: false,
    ),
    AppLocation(
      id: 8,
      name: 'Silver City / Buxi Bazar',
      district: 'Cuttack',
      city: 'Cuttack',
      pincode: '753001',
      latitude: 20.4630,
      longitude: 85.8840,
      multiplier: 1.02,
      label: 'Heritage Artisan Guild (+2%)',
      tag: 'Traditional Craft Precinct',
      artisanCount: 64,
      isPopular: false,
    ),

    // Puri
    AppLocation(
      id: 9,
      name: 'Grand Road / VIP Road',
      district: 'Puri',
      city: 'Puri',
      pincode: '752002',
      latitude: 19.8120,
      longitude: 85.8280,
      multiplier: 1.02,
      label: 'Pilgrim Corridor (+2%)',
      tag: 'High Pilgrim Density',
      artisanCount: 57,
      isPopular: true,
    ),
    AppLocation(
      id: 10,
      name: 'Konark Sun Coast / Marine Drive',
      district: 'Puri',
      city: 'Konark',
      pincode: '752111',
      latitude: 19.8876,
      longitude: 86.0945,
      multiplier: 1.03,
      label: 'Eco-Tourism Coast (+3%)',
      tag: 'Resort & Solar Maintenance',
      artisanCount: 42,
      isPopular: false,
    ),
    AppLocation(
      id: 11,
      name: 'Sea Beach Road / Baliapanda',
      district: 'Puri',
      city: 'Puri',
      pincode: '752001',
      latitude: 19.7980,
      longitude: 85.8250,
      multiplier: 1.05,
      label: 'Coastal Anti-Corrosive (+5%)',
      tag: 'High Saline & Rust Mitigation',
      artisanCount: 48,
      isPopular: false,
    ),
    AppLocation(
      id: 12,
      name: 'Brahmagiri / Satapada / Chilika',
      district: 'Puri',
      city: 'Brahmagiri',
      pincode: '752001',
      latitude: 19.8000,
      longitude: 85.6700,
      multiplier: 0.96,
      label: 'Grassroots Subsidized (-4%)',
      tag: 'Rural Agro-Maritime Subsidy',
      artisanCount: 39,
      isPopular: false,
    ),

    // Regional Hubs
    AppLocation(
      id: 13,
      name: 'Civil Township / Panposh',
      district: 'Sundargarh',
      city: 'Rourkela',
      pincode: '769001',
      latitude: 22.2490,
      longitude: 84.8820,
      multiplier: 1.03,
      label: 'Industrial Smart City (+3%)',
      tag: 'Steel Plant & Commercial Zone',
      artisanCount: 62,
      isPopular: true,
    ),
    AppLocation(
      id: 14,
      name: 'Silk City Central / Gosaninuagaon',
      district: 'Ganjam',
      city: 'Berhampur',
      pincode: '760001',
      latitude: 19.3150,
      longitude: 84.7940,
      multiplier: 1.01,
      label: 'Southern Commerce Hub (+1%)',
      tag: 'Textile & Trade Center',
      artisanCount: 55,
      isPopular: true,
    ),
    AppLocation(
      id: 15,
      name: 'VSS Marg / Budharaja',
      district: 'Sambalpur',
      city: 'Sambalpur',
      pincode: '768001',
      latitude: 21.4680,
      longitude: 83.9880,
      multiplier: 1.02,
      label: 'Western Regional Hub (+2%)',
      tag: 'Educational & Industrial Belt',
      artisanCount: 49,
      isPopular: true,
    ),
    AppLocation(
      id: 16,
      name: 'Remuna Golei / OT Road',
      district: 'Balasore',
      city: 'Balasore',
      pincode: '756001',
      latitude: 21.4930,
      longitude: 86.9330,
      multiplier: 1.00,
      label: 'Northern Trade Corridor (0%)',
      tag: 'Industrial Corridor & Port Highway',
      artisanCount: 44,
      isPopular: false,
    ),
  ];

  late AppLocation _selectedLocation;
  bool _isUsingGps = false;
  bool _isDetecting = false;
  String? _gpsStatusMessage;
  double? _lastGpsDistanceKm;

  AppLocation get selectedLocation => _selectedLocation;
  bool get isUsingGps => _isUsingGps;
  bool get isDetecting => _isDetecting;
  String? get gpsStatusMessage => _gpsStatusMessage;
  double? get lastGpsDistanceKm => _lastGpsDistanceKm;
  List<AppLocation> get locations => defaultClusters;

  List<String> get availableDistricts {
    final set = defaultClusters.map((l) => l.district).toSet();
    return set.toList();
  }

  LocationProvider() {
    final savedId = StorageService.getSelectedLocationId();
    if (savedId != null) {
      _selectedLocation = defaultClusters.firstWhere(
        (l) => l.id == savedId,
        orElse: () => defaultClusters.first,
      );
    } else {
      _selectedLocation = defaultClusters.first;
    }
  }

  void selectLocation(AppLocation location) {
    _selectedLocation = location;
    _isUsingGps = false;
    _gpsStatusMessage = null;
    _lastGpsDistanceKm = null;
    StorageService.saveSelectedLocationId(location.id);
    notifyListeners();
  }

  Future<bool> detectGpsLocation() async {
    _isDetecting = true;
    _gpsStatusMessage = 'Detecting current GPS coordinates...';
    notifyListeners();

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _gpsStatusMessage = 'Location services disabled. Please enable GPS.';
        _isDetecting = false;
        notifyListeners();
        return false;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _gpsStatusMessage = 'Location permissions denied.';
          _isDetecting = false;
          notifyListeners();
          return false;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _gpsStatusMessage = 'Location permissions permanently denied.';
        _isDetecting = false;
        notifyListeners();
        return false;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 8),
        ),
      );

      // Find nearest cluster via Haversine distance
      AppLocation? nearest;
      double minDistance = double.infinity;

      for (final loc in defaultClusters) {
        final dist = _calculateDistanceKm(
          position.latitude,
          position.longitude,
          loc.latitude,
          loc.longitude,
        );
        if (dist < minDistance) {
          minDistance = dist;
          nearest = loc;
        }
      }

      if (nearest != null) {
        _selectedLocation = nearest;
        _isUsingGps = true;
        _lastGpsDistanceKm = minDistance;
        _gpsStatusMessage = 'GPS matched: ${nearest.name} (${minDistance.toStringAsFixed(1)} km away)';
        await StorageService.saveSelectedLocationId(nearest.id);
      }

      _isDetecting = false;
      notifyListeners();
      return true;
    } catch (e) {
      _gpsStatusMessage = 'Failed to get GPS location. Selected default cluster.';
      _isDetecting = false;
      notifyListeners();
      return false;
    }
  }

  static double _calculateDistanceKm(
      double lat1, double lon1, double lat2, double lon2) {
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
}
