import 'package:flutter/foundation.dart';

class ApiEndpoints {
  static String get defaultBaseUrl {
    if (kIsWeb ||
        defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.linux) {
      return 'http://localhost:5000/api';
    }
    // Default to host machine Wi-Fi IP for seamless physical phone & emulator access
    return 'http://192.168.5.37:5000/api';
  }

  static String activeBaseUrl = defaultBaseUrl;

  static void setBaseUrl(String url) {
    activeBaseUrl = url.endsWith('/') ? url.substring(0, url.length - 1) : url;
  }

  // Auth
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String me = '/auth/me';

  // Services
  static const String services = '/services';
  static const String serviceLocations = '/services/locations';
  static String serviceDetail(int id) => '/services/$id';

  // Workers
  static const String workers = '/workers';
  static String workerDetail(int id) => '/workers/$id';
  static const String matchRecommend = '/matching/recommend';

  // Bookings
  static const String bookings = '/bookings';
  static String bookingDetail(int id) => '/bookings/$id';
  static String cancelBooking(int id) => '/bookings/$id/cancel';
  static String verifyArrivalOtp(int id) => '/bookings/$id/verify-arrival-otp';
  static String verifyCompletionOtp(int id) => '/bookings/$id/verify-completion-otp';
  static String claimGuarantee(int id) => '/bookings/$id/claim-guarantee';

  // Payments & Reviews
  static const String processPayment = '/payments/process';
  static String getInvoice(int id) => '/payments/invoice/$id';
  static const String reviews = '/reviews';
  static String workerReviews(int id) => '/reviews/worker/$id';
  static const String featuredReviews = '/reviews/featured';

  // Governance
  static const String disputes = '/governance/disputes';
  static const String applianceLineage = '/governance/appliance-lineage';

  // AI Chat & Diagnostics
  static const String aiChat = '/smart-features/ai-chat';
  static const String aiDiagnoseImage = '/smart-features/ai-diagnose-image';

  // Stats
  static const String dbStats = '/db/stats';
}
