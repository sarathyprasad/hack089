import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../views/public/home_screen.dart';
import '../views/public/services_screen.dart';
import '../views/public/service_detail_screen.dart';
import '../views/public/find_worker_screen.dart';
import '../views/public/rate_card_screen.dart';
import '../views/public/about_screen.dart';
import '../views/public/help_screen.dart';
import '../views/auth/login_screen.dart';
import '../views/auth/register_screen.dart';
import '../views/customer/book_service_screen.dart';
import '../views/customer/customer_bookings_screen.dart';
import '../views/customer/booking_detail_screen.dart';
import '../views/customer/tax_invoice_screen.dart';
import '../views/customer/live_route_map_screen.dart';
import '../views/worker/worker_dashboard_screen.dart';
import '../views/worker/worker_welfare_screen.dart';
import '../views/worker/active_job_detail_screen.dart';
import '../views/federation/society_registration_screen.dart';
import '../views/federation/society_timeline_screen.dart';
import '../views/federation/federation_portal_screen.dart';
import '../views/federation/institutional_tenders_screen.dart';
import '../views/admin/admin_dashboard_screen.dart';
import '../views/auth/welcome_screen.dart';
import '../views/shared/settings_screen.dart';
import '../core/storage/storage_service.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final token = StorageService.getToken();
      final isGuest = StorageService.isGuestMode();
      final path = state.uri.path;

      // Unprotected authentication and gateway routes
      if (path == '/welcome' || path == '/login' || path == '/register') {
        return null;
      }

      // First-open check: if not logged in and not in guest mode, force welcome gateway
      if (token == null && !isGuest) {
        return '/welcome';
      }

      // Guest mode restrictions: block direct workspace access
      if (token == null && isGuest) {
        if (path == '/customer/bookings' ||
            path.startsWith('/worker/') ||
            path.startsWith('/admin/') ||
            path.startsWith('/federation/portal')) {
          return '/login';
        }
      }

      return null;
    },
    routes: [
      // 0. First-Open Gateway
      GoRoute(
        path: '/welcome',
        builder: (context, state) => const WelcomeScreen(),
      ),

      // 1. Public Marketing & Information Routes
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/services',
        builder: (context, state) => const ServicesScreen(),
      ),
      GoRoute(
        path: '/services/:id',
        builder: (context, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '1') ?? 1;
          return ServiceDetailScreen(serviceId: id);
        },
      ),
      GoRoute(
        path: '/find-worker',
        builder: (context, state) => const FindWorkerScreen(),
      ),
      GoRoute(
        path: '/rate-card',
        builder: (context, state) => const RateCardScreen(),
      ),
      GoRoute(
        path: '/about',
        builder: (context, state) => const AboutScreen(),
      ),
      GoRoute(
        path: '/help',
        builder: (context, state) => const HelpScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),

      // 2. Authentication
      GoRoute(
        path: '/login',
        builder: (context, state) {
          final role = state.uri.queryParameters['role'] ?? state.uri.queryParameters['portal'];
          return LoginScreen(initialRole: role);
        },
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),

      // 3. Society Statutory Formation Lifecycle
      GoRoute(
        path: '/society/register',
        builder: (context, state) => const SocietyRegistrationScreen(),
      ),
      GoRoute(
        path: '/society/timeline',
        builder: (context, state) {
          final track = state.uri.queryParameters['track'];
          return SocietyTimelineScreen(initialTrackingId: track);
        },
      ),

      // 4. Citizen / Customer Module
      GoRoute(
        path: '/book-service',
        builder: (context, state) {
          final sId = int.tryParse(state.uri.queryParameters['serviceId'] ?? '');
          final wId = int.tryParse(state.uri.queryParameters['workerId'] ?? '');
          return BookServiceScreen(initialServiceId: sId, initialWorkerId: wId);
        },
      ),
      GoRoute(
        path: '/customer/bookings',
        builder: (context, state) => const CustomerBookingsScreen(),
      ),
      GoRoute(
        path: '/customer/bookings/:id',
        builder: (context, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '1') ?? 1;
          return BookingDetailScreen(bookingId: id);
        },
      ),
      GoRoute(
        path: '/customer/bookings/:id/invoice',
        builder: (context, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '1') ?? 1;
          return TaxInvoiceScreen(bookingId: id);
        },
      ),
      GoRoute(
        path: '/customer/bookings/:id/map',
        builder: (context, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '1') ?? 1;
          return LiveRouteMapScreen(bookingId: id);
        },
      ),

      // 5. Worker Module
      GoRoute(
        path: '/worker/dashboard',
        builder: (context, state) => const WorkerDashboardScreen(),
      ),
      GoRoute(
        path: '/worker/welfare',
        builder: (context, state) => const WorkerWelfareScreen(),
      ),
      GoRoute(
        path: '/worker/jobs/:id',
        builder: (context, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '1') ?? 1;
          return ActiveJobDetailScreen(bookingId: id);
        },
      ),

      // 6. Federation Dual Consoles & Tenders
      GoRoute(
        path: '/federation/portal',
        builder: (context, state) => const FederationPortalScreen(),
      ),
      GoRoute(
        path: '/federation/tenders',
        builder: (context, state) => const InstitutionalTendersScreen(),
      ),

      // 7. Cooperative Admin Board
      GoRoute(
        path: '/admin/dashboard',
        builder: (context, state) => const AdminDashboardScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Page Not Found')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('404 - Requested screen does not exist.', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: const Text('Return to Home'),
            ),
          ],
        ),
      ),
    ),
  );
}
