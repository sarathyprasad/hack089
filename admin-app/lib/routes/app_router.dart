import 'package:go_router/go_router.dart';
import '../views/login_screen.dart';
import '../views/command_dashboard_screen.dart';
import '../views/federation_overview_screen.dart';
import '../views/apex_dashboard_screen.dart';
import '../views/society_operations_screen.dart';
import '../views/society_registration_screen.dart';
import '../views/society_timeline_screen.dart';
import '../views/institutional_tenders_screen.dart';
import '../views/live_monitoring_screen.dart';
import '../views/dispute_resolution_screen.dart';
import '../views/tariff_admin_screen.dart';
import '../views/escrow_settlement_screen.dart';
import '../views/agm_governance_screen.dart';
import '../views/bulk_inventory_screen.dart';
import '../core/storage/storage_service.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final token = StorageService.getToken();
      final path = state.uri.path;
      if (token == null && path != '/login') return '/login';
      if (token != null && path == '/login') return '/';
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/', builder: (context, state) => const CommandDashboardScreen()),
      GoRoute(path: '/federation', builder: (context, state) => const FederationOverviewScreen()),
      GoRoute(path: '/apex', builder: (context, state) => const ApexDashboardScreen()),
      GoRoute(path: '/society-operations', builder: (context, state) => const SocietyOperationsScreen()),
      GoRoute(path: '/society-registration', builder: (context, state) => const SocietyRegistrationScreen()),
      GoRoute(
        path: '/society-timeline',
        builder: (context, state) {
          final idParam = state.uri.queryParameters['id'];
          final id = idParam != null ? int.tryParse(idParam) : null;
          return SocietyTimelineScreen(initialSocietyId: id);
        },
      ),
      GoRoute(path: '/tenders', builder: (context, state) => const InstitutionalTendersScreen()),
      GoRoute(path: '/monitoring', builder: (context, state) => const LiveMonitoringScreen()),
      GoRoute(path: '/disputes', builder: (context, state) => const DisputeResolutionScreen()),
      GoRoute(path: '/tariffs', builder: (context, state) => const TariffAdminScreen()),
      GoRoute(path: '/escrow', builder: (context, state) => const EscrowSettlementScreen()),
      GoRoute(path: '/agm', builder: (context, state) => const AgmGovernanceScreen()),
      GoRoute(path: '/inventory', builder: (context, state) => const BulkInventoryScreen()),
    ],
  );
}
