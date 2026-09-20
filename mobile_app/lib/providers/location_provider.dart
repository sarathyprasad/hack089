import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import '../core/storage/storage_service.dart';
import '../core/network/api_client.dart';
import '../core/constants/api_endpoints.dart';

class ServiceLocation {
  final int id;
  final int societyId;
  final String name;
  final String district;
  final String city;
  final String pincode;
  final double multiplier;
  final String label;
  final String tag;
  final double lat;
  final double lng;

  const ServiceLocation({
    required this.id,
    required this.societyId,
    required this.name,
    required this.district,
    required this.city,
    required this.pincode,
    required this.multiplier,
    required this.label,
    required this.tag,
    required this.lat,
    required this.lng,
  });

  String get shortName => name.split('/').first.trim();

  factory ServiceLocation.fromJson(Map<String, dynamic> json) {
    return ServiceLocation(
      id: json['id'] as int? ?? 1,
      societyId: json['society_id'] as int? ?? 1,
      name: json['name'] as String? ?? 'Bhubaneswar Central',
      district: json['district'] as String? ?? 'Khordha',
      city: json['city'] as String? ?? 'Bhubaneswar',
      pincode: json['pincode'] as String? ?? '751001',
      multiplier: (json['multiplier'] as num?)?.toDouble() ?? 1.0,
      label: json['label'] as String? ?? 'Standard Base Rate (0%)',
      tag: json['tag'] as String? ?? '',
      lat: (json['lat'] as num?)?.toDouble() ?? 20.2885,
      lng: (json['lng'] as num?)?.toDouble() ?? 85.8436,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'society_id': societyId,
    'name': name,
    'district': district,
    'city': city,
    'pincode': pincode,
    'multiplier': multiplier,
    'label': label,
    'tag': tag,
    'lat': lat,
    'lng': lng,
  };
}

class UnsupportedLocation {
  final String name;
  final String district;
  final bool isComingSoon;
  final int distanceKm;

  const UnsupportedLocation({
    required this.name,
    required this.district,
    this.isComingSoon = true,
    required this.distanceKm,
  });

  factory UnsupportedLocation.fromJson(Map<String, dynamic> json) {
    return UnsupportedLocation(
      name: json['name'] as String? ?? 'Unknown Area',
      district: json['district'] as String? ?? 'Odisha',
      isComingSoon: json['isComingSoon'] as bool? ?? true,
      distanceKm: (json['distanceKm'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'district': district,
    'isComingSoon': isComingSoon,
    'distanceKm': distanceKm,
  };
}

class KnownExternalCity {
  final String name;
  final String district;
  final double lat;
  final double lng;

  const KnownExternalCity({
    required this.name,
    required this.district,
    required this.lat,
    required this.lng,
  });
}

class LocationProvider extends ChangeNotifier {
  static const List<ServiceLocation> defaultLocations = [
    ServiceLocation(
      id: 1,
      societyId: 1,
      name: 'Saheed Nagar / Master Canteen',
      district: 'Khordha',
      city: 'Bhubaneswar',
      pincode: '751001',
      multiplier: 1.04,
      label: 'Central Urban (+4%)',
      tag: 'High Commercial Traffic',
      lat: 20.2885,
      lng: 85.8436,
    ),
    ServiceLocation(
      id: 2,
      societyId: 2,
      name: 'Khandagiri / Aiginia',
      district: 'Khordha',
      city: 'Bhubaneswar',
      pincode: '751030',
      multiplier: 1.00,
      label: 'Standard Base Rate (0%)',
      tag: 'Suburban Residential',
      lat: 20.2588,
      lng: 85.7865,
    ),
    ServiceLocation(
      id: 3,
      societyId: 3,
      name: 'Old Town / Lingaraj Heritage',
      district: 'Khordha',
      city: 'Bhubaneswar',
      pincode: '751002',
      multiplier: 1.03,
      label: 'Heritage Conservation (+3%)',
      tag: 'Narrow Lane & Heritage Restorations',
      lat: 20.2405,
      lng: 85.8340,
    ),
    ServiceLocation(
      id: 4,
      societyId: 4,
      name: 'Patia / Infocity IT Corridor',
      district: 'Khordha',
      city: 'Bhubaneswar',
      pincode: '751024',
      multiplier: 1.06,
      label: 'IT High-Rise Corridor (+6%)',
      tag: 'Multi-Story & Modern Gadgets',
      lat: 20.3540,
      lng: 85.8190,
    ),
    ServiceLocation(
      id: 5,
      societyId: 5,
      name: 'Badambadi / Ranihat',
      district: 'Cuttack',
      city: 'Cuttack',
      pincode: '753012',
      multiplier: 1.00,
      label: 'Commercial Base Rate (0%)',
      tag: 'Trade & Wholesale Zone',
      lat: 20.4578,
      lng: 85.8756,
    ),
    ServiceLocation(
      id: 6,
      societyId: 6,
      name: 'Madhupatna / OMP / Jagatpur',
      district: 'Cuttack',
      city: 'Cuttack',
      pincode: '753010',
      multiplier: 0.98,
      label: 'Industrial Artisan (-2%)',
      tag: 'High-Volume Fabrication Hub',
      lat: 20.4490,
      lng: 85.8920,
    ),
    ServiceLocation(
      id: 7,
      societyId: 7,
      name: 'CDA Sectors 1-14 / Cantonment',
      district: 'Cuttack',
      city: 'Cuttack',
      pincode: '753014',
      multiplier: 1.04,
      label: 'Planned Urban (+4%)',
      tag: 'Gated Societies & High-Rises',
      lat: 20.4850,
      lng: 85.8350,
    ),
    ServiceLocation(
      id: 8,
      societyId: 8,
      name: 'Silver City / Buxi Bazar',
      district: 'Cuttack',
      city: 'Cuttack',
      pincode: '753001',
      multiplier: 1.02,
      label: 'Heritage Artisan Guild (+2%)',
      tag: 'Traditional Craft Precinct',
      lat: 20.4630,
      lng: 85.8840,
    ),
    ServiceLocation(
      id: 9,
      societyId: 9,
      name: 'Grand Road / VIP Road',
      district: 'Puri',
      city: 'Puri',
      pincode: '752002',
      multiplier: 1.02,
      label: 'Pilgrim Corridor (+2%)',
      tag: 'High Pilgrim Density',
      lat: 19.8120,
      lng: 85.8280,
    ),
    ServiceLocation(
      id: 10,
      societyId: 10,
      name: 'Konark Sun Coast / Marine Drive',
      district: 'Puri',
      city: 'Konark',
      pincode: '752111',
      multiplier: 1.03,
      label: 'Eco-Tourism Coast (+3%)',
      tag: 'Resort & Solar Maintenance',
      lat: 19.8876,
      lng: 86.0945,
    ),
    ServiceLocation(
      id: 11,
      societyId: 11,
      name: 'Sea Beach Road / Baliapanda',
      district: 'Puri',
      city: 'Puri',
      pincode: '752001',
      multiplier: 1.05,
      label: 'Coastal Anti-Corrosive (+5%)',
      tag: 'High Saline & Rust Mitigation',
      lat: 19.7980,
      lng: 85.8250,
    ),
    ServiceLocation(
      id: 12,
      societyId: 12,
      name: 'Brahmagiri / Satapada / Chilika',
      district: 'Puri',
      city: 'Brahmagiri',
      pincode: '752001',
      multiplier: 0.96,
      label: 'Grassroots Subsidized (-4%)',
      tag: 'Rural Agro-Maritime Subsidy',
      lat: 19.8000,
      lng: 85.6700,
    ),
  ];

  static const List<KnownExternalCity> knownExternalCities = [
    KnownExternalCity(name: 'Berhampur', district: 'Ganjam', lat: 19.315, lng: 84.794),
    KnownExternalCity(name: 'Rourkela', district: 'Sundargarh', lat: 22.249, lng: 84.882),
    KnownExternalCity(name: 'Sambalpur', district: 'Sambalpur', lat: 21.466, lng: 83.975),
    KnownExternalCity(name: 'Balasore', district: 'Balasore', lat: 21.493, lng: 86.933),
    KnownExternalCity(name: 'Baripada', district: 'Mayurbhanj', lat: 21.934, lng: 86.736),
    KnownExternalCity(name: 'Angul', district: 'Angul', lat: 20.840, lng: 85.100),
    KnownExternalCity(name: 'Bhadrak', district: 'Bhadrak', lat: 21.057, lng: 86.495),
    KnownExternalCity(name: 'Jharsuguda', district: 'Jharsuguda', lat: 21.855, lng: 84.006),
    KnownExternalCity(name: 'Jeypore', district: 'Koraput', lat: 18.854, lng: 82.569),
  ];

  List<ServiceLocation> _locations = defaultLocations;
  int _selectedAreaId = 1;
  bool _isUsingCurrentLocation = false;
  bool _isDetectingLocation = false;
  String _locationNotice = '';
  UnsupportedLocation? _unsupportedLocation;

  List<ServiceLocation> get locations => _locations;
  int get selectedAreaId => _selectedAreaId;
  bool get isUsingCurrentLocation => _isUsingCurrentLocation;
  bool get isDetectingLocation => _isDetectingLocation;
  String get locationNotice => _locationNotice;
  UnsupportedLocation? get unsupportedLocation => _unsupportedLocation;

  ServiceLocation get selectedLocation {
    return _locations.firstWhere(
      (l) => l.id == _selectedAreaId,
      orElse: () => defaultLocations.first,
    );
  }

  String get selectedDistrict => selectedLocation.district;
  double get multiplier => selectedLocation.multiplier;
  String get label => selectedLocation.label;

  LocationProvider() {
    _initFromStorage();
  }

  void _initFromStorage() {
    _selectedAreaId = StorageService.getSelectedAreaId(defaultValue: 1);
    _isUsingCurrentLocation = StorageService.getUseCurrentLocation();
    final rawUnsupp = StorageService.getUnsupportedLocation();
    if (rawUnsupp != null) {
      _unsupportedLocation = UnsupportedLocation.fromJson(rawUnsupp);
    }
    fetchRemoteLocations();
  }

  Future<void> fetchRemoteLocations() async {
    try {
      final res = await ApiClient().get(ApiEndpoints.serviceLocations);
      if (res is Map && res['locations'] is List) {
        final list = (res['locations'] as List)
            .map((e) => ServiceLocation.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
        if (list.isNotEmpty) {
          _locations = list;
          notifyListeners();
        }
      }
    } catch (_) {
      // Use built-in 12 default hubs
    }
  }

  void showNotice(String msg) {
    _locationNotice = msg;
    notifyListeners();
  }

  void dismissNotice() {
    _locationNotice = '';
    notifyListeners();
  }

  static double calculateHaversineKm(double lat1, double lon1, double lat2, double lon2) {
    const double r = 6371; // Earth radius in km
    final dLat = (lat2 - lat1) * (math.pi / 180);
    final dLon = (lon2 - lon1) * (math.pi / 180);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1 * (math.pi / 180)) *
            math.cos(lat2 * (math.pi / 180)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return r * c;
  }

  Future<void> detectCurrentLocation({double? testLat, double? testLng}) async {
    _isDetectingLocation = true;
    notifyListeners();

    try {
      // Default to Khandagiri base coordinates or test coordinates
      final lat = testLat ?? 20.2588;
      final lng = testLng ?? 85.7865;

      int closestId = 2;
      double minKm = double.infinity;

      for (final loc in _locations) {
        final km = calculateHaversineKm(loc.lat, loc.lng, lat, lng);
        if (km < minKm) {
          minKm = km;
          closestId = loc.id;
        }
      }

      // 35km maximum cooperative service radius
      final isOutOfCoverage = minKm > 35;

      if (!isOutOfCoverage) {
        final matched = _locations.firstWhere((l) => l.id == closestId, orElse: () => defaultLocations[1]);
        _selectedAreaId = closestId;
        _isUsingCurrentLocation = true;
        _unsupportedLocation = null;

        await StorageService.saveSelectedAreaId(closestId);
        await StorageService.saveUseCurrentLocation(true);
        await StorageService.saveUnsupportedLocation(null);

        _isDetectingLocation = false;
        showNotice('📍 GPS detected: ${matched.shortName} (${matched.city})');
        notifyListeners();
        return;
      }

      // Out of coverage: Resolve nearest external city
      KnownExternalCity? closestCity;
      double minCityDist = double.infinity;
      for (final c in knownExternalCities) {
        final km = calculateHaversineKm(c.lat, c.lng, lat, lng);
        if (km < minCityDist) {
          minCityDist = km;
          closestCity = c;
        }
      }

      final cityName = closestCity != null && minCityDist < 80 ? closestCity.name : 'Berhampur';
      final districtName = closestCity != null && minCityDist < 80 ? closestCity.district : 'Ganjam';

      final unsupp = UnsupportedLocation(
        name: cityName,
        district: districtName,
        isComingSoon: true,
        distanceKm: minKm.round(),
      );

      _unsupportedLocation = unsupp;
      _isUsingCurrentLocation = true;
      _selectedAreaId = closestId; // Anchor pricing engine

      await StorageService.saveSelectedAreaId(closestId);
      await StorageService.saveUseCurrentLocation(true);
      await StorageService.saveUnsupportedLocation(unsupp.toJson());

      _isDetectingLocation = false;
      showNotice('📍 Detected: $cityName. Services are coming soon to your area! Active in Khordha, Cuttack & Puri.');
      notifyListeners();
    } catch (e) {
      _isDetectingLocation = false;
      showNotice('📍 Location detection defaulted to Khandagiri (Bhubaneswar)');
      notifyListeners();
    }
  }

  Future<void> changeLocation(int areaId) async {
    _selectedAreaId = areaId;
    _isUsingCurrentLocation = false;
    _unsupportedLocation = null;

    await StorageService.saveSelectedAreaId(areaId);
    await StorageService.saveUseCurrentLocation(false);
    await StorageService.saveUnsupportedLocation(null);

    final loc = _locations.firstWhere((l) => l.id == areaId, orElse: () => defaultLocations.first);
    showNotice('📍 Switched area: ${loc.shortName} (${loc.city})');
    notifyListeners();
  }

  Future<void> setSimulatedBerhampur() async {
    // Berhampur coordinates (19.315° N, 84.794° E)
    await detectCurrentLocation(testLat: 19.315, testLng: 84.794);
  }

  Future<void> clearUnsupportedLocation() async {
    _unsupportedLocation = null;
    await StorageService.saveUnsupportedLocation(null);
    notifyListeners();
  }

  int calculateAreaPrice(num basePrice, {String priceUnit = 'per_visit'}) {
    final base = basePrice.toDouble();
    if (priceUnit == 'per_sqft') {
      return math.max(1, (base * multiplier).round());
    }
    final raw = base * multiplier;
    return math.max(99, ((raw / 5).round() * 5));
  }
}
