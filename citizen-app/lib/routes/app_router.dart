import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../views/splash_screen.dart';
import '../views/home_screen.dart';
import '../views/services_screen.dart';
import '../views/service_detail_screen.dart';
import '../views/find_worker_screen.dart';
import '../views/book_service_screen.dart';
import '../views/my_bookings_screen.dart';
import '../views/booking_detail_screen.dart';
import '../views/rate_card_screen.dart';
import '../views/login_screen.dart';
import '../views/register_screen.dart';
import '../views/appliance_lineage_screen.dart';
import '../views/live_tracking_screen.dart';
import '../views/invoice_detail_screen.dart';
import '../views/saved_addresses_screen.dart';
import '../views/profile_screen.dart';
import '../views/rewards_screen.dart';
import '../views/help_screen.dart';
import '../core/storage/storage_service.dart';

/// Smooth fade + subtle slide page transition for all routes
CustomTransitionPage<void> _buildPageTransition({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 280),
    reverseTransitionDuration: const Duration(milliseconds: 220),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final fadeTween = Tween<double>(begin: 0.0, end: 1.0);
      final slideTween = Tween<Offset>(
        begin: const Offset(0.02, 0.0),
        end: Offset.zero,
      );
      return FadeTransition(
        opacity: fadeTween.animate(
          CurvedAnimation(parent: animation, curve: Curves.easeOut),
        ),
        child: SlideTransition(
          position: slideTween.animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
          ),
          child: child,
        ),
      );
    },
  );
}

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final token = StorageService.getToken();
      final path = state.uri.path;

      // Protected routes require login
      if (token == null && (path.startsWith('/my-bookings') || path == '/book-service' || path.startsWith('/track') || path.startsWith('/invoice') || path == '/addresses' || path == '/profile')) {
        return '/login';
      }
      return null;
    },
    routes: [
      // Splash / Boot screen
      GoRoute(
        path: '/',
        pageBuilder: (context, state) => CustomTransitionPage<void>(
          key: state.pageKey,
          child: const SplashScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              FadeTransition(opacity: animation, child: child),
        ),
      ),
      GoRoute(
        path: '/home',
        pageBuilder: (context, state) => _buildPageTransition(
          context: context, state: state, child: const HomeScreen(),
        ),
      ),
      GoRoute(
        path: '/services',
        pageBuilder: (context, state) => _buildPageTransition(
          context: context, state: state, child: const ServicesScreen(),
        ),
      ),
      GoRoute(
        path: '/services/:id',
        pageBuilder: (context, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '1') ?? 1;
          return _buildPageTransition(
            context: context, state: state, child: ServiceDetailScreen(serviceId: id),
          );
        },
      ),
      GoRoute(
        path: '/find-worker',
        pageBuilder: (context, state) => _buildPageTransition(
          context: context, state: state, child: const FindWorkerScreen(),
        ),
      ),
      GoRoute(
        path: '/book-service',
        pageBuilder: (context, state) {
          final sId = int.tryParse(state.uri.queryParameters['serviceId'] ?? '');
          return _buildPageTransition(
            context: context, state: state, child: BookServiceScreen(initialServiceId: sId),
          );
        },
      ),
      GoRoute(
        path: '/my-bookings',
        pageBuilder: (context, state) => _buildPageTransition(
          context: context, state: state, child: const MyBookingsScreen(),
        ),
      ),
      GoRoute(
        path: '/my-bookings/:id',
        pageBuilder: (context, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '1') ?? 1;
          return _buildPageTransition(
            context: context, state: state, child: BookingDetailScreen(bookingId: id),
          );
        },
      ),
      GoRoute(
        path: '/book',
        pageBuilder: (context, state) {
          final sId = int.tryParse(state.uri.queryParameters['serviceId'] ?? '');
          return _buildPageTransition(
            context: context, state: state, child: BookServiceScreen(initialServiceId: sId),
          );
        },
      ),
      GoRoute(
        path: '/booking/:id',
        pageBuilder: (context, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '1') ?? 1;
          return _buildPageTransition(
            context: context, state: state, child: BookingDetailScreen(bookingId: id),
          );
        },
      ),
      GoRoute(
        path: '/track/:id',
        pageBuilder: (context, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '1') ?? 1;
          return _buildPageTransition(
            context: context, state: state, child: LiveTrackingScreen(bookingId: id),
          );
        },
      ),
      GoRoute(
        path: '/invoice/:id',
        pageBuilder: (context, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '1') ?? 1;
          return _buildPageTransition(
            context: context, state: state, child: InvoiceDetailScreen(bookingId: id),
          );
        },
      ),
      GoRoute(
        path: '/addresses',
        pageBuilder: (context, state) => _buildPageTransition(
          context: context, state: state, child: const SavedAddressesScreen(),
        ),
      ),
      GoRoute(
        path: '/profile',
        pageBuilder: (context, state) => _buildPageTransition(
          context: context, state: state, child: const ProfileScreen(),
        ),
      ),
      GoRoute(
        path: '/rewards',
        pageBuilder: (context, state) => _buildPageTransition(
          context: context, state: state, child: const RewardsScreen(),
        ),
      ),
      GoRoute(
        path: '/help',
        pageBuilder: (context, state) => _buildPageTransition(
          context: context, state: state, child: const HelpScreen(),
        ),
      ),
      GoRoute(
        path: '/lineage',
        pageBuilder: (context, state) => _buildPageTransition(
          context: context, state: state, child: const ApplianceLineageScreen(),
        ),
      ),
      GoRoute(
        path: '/rate-card',
        pageBuilder: (context, state) => _buildPageTransition(
          context: context, state: state, child: const RateCardScreen(),
        ),
      ),
      GoRoute(
        path: '/login',
        pageBuilder: (context, state) => _buildPageTransition(
          context: context, state: state, child: const LoginScreen(),
        ),
      ),
      GoRoute(
        path: '/register',
        pageBuilder: (context, state) => _buildPageTransition(
          context: context, state: state, child: const RegisterScreen(),
        ),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Page Not Found')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('Page not found', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => context.go('/home'),
              child: const Text('Return Home'),
            ),
          ],
        ),
      ),
    ),
  );
}

