import 'package:flutter/foundation.dart';

class ApiEndpoints {
  static String get defaultBaseUrl {
    if (kIsWeb || defaultTargetPlatform == TargetPlatform.windows || defaultTargetPlatform == TargetPlatform.macOS || defaultTargetPlatform == TargetPlatform.linux) {
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
  static const String me = '/auth/me';

  // Worker Portal
  static const String workerDashboard = '/worker-portal/dashboard';
  static const String workerAvailability = '/worker-portal/availability';
  static String workerJobAction(int id) => '/worker-portal/jobs/$id/action';
  static const String workerWelfare = '/worker-portal/welfare';
  static const String workerWelfareEnroll = '/worker-portal/welfare/enroll';
  static const String workerToolkits = '/worker-portal/toolkits';
  static const String workerToolkitOrder = '/worker-portal/toolkits/order';

  // Bookings (worker side)
  static String bookingDetail(int id) => '/bookings/$id';
  static String updateBookingStatus(int id) => '/bookings/$id/status';
  static String verifyArrivalOtp(int id) => '/bookings/$id/verify-arrival-otp';
  static String verifyCompletionOtp(int id) => '/bookings/$id/verify-completion-otp';
  static String addParts(int id) => '/bookings/$id/add-parts';

  // Reviews
  static String workerReviews(int id) => '/reviews/worker/$id';

  // SOS & Governance
  static const String sos = '/governance/sos';
  static const String partsCatalog = '/governance/parts-catalog';
  static const String ncctApply = '/federation/ncct/apply';
}
