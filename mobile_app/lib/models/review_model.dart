class CustomerReview {
  final String id;
  final String name;
  final String role;
  final String district;
  final String city;
  final String location;
  final String serviceName;
  final String category;
  final String categoryLabel;
  final double rating;
  final int punctuality;
  final int quality;
  final int safety;
  final String comment;
  final String servicedBy;
  final String? workerReply;
  final String date;
  final bool verified;
  final bool warrantyProtected;

  CustomerReview({
    required this.id,
    required this.name,
    required this.role,
    required this.district,
    required this.city,
    required this.location,
    required this.serviceName,
    required this.category,
    required this.categoryLabel,
    required this.rating,
    required this.punctuality,
    required this.quality,
    required this.safety,
    required this.comment,
    required this.servicedBy,
    this.workerReply,
    required this.date,
    this.verified = true,
    this.warrantyProtected = true,
  });

  factory CustomerReview.fromJson(Map<String, dynamic> json) {
    final scores = json['scores'] as Map<String, dynamic>? ?? {};
    return CustomerReview(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Verified Citizen',
      role: json['role']?.toString() ?? 'Resident',
      district: json['district']?.toString() ?? 'Khordha',
      city: json['city']?.toString() ?? 'Bhubaneswar',
      location: json['location']?.toString() ?? 'Bhubaneswar, Odisha',
      serviceName: json['serviceName']?.toString() ?? 'Trade Service',
      category: json['category']?.toString() ?? 'electrical',
      categoryLabel: json['categoryLabel']?.toString() ?? 'General Trade',
      rating: double.tryParse(json['rating']?.toString() ?? '5') ?? 5.0,
      punctuality: int.tryParse(scores['punctuality']?.toString() ?? '5') ?? 5,
      quality: int.tryParse(scores['quality']?.toString() ?? '5') ?? 5,
      safety: int.tryParse(scores['safety']?.toString() ?? '5') ?? 5,
      comment: json['comment']?.toString() ?? '',
      servicedBy: json['servicedBy']?.toString() ?? 'Assigned Artisan',
      workerReply: json['workerReply']?.toString(),
      date: json['date']?.toString() ?? 'Recently',
      verified: json['verified'] == true,
      warrantyProtected: json['warrantyProtected'] == true,
    );
  }
}

class WorkerReview {
  final String id;
  final String name;
  final String trade;
  final String experience;
  final String qualification;
  final String cooperative;
  final String district;
  final String city;
  final double rating;
  final String highlight;
  final String comment;
  final String monthlyIncome;
  final String completedJobs;
  final String artisanRating;
  final String welfare;
  final String category;
  final String categoryLabel;
  final String joinedYear;
  final bool verified;
  final bool masterArtisan;

  WorkerReview({
    required this.id,
    required this.name,
    required this.trade,
    required this.experience,
    required this.qualification,
    required this.cooperative,
    required this.district,
    required this.city,
    required this.rating,
    required this.highlight,
    required this.comment,
    required this.monthlyIncome,
    required this.completedJobs,
    required this.artisanRating,
    required this.welfare,
    required this.category,
    required this.categoryLabel,
    required this.joinedYear,
    this.verified = true,
    this.masterArtisan = false,
  });

  factory WorkerReview.fromJson(Map<String, dynamic> json) {
    final metrics = json['metrics'] as Map<String, dynamic>? ?? {};
    return WorkerReview(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Artisan Member',
      trade: json['trade']?.toString() ?? 'Technician',
      experience: json['experience']?.toString() ?? '',
      qualification: json['qualification']?.toString() ?? 'Skill Certified',
      cooperative: json['cooperative']?.toString() ?? 'Labour Cooperative Federation',
      district: json['district']?.toString() ?? 'Khordha',
      city: json['city']?.toString() ?? 'Bhubaneswar',
      rating: double.tryParse(json['rating']?.toString() ?? '5') ?? 5.0,
      highlight: json['highlight']?.toString() ?? '',
      comment: json['comment']?.toString() ?? '',
      monthlyIncome: metrics['monthlyIncome']?.toString() ?? '₹30,000+/mo',
      completedJobs: metrics['completedJobs']?.toString() ?? '300+ Bookings',
      artisanRating: metrics['artisanRating']?.toString() ?? '4.9 ★',
      welfare: metrics['welfare']?.toString() ?? 'ESIC & Accident Insurance Covered',
      category: json['category']?.toString() ?? 'electrical',
      categoryLabel: json['categoryLabel']?.toString() ?? 'General Trade',
      joinedYear: json['joinedYear']?.toString() ?? '2023',
      verified: json['verified'] == true,
      masterArtisan: json['masterArtisan'] == true,
    );
  }
}

class ReviewStats {
  final double overallAverageRating;
  final int totalCustomerReviews;
  final String customerSatisfactionRate;
  final String workerSatisfactionRate;
  final int activeArtisans;
  final String livingWageCompliance;
  final String warrantyClaimSuccess;

  ReviewStats({
    required this.overallAverageRating,
    required this.totalCustomerReviews,
    required this.customerSatisfactionRate,
    required this.workerSatisfactionRate,
    required this.activeArtisans,
    required this.livingWageCompliance,
    required this.warrantyClaimSuccess,
  });

  factory ReviewStats.fromJson(Map<String, dynamic> json) {
    return ReviewStats(
      overallAverageRating: double.tryParse(json['overallAverageRating']?.toString() ?? '4.9') ?? 4.9,
      totalCustomerReviews: int.tryParse(json['totalCustomerReviews']?.toString() ?? '4850') ?? 4850,
      customerSatisfactionRate: json['customerSatisfactionRate']?.toString() ?? '99.4%',
      workerSatisfactionRate: json['workerSatisfactionRate']?.toString() ?? '98.6%',
      activeArtisans: int.tryParse(json['activeArtisans']?.toString() ?? '50') ?? 50,
      livingWageCompliance: json['livingWageCompliance']?.toString() ?? '93% Direct Payout (93-2-5 Model)',
      warrantyClaimSuccess: json['warrantyClaimSuccess']?.toString() ?? '100% Free Re-Repair SLA',
    );
  }
}
