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
  static const String me = '/auth/me';

  // Admin Core
  static const String dashboard = '/admin/dashboard';
  static const String workers = '/admin/workers';
  static String verifyWorker(int id) => '/admin/workers/$id/verify';
  static const String bookings = '/admin/bookings';
  static const String auditLogs = '/admin/audit-logs';

  // Federation & Apex
  static const String federationOverview = '/societies/federation-overview';
  static const String federations = '/societies/federations';
  static const String districts = '/societies/districts';
  static String toggleDistrict(int id) => '/societies/districts/$id/toggle';
  static const String federationAdminDashboard = '/federation/admin-dashboard';
  static const String treasurerDashboard = '/federation/treasurer-dashboard';
  static const String tenders = '/federation/tenders';
  static const String ncctApply = '/federation/ncct/apply';
  static const String federationRegisterWorker = '/federation/workers/register';

  // Societies
  static const String societies = '/societies';
  static const String registerSociety = '/societies/register';
  static String trackSociety(String trackingId) => '/societies/track/$trackingId';
  static const String pendingDco = '/societies/pending/dco';
  static String dcoReview(int id) => '/societies/$id/dco-review';
  static String updateTimeline(int id) => '/societies/$id/timeline';
  static String updateAudit(int id) => '/societies/$id/audit';
  static String updateGovernance(int id) => '/societies/$id/governance';
  static const String societyInquiries = '/societies/inquiries';

  // Smart Features & AI Forecasting
  static const String forecast = '/smart-features/forecast';
  static const String workforceAllocation = '/smart-features/allocation';
  static String approveMutualAid(String id) => '/smart-features/mutual-aid/$id/approve';

  // Governance & SOS Alerts
  static const String sosAlerts = '/governance/sos-alerts';
  static const String liveMap = '/governance/live-map';
  static const String disputes = '/governance/disputes';
  static String resolveDispute(int id) => '/governance/disputes/$id/resolve';
}
