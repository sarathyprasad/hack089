class ServiceModel {
  final int id;
  final String name;
  final String category;
  final String description;
  final double basePrice;
  final int durationMinutes;
  final String? iconName;
  final bool isEmergencyAvailable;
  final int activeWorkersCount;
  final List<String> checklist;

  ServiceModel({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.basePrice,
    required this.durationMinutes,
    this.iconName,
    this.isEmergencyAvailable = false,
    this.activeWorkersCount = 0,
    this.checklist = const [],
  });

  // 93-2-5 Escrow Tariff Calculations
  double get workerTakeHome => double.parse((basePrice * 0.93).toStringAsFixed(2));
  double get welfareLevy => double.parse((basePrice * 0.05).toStringAsFixed(2));
  double get platformFee => double.parse((basePrice * 0.02).toStringAsFixed(2));

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    List<String> items = [];
    if (json['checklist'] is List) {
      items = (json['checklist'] as List).map((e) => e.toString()).toList();
    } else if (json['description'] != null && json['description'].toString().contains('•')) {
      items = json['description'].toString().split('•').skip(1).map((e) => e.trim()).toList();
    }

    return ServiceModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? '',
      category: json['category']?.toString() ?? 'General',
      description: json['description']?.toString() ?? '',
      basePrice: double.tryParse(json['base_price']?.toString() ?? '0') ?? 0.0,
      durationMinutes: int.tryParse(json['duration_minutes']?.toString() ?? '60') ?? 60,
      iconName: json['icon_name']?.toString(),
      isEmergencyAvailable: json['is_emergency_available'] == true || json['is_emergency'] == true,
      activeWorkersCount: int.tryParse(json['active_workers_count']?.toString() ?? '0') ?? 0,
      checklist: items,
    );
  }
}
