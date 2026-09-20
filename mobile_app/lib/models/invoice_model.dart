class InvoiceModel {
  final String invoiceNumber;
  final int bookingId;
  final String bookingCode;
  final String date;
  final String customerName;
  final String customerAddress;
  final String? customerPhone;
  final String workerName;
  final String workerTrade;
  final String? workerPhone;
  final String serviceName;
  final double basePrice;
  final double workerWage; // 93%
  final double cooperativeWelfare; // 5%
  final double platformFee; // 2%
  final double partsTotal;
  final double totalAmount;
  final String paymentStatus;
  final String? transactionId;
  final String? paymentMethod;
  final String? qrPayload;

  InvoiceModel({
    required this.invoiceNumber,
    required this.bookingId,
    required this.bookingCode,
    required this.date,
    required this.customerName,
    required this.customerAddress,
    this.customerPhone,
    required this.workerName,
    required this.workerTrade,
    this.workerPhone,
    required this.serviceName,
    required this.basePrice,
    required this.workerWage,
    required this.cooperativeWelfare,
    required this.platformFee,
    required this.partsTotal,
    required this.totalAmount,
    required this.paymentStatus,
    this.transactionId,
    this.paymentMethod,
    this.qrPayload,
  });

  factory InvoiceModel.fromJson(Map<String, dynamic> json) {
    final base = double.tryParse(json['amount']?.toString() ?? '0') ?? 0.0;
    final total = double.tryParse(json['total_amount']?.toString() ?? '0') ?? base;

    return InvoiceModel(
      invoiceNumber: json['invoice_number']?.toString() ?? 'INV-OD-${json['booking_id'] ?? '2026'}',
      bookingId: json['booking_id'] is int ? json['booking_id'] : int.tryParse(json['booking_id']?.toString() ?? '0') ?? 0,
      bookingCode: json['booking_code']?.toString() ?? 'BK-OD-2026',
      date: json['date']?.toString() ?? DateTime.now().toString().split(' ')[0],
      customerName: json['customer_name']?.toString() ?? 'Citizen',
      customerAddress: json['location_address']?.toString() ?? 'Bhubaneswar, Odisha',
      customerPhone: json['customer_phone']?.toString(),
      workerName: json['worker_name']?.toString() ?? 'Verified Artisan',
      workerTrade: json['worker_trade']?.toString() ?? 'Cooperative Specialist',
      workerPhone: json['worker_phone']?.toString(),
      serviceName: json['service_name']?.toString() ?? 'Service',
      basePrice: base,
      workerWage: double.tryParse(json['worker_take_home']?.toString() ?? (base * 0.93).toStringAsFixed(2)) ?? (base * 0.93),
      cooperativeWelfare: double.tryParse(json['cooperative_fee']?.toString() ?? (base * 0.05).toStringAsFixed(2)) ?? (base * 0.05),
      platformFee: double.tryParse(json['platform_fee']?.toString() ?? (base * 0.02).toStringAsFixed(2)) ?? (base * 0.02),
      partsTotal: double.tryParse(json['parts_total']?.toString() ?? '0') ?? 0.0,
      totalAmount: total,
      paymentStatus: json['payment_status']?.toString().toUpperCase() ?? 'PAID',
      transactionId: json['transaction_id']?.toString() ?? 'TXN-DEMO-${DateTime.now().millisecondsSinceEpoch}',
      paymentMethod: json['payment_method']?.toString() ?? 'UPI',
      qrPayload: json['qr_payload']?.toString() ?? 'PRITHVI-FIX-INVOICE:FORM-IV:ODISHA-COOP',
    );
  }
}

class ReviewModel {
  final int id;
  final int bookingId;
  final int workerId;
  final String workerName;
  final String customerName;
  final int rating;
  final String comment;
  final List<String> tags;
  final String createdAt;

  ReviewModel({
    required this.id,
    required this.bookingId,
    required this.workerId,
    required this.workerName,
    required this.customerName,
    required this.rating,
    required this.comment,
    this.tags = const [],
    required this.createdAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    List<String> parsedTags = [];
    if (json['tags'] is List) {
      parsedTags = (json['tags'] as List).map((e) => e.toString()).toList();
    }

    return ReviewModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      bookingId: json['booking_id'] is int ? json['booking_id'] : int.tryParse(json['booking_id']?.toString() ?? '0') ?? 0,
      workerId: json['worker_id'] is int ? json['worker_id'] : int.tryParse(json['worker_id']?.toString() ?? '0') ?? 0,
      workerName: json['worker_name']?.toString() ?? 'Artisan',
      customerName: json['customer_name']?.toString() ?? 'Citizen',
      rating: int.tryParse(json['rating']?.toString() ?? '5') ?? 5,
      comment: json['comment']?.toString() ?? '',
      tags: parsedTags,
      createdAt: json['created_at']?.toString() ?? '',
    );
  }
}
