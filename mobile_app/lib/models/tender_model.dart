class TenderModel {
  final int id;
  final String title;
  final String description;
  final String department;
  final String district;
  final double estimatedValue;
  final String status; // OPEN, CLOSED, AWARDED
  final DateTime? deadline;
  final DateTime? publishedAt;
  final String? referenceNumber;
  final String? scope;
  final int? bidCount;

  TenderModel({
    required this.id,
    required this.title,
    required this.description,
    required this.department,
    required this.district,
    required this.estimatedValue,
    required this.status,
    this.deadline,
    this.publishedAt,
    this.referenceNumber,
    this.scope,
    this.bidCount,
  });

  factory TenderModel.fromJson(Map<String, dynamic> json) {
    return TenderModel(
      id: json['id'] ?? json['tender_id'] ?? 0,
      title: json['title']?.toString() ?? 'Untitled Tender',
      description: json['description']?.toString() ?? '',
      department: json['department']?.toString() ?? '',
      district: json['district']?.toString() ?? '',
      estimatedValue: double.tryParse(json['estimated_value']?.toString() ?? '0') ?? 0,
      status: json['status']?.toString().toUpperCase() ?? 'OPEN',
      deadline: json['deadline'] != null ? DateTime.tryParse(json['deadline'].toString()) : null,
      publishedAt: json['published_at'] != null ? DateTime.tryParse(json['published_at'].toString()) : null,
      referenceNumber: json['reference_number'] ?? json['referenceNumber'],
      scope: json['scope'],
      bidCount: json['bid_count'] ?? json['bidCount'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'department': department,
        'district': district,
        'estimated_value': estimatedValue,
        'status': status,
        'deadline': deadline?.toIso8601String(),
        'published_at': publishedAt?.toIso8601String(),
        'reference_number': referenceNumber,
        'scope': scope,
        'bid_count': bidCount,
      };

  bool get isOpen => status == 'OPEN';
  String get formattedValue => '₹${(estimatedValue / 100000).toStringAsFixed(1)}L';
}
