class WorkerModel {
  final int id;
  final int userId;
  final String name;
  final String? email;
  final String? phone;
  final int? cooperativeId;
  final String? cooperativeName;
  final String district;
  final String city;
  final String primaryTrade;
  final int experienceYears;
  final double hourlyRate;
  final double rating;
  final int totalReviews;
  final int completedJobs;
  final String verificationStatus; // 'VERIFIED', 'PENDING', 'REJECTED'
  final String toolkitCompliance; // 'VERIFIED_EQUIPPED', 'PENDING'
  final String availability; // 'AVAILABLE', 'BUSY', 'OFFLINE'
  final List<String> skills;
  final List<dynamic> certifications;
  final double? matchScore; // Calculated during Smart Matching
  final double? distanceKm;

  WorkerModel({
    required this.id,
    required this.userId,
    required this.name,
    this.email,
    this.phone,
    this.cooperativeId,
    this.cooperativeName,
    required this.district,
    required this.city,
    required this.primaryTrade,
    required this.experienceYears,
    required this.hourlyRate,
    required this.rating,
    required this.totalReviews,
    required this.completedJobs,
    required this.verificationStatus,
    this.toolkitCompliance = 'PENDING',
    required this.availability,
    this.skills = const [],
    this.certifications = const [],
    this.matchScore,
    this.distanceKm,
  });

  bool get isVerified => verificationStatus.toUpperCase() == 'VERIFIED';
  bool get isToolkitEquipped => toolkitCompliance.toUpperCase() == 'VERIFIED_EQUIPPED';
  bool get isAvailable => availability.toUpperCase() == 'AVAILABLE';
  bool get canWork => isVerified && isToolkitEquipped;

  factory WorkerModel.fromJson(Map<String, dynamic> json) {
    List<String> parsedSkills = [];
    if (json['skills'] is List) {
      parsedSkills = (json['skills'] as List).map((e) => e.toString()).toList();
    } else if (json['skills'] is String) {
      parsedSkills = (json['skills'] as String).split(',').map((e) => e.trim()).toList();
    }

    return WorkerModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      userId: json['user_id'] is int ? json['user_id'] : int.tryParse(json['user_id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? 'Artisan',
      email: json['email']?.toString(),
      phone: json['phone']?.toString(),
      cooperativeId: json['cooperative_id'] != null ? int.tryParse(json['cooperative_id'].toString()) : null,
      cooperativeName: json['cooperative_name']?.toString() ?? 'District Labour Cooperative',
      district: json['district']?.toString() ?? 'Khordha',
      city: json['city']?.toString() ?? 'Bhubaneswar',
      primaryTrade: json['primary_trade']?.toString() ?? 'General',
      experienceYears: int.tryParse(json['experience_years']?.toString() ?? '0') ?? 0,
      hourlyRate: double.tryParse(json['hourly_rate']?.toString() ?? '200') ?? 200.0,
      rating: double.tryParse(json['rating']?.toString() ?? '4.8') ?? 4.8,
      totalReviews: int.tryParse(json['total_reviews']?.toString() ?? '0') ?? 0,
      completedJobs: int.tryParse(json['completed_jobs']?.toString() ?? '0') ?? 0,
      verificationStatus: json['verification_status']?.toString() ?? 'PENDING',
      toolkitCompliance: json['toolkit_compliance']?.toString() ?? 'PENDING',
      availability: json['availability']?.toString() ?? 'AVAILABLE',
      skills: parsedSkills,
      certifications: json['certifications'] is List ? json['certifications'] : [],
      matchScore: json['matchScore'] != null ? double.tryParse(json['matchScore'].toString()) : null,
      distanceKm: json['distanceKm'] != null ? double.tryParse(json['distanceKm'].toString()) : null,
    );
  }
}
