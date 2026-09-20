import 'package:flutter/foundation.dart';

class ApiEndpoints {
  // Default base URL depending on platform
  static String get defaultBaseUrl {
    if (kIsWeb ||
        defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.linux) {
      return 'http://localhost:5000/api';
    }
    // Android emulator alias for host localhost
    return 'http://10.0.2.2:5000/api';
  }

  // Active Base URL (can be customized via in-app Settings / Developer drawer)
  static String activeBaseUrl = defaultBaseUrl;

  static void setBaseUrl(String url) {
    if (url.endsWith('/')) {
      activeBaseUrl = url.substring(0, url.length - 1);
    } else {
      activeBaseUrl = url;
    }
  }

  // Authentication
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String me = '/auth/me';

  // Public Catalog & Workers
  static const String services = '/services';
  static const String serviceLocations = '/services/locations';
  static const String workers = '/workers';
  static const String matchRecommend = '/matching/recommend';

  // Bookings & Lifecycle
  static const String bookings = '/bookings';
  static String bookingDetail(int id) => '/bookings/$id';
  static String updateBookingStatus(int id) => '/bookings/$id/status';
  static String cancelBooking(int id) => '/bookings/$id/cancel';
  static String verifyArrivalOtp(int id) => '/bookings/$id/verify-arrival-otp';
  static String verifyCompletionOtp(int id) => '/bookings/$id/verify-completion-otp';
  static String uploadPhotoProof(int id) => '/bookings/$id/photo-proof';
  static String addParts(int id) => '/bookings/$id/add-parts';
  static String claimGuarantee(int id) => '/bookings/$id/claim-guarantee';

  // Worker Portal
  static const String workerDashboard = '/worker-portal/dashboard';
  static const String workerAvailability = '/worker-portal/availability';
  static String workerJobAction(int id) => '/worker-portal/jobs/$id/action';
  static const String workerWelfare = '/worker-portal/welfare';
  static const String workerWelfareEnroll = '/worker-portal/welfare/enroll';

  // Cooperative Admin & Governance
  static const String adminDashboard = '/admin/dashboard';
  static const String adminWorkers = '/admin/workers';
  static String adminVerifyWorker(int id) => '/admin/workers/$id/verify';
  static const String adminBookings = '/admin/bookings';

  // Smart Features & AI Demand Forecast
  static const String demandForecast = '/smart-features/forecast';
  static const String workforceAllocation = '/smart-features/allocation';
  static String approveMutualAid(int id) => '/smart-features/mutual-aid/$id/approve';
  static const String aiChat = '/smart-features/ai-chat';

  // Payments & Reviews
  static const String processPayment = '/payments/process';
  static String getInvoice(int id) => '/payments/invoice/$id';
  static const String reviews = '/reviews';
  static String workerReviews(int id) => '/reviews/worker/$id';
  static const String featuredReviews = '/reviews/featured';

  // Governance & Lineage
  static const String partsCatalog = '/governance/parts-catalog';
  static const String sos = '/governance/sos';
  static const String sosAlerts = '/governance/sos-alerts';
  static const String liveMap = '/governance/live-map';
  static const String disputes = '/governance/disputes';
  static String resolveDispute(int id) => '/governance/disputes/$id/resolve';
  static const String applianceLineage = '/governance/appliance-lineage';

  // Societies & Federation
  static const String societiesRegister = '/societies/register';
  static String societyTrack(String trackingId) => '/societies/track/$trackingId';
  static const String societiesList = '/societies';
  static String societyTimeline(int id) => '/societies/$id/timeline';

  static const String federationAdminDashboard = '/federation/admin-dashboard';
  static const String federationTreasurerDashboard = '/federation/treasurer-dashboard';
  static const String federationApplyNcct = '/federation/ncct/apply';
  static const String federationTenders = '/federation/tenders';
  static const String federationWorkerRegister = '/federation/workers/register';

  // Stats & Localization
  static const String dbStats = '/db/stats';
  static const String localizationLanguages = '/localization/languages';
  static String localizationDict(String lang) => '/localization/$lang';
}
