class UserModel {
  final int id;
  final String name;
  final String email;
  final String role; // 'CUSTOMER', 'WORKER', 'COOPERATIVE_ADMIN'
  final String? phone;
  final String? district;
  final String? city;
  final String? address;
  final String? pincode;
  final int? cooperativeId;
  final String? cooperativeName;
  final int? workerId;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.phone,
    this.district,
    this.city,
    this.address,
    this.pincode,
    this.cooperativeId,
    this.cooperativeName,
    this.workerId,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      role: json['role']?.toString().toUpperCase() ?? 'CUSTOMER',
      phone: json['phone']?.toString(),
      district: json['district']?.toString(),
      city: json['city']?.toString(),
      address: json['address']?.toString(),
      pincode: json['pincode']?.toString(),
      cooperativeId: json['cooperative_id'] != null ? int.tryParse(json['cooperative_id'].toString()) : null,
      cooperativeName: json['cooperative_name']?.toString(),
      workerId: json['worker_id'] != null ? int.tryParse(json['worker_id'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'phone': phone,
      'district': district,
      'city': city,
      'address': address,
      'pincode': pincode,
      'cooperative_id': cooperativeId,
      'cooperative_name': cooperativeName,
      'worker_id': workerId,
    };
  }

  bool get isCustomer => role == 'CUSTOMER';
  bool get isWorker => role == 'WORKER';
  bool get isAdmin => role == 'COOPERATIVE_ADMIN';
}
