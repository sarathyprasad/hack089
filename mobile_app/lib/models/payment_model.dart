class PaymentModel {
  final int id;
  final int bookingId;
  final double amount;
  final String method; // UPI, CARD, NETBANKING, CASH
  final String status; // PENDING, PAID, FAILED, REFUNDED
  final String? transactionId;
  final String? upiId;
  final DateTime? paidAt;
  final double workerShare; // 93%
  final double welfareShare; // 2%
  final double platformShare; // 5%

  PaymentModel({
    required this.id,
    required this.bookingId,
    required this.amount,
    required this.method,
    required this.status,
    this.transactionId,
    this.upiId,
    this.paidAt,
    this.workerShare = 0,
    this.welfareShare = 0,
    this.platformShare = 0,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id'] ?? json['payment_id'] ?? 0,
      bookingId: json['booking_id'] ?? json['bookingId'] ?? 0,
      amount: double.tryParse(json['amount']?.toString() ?? '0') ?? 0,
      method: json['method']?.toString().toUpperCase() ?? 'UPI',
      status: json['status']?.toString().toUpperCase() ?? 'PENDING',
      transactionId: json['transaction_id'] ?? json['transactionId'],
      upiId: json['upi_id'] ?? json['upiId'],
      paidAt: json['paid_at'] != null ? DateTime.tryParse(json['paid_at'].toString()) : null,
      workerShare: double.tryParse(json['worker_share']?.toString() ?? '0') ?? 0,
      welfareShare: double.tryParse(json['welfare_share']?.toString() ?? '0') ?? 0,
      platformShare: double.tryParse(json['platform_share']?.toString() ?? '0') ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'booking_id': bookingId,
        'amount': amount,
        'method': method,
        'status': status,
        'transaction_id': transactionId,
        'upi_id': upiId,
        'paid_at': paidAt?.toIso8601String(),
        'worker_share': workerShare,
        'welfare_share': welfareShare,
        'platform_share': platformShare,
      };

  bool get isPaid => status == 'PAID';
  bool get isPending => status == 'PENDING';
  String get formattedAmount => '₹${amount.toStringAsFixed(0)}';
}
