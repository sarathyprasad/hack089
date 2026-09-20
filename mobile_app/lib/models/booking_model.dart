class BookingModel {
  final int id;
  final String bookingCode;
  final int customerId;
  final String customerName;
  final String? customerPhone;
  final int? workerId;
  final String? workerName;
  final String? workerPhone;
  final String? workerTrade;
  final int serviceId;
  final String serviceName;
  final String category;
  final String scheduledDate;
  final String scheduledTime;
  final String locationAddress;
  final String locationCity;
  final String locationDistrict;
  final String? locationPincode;
  final String status;
  final bool isEmergency;
  final double amount;
  final double cooperativeFee;
  final double platformFee;
  final double totalAmount;
  final String? arrivalOtp;
  final String? completionOtp;
  final bool arrivalOtpVerified;
  final bool completionOtpVerified;
  final String? photoProofBefore;
  final String? photoProofAfter;
  final String? warrantyUntil;
  final List<dynamic> parts;
  final String? notes;
  final String paymentStatus;
  final String createdAt;
  final double? latitude;
  final double? longitude;
  final double? workerLatitude;
  final double? workerLongitude;
  final double? distanceKm;
  final int? etaMinutes;
  final int squadSize;
  final double transitCompensationFee;
  final double workerWageSharePct;
  final double welfareFundSharePct;
  final double platformUpkeepSharePct;

  BookingModel({
    required this.id,
    required this.bookingCode,
    required this.customerId,
    required this.customerName,
    this.customerPhone,
    this.workerId,
    this.workerName,
    this.workerPhone,
    this.workerTrade,
    required this.serviceId,
    required this.serviceName,
    required this.category,
    required this.scheduledDate,
    required this.scheduledTime,
    required this.locationAddress,
    required this.locationCity,
    required this.locationDistrict,
    this.locationPincode,
    required this.status,
    required this.isEmergency,
    required this.amount,
    required this.cooperativeFee,
    required this.platformFee,
    required this.totalAmount,
    this.arrivalOtp,
    this.completionOtp,
    this.arrivalOtpVerified = false,
    this.completionOtpVerified = false,
    this.photoProofBefore,
    this.photoProofAfter,
    this.warrantyUntil,
    this.parts = const [],
    this.notes,
    this.paymentStatus = 'PENDING',
    required this.createdAt,
    this.latitude,
    this.longitude,
    this.workerLatitude,
    this.workerLongitude,
    this.distanceKm,
    this.etaMinutes,
    this.squadSize = 1,
    this.transitCompensationFee = 0.0,
    this.workerWageSharePct = 93.0,
    this.welfareFundSharePct = 5.0,
    this.platformUpkeepSharePct = 2.0,
  });

  bool get isRequested => status == 'REQUESTED';
  bool get isAccepted => status == 'ACCEPTED';
  bool get isInProgress => status == 'IN_PROGRESS';
  bool get isCompleted => status == 'COMPLETED';
  bool get isCancelled => status == 'CANCELLED';
  bool get isPaid => paymentStatus.toUpperCase() == 'PAID';

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      bookingCode: json['booking_code']?.toString() ?? 'BK-OD-${json['id']}',
      customerId: json['customer_id'] is int ? json['customer_id'] : int.tryParse(json['customer_id']?.toString() ?? '0') ?? 0,
      customerName: json['customer_name']?.toString() ?? 'Citizen',
      customerPhone: json['customer_phone']?.toString(),
      workerId: json['worker_id'] != null ? int.tryParse(json['worker_id'].toString()) : null,
      workerName: json['worker_name']?.toString(),
      workerPhone: json['worker_phone']?.toString(),
      workerTrade: json['worker_trade']?.toString() ?? json['primary_trade']?.toString(),
      serviceId: json['service_id'] is int ? json['service_id'] : int.tryParse(json['service_id']?.toString() ?? '0') ?? 0,
      serviceName: json['service_name']?.toString() ?? 'Trade Service',
      category: json['category']?.toString() ?? 'General',
      scheduledDate: json['scheduled_date']?.toString() ?? '',
      scheduledTime: json['scheduled_time']?.toString() ?? '',
      locationAddress: json['location_address']?.toString() ?? '',
      locationCity: json['location_city']?.toString() ?? 'Bhubaneswar',
      locationDistrict: json['location_district']?.toString() ?? 'Khordha',
      locationPincode: json['location_pincode']?.toString(),
      status: json['status']?.toString().toUpperCase() ?? 'REQUESTED',
      isEmergency: json['is_emergency'] == true,
      amount: double.tryParse(json['amount']?.toString() ?? '0') ?? 0.0,
      cooperativeFee: double.tryParse(json['cooperative_fee']?.toString() ?? '0') ?? 0.0,
      platformFee: double.tryParse(json['platform_fee']?.toString() ?? '0') ?? 0.0,
      totalAmount: double.tryParse(json['total_amount']?.toString() ?? '0') ?? 0.0,
      arrivalOtp: json['arrival_otp']?.toString(),
      completionOtp: json['completion_otp']?.toString(),
      arrivalOtpVerified: json['arrival_otp_verified'] == true,
      completionOtpVerified: json['completion_otp_verified'] == true,
      photoProofBefore: json['photo_proof_before']?.toString(),
      photoProofAfter: json['photo_proof_after']?.toString(),
      warrantyUntil: json['warranty_until']?.toString(),
      parts: json['parts'] is List ? json['parts'] : [],
      notes: json['notes']?.toString(),
      paymentStatus: json['payment_status']?.toString().toUpperCase() ?? 'PENDING',
      createdAt: json['created_at']?.toString() ?? '',
      latitude: json['latitude'] != null ? double.tryParse(json['latitude'].toString()) : null,
      longitude: json['longitude'] != null ? double.tryParse(json['longitude'].toString()) : null,
      workerLatitude: json['worker_latitude'] != null ? double.tryParse(json['worker_latitude'].toString()) : null,
      workerLongitude: json['worker_longitude'] != null ? double.tryParse(json['worker_longitude'].toString()) : null,
      distanceKm: json['distance_km'] != null ? double.tryParse(json['distance_km'].toString()) : (json['tracking'] != null && json['tracking']['distanceKm'] != null ? double.tryParse(json['tracking']['distanceKm'].toString()) : null),
      etaMinutes: json['eta_minutes'] != null ? int.tryParse(json['eta_minutes'].toString()) : (json['tracking'] != null && json['tracking']['etaMinutes'] != null ? int.tryParse(json['tracking']['etaMinutes'].toString()) : null),
      squadSize: json['squad_size'] != null ? int.tryParse(json['squad_size'].toString()) ?? 1 : 1,
      transitCompensationFee: double.tryParse(json['transit_compensation_fee']?.toString() ?? '0') ?? 0.0,
      workerWageSharePct: double.tryParse(json['worker_wage_share_pct']?.toString() ?? '93.0') ?? 93.0,
      welfareFundSharePct: double.tryParse(json['welfare_fund_share_pct']?.toString() ?? '5.0') ?? 5.0,
      platformUpkeepSharePct: double.tryParse(json['platform_upkeep_share_pct']?.toString() ?? '2.0') ?? 2.0,
    );
  }
}
