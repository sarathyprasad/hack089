import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../views/splash_screen.dart';
import '../views/login_screen.dart';
import '../views/dashboard_screen.dart';
import '../views/job_detail_screen.dart';
import '../views/earnings_screen.dart';
import '../views/welfare_screen.dart';
import '../views/profile_screen.dart';
import '../views/skills_training_screen.dart';
import '../views/demand_heatmap_screen.dart';
import '../views/payout_wallet_screen.dart';
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
      // Don't redirect splash screen
      if (path == '/') return null;
      if (token == null && path != '/login') return '/login';
      if (token != null && path == '/login') return '/dashboard';
      return null;
    },
    routes: [
      // Splash / Boot screen
      GoRoute(
        path: '/',
        pageBuilder: (context, state) => CustomTransitionPage<void>(
          key: state.pageKey,
          child: const WorkerSplashScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              FadeTransition(opacity: animation, child: child),
        ),
      ),
      GoRoute(
        path: '/login',
        pageBuilder: (context, state) => _buildPageTransition(
          context: context, state: state, child: const LoginScreen(),
        ),
      ),
      GoRoute(
        path: '/dashboard',
        pageBuilder: (context, state) => _buildPageTransition(
          context: context, state: state, child: const DashboardScreen(),
        ),
      ),
      GoRoute(
        path: '/job/:id',
        pageBuilder: (context, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '1') ?? 1;
          return _buildPageTransition(
            context: context, state: state, child: JobDetailScreen(bookingId: id),
          );
        },
      ),
      GoRoute(
        path: '/earnings',
        pageBuilder: (context, state) => _buildPageTransition(
          context: context, state: state, child: const EarningsScreen(),
        ),
      ),
      GoRoute(
        path: '/wallet',
        pageBuilder: (context, state) => _buildPageTransition(
          context: context, state: state, child: const PayoutWalletScreen(),
        ),
      ),
      GoRoute(
        path: '/heatmap',
        pageBuilder: (context, state) => _buildPageTransition(
          context: context, state: state, child: const DemandHeatmapScreen(),
        ),
      ),
      GoRoute(
        path: '/welfare',
        pageBuilder: (context, state) => _buildPageTransition(
          context: context, state: state, child: const WelfareScreen(),
        ),
      ),
      GoRoute(
        path: '/skills',
        pageBuilder: (context, state) => _buildPageTransition(
          context: context, state: state, child: const SkillsTrainingScreen(),
        ),
      ),
      GoRoute(
        path: '/profile',
        pageBuilder: (context, state) => _buildPageTransition(
          context: context, state: state, child: const ProfileScreen(),
        ),
      ),
    ],
  );
}
