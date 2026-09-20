class SocietyModel {
  final int id;
  final String name;
  final String? registrationNo;
  final String trackingId;
  final String district;
  final String? blockPanchayat;
  final String? registrationDate;
  final String status;
  final int currentStage;
  final int membersCount;
  final double authorizedCapital;
  final String auditRating;
  final String? contactPerson;
  final String? contactPhone;
  final List<dynamic> timelineStages;

  SocietyModel({
    required this.id,
    required this.name,
    this.registrationNo,
    required this.trackingId,
    required this.district,
    this.blockPanchayat,
    this.registrationDate,
    required this.status,
    required this.currentStage,
    required this.membersCount,
    required this.authorizedCapital,
    required this.auditRating,
    this.contactPerson,
    this.contactPhone,
    this.timelineStages = const [],
  });

  factory SocietyModel.fromJson(Map<String, dynamic> json) {
    return SocietyModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? 'Labour Cooperative Society',
      registrationNo: json['registration_no']?.toString(),
      trackingId: json['tracking_id']?.toString() ?? 'OD-COOP-${json['id']}',
      district: json['district']?.toString() ?? 'Khordha',
      blockPanchayat: json['block_panchayat']?.toString(),
      registrationDate: json['registration_date']?.toString(),
      status: json['status']?.toString() ?? 'UNDER_SCRUTINY',
      currentStage: int.tryParse(json['current_stage']?.toString() ?? '1') ?? 1,
      membersCount: int.tryParse(json['members_count']?.toString() ?? '10') ?? 10,
      authorizedCapital: double.tryParse(json['authorized_capital']?.toString() ?? '100000') ?? 100000.0,
      auditRating: json['audit_rating']?.toString() ?? 'A',
      contactPerson: json['contact_person']?.toString(),
      contactPhone: json['contact_phone']?.toString(),
      timelineStages: json['timeline_stages'] is List ? json['timeline_stages'] : [],
    );
  }
}

class TenderModel {
  final int id;
  final String tenderNo;
  final String title;
  final String department;
  final String district;
  final double estimatedValue;
  final String submissionDeadline;
  final String status;
  final String description;
  final int tradesRequired;

  TenderModel({
    required this.id,
    required this.tenderNo,
    required this.title,
    required this.department,
    required this.district,
    required this.estimatedValue,
    required this.submissionDeadline,
    required this.status,
    required this.description,
    required this.tradesRequired,
  });

  factory TenderModel.fromJson(Map<String, dynamic> json) {
    return TenderModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      tenderNo: json['tender_no']?.toString() ?? 'TDR-2026-${json['id']}',
      title: json['title']?.toString() ?? 'Institutional Service Contract',
      department: json['department']?.toString() ?? 'Dept of Cooperation, Govt of Odisha',
      district: json['district']?.toString() ?? 'Khordha',
      estimatedValue: double.tryParse(json['estimated_value']?.toString() ?? '500000') ?? 500000.0,
      submissionDeadline: json['submission_deadline']?.toString() ?? '2026-10-15',
      status: json['status']?.toString() ?? 'OPEN',
      description: json['description']?.toString() ?? '',
      tradesRequired: int.tryParse(json['trades_required']?.toString() ?? '15') ?? 15,
    );
  }
}
