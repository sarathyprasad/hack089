import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/accessibility_provider.dart';
import 'core/localization/language_provider.dart';
import 'core/storage/storage_service.dart';
import 'providers/auth_provider.dart';
import 'providers/service_provider.dart';
import 'providers/worker_provider.dart';
import 'providers/booking_provider.dart';
import 'providers/worker_portal_provider.dart';
import 'providers/admin_provider.dart';
import 'providers/society_provider.dart';
import 'providers/chat_provider.dart';
import 'providers/review_provider.dart';
import 'providers/location_provider.dart';
import 'routes/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => LocationProvider()),
        ChangeNotifierProvider(create: (_) => AccessibilityProvider()),
        ChangeNotifierProvider(create: (_) => ServiceProvider()),
        ChangeNotifierProvider(create: (_) => WorkerProvider()),
        ChangeNotifierProvider(create: (_) => BookingProvider()),
        ChangeNotifierProvider(create: (_) => WorkerPortalProvider()),
        ChangeNotifierProvider(create: (_) => AdminProvider()),
        ChangeNotifierProvider(create: (_) => SocietyProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => ReviewProvider()),
      ],
      child: const PrithviFixApp(),
    ),
  );
}

class PrithviFixApp extends StatelessWidget {
  const PrithviFixApp({super.key});

  @override
  Widget build(BuildContext context) {
    final accessProv = context.watch<AccessibilityProvider>();
    final langProv = context.watch<LanguageProvider>();

    return MaterialApp.router(
      title: 'Prithvi Fix — Cooperative Gig Platform',
      debugShowCheckedModeBanner: false,
      routerConfig: AppRouter.router,
      locale: langProv.currentFlutterLocale,
      theme: accessProv.highContrast
          ? AppTheme.highContrastTheme
          : AppTheme.lightTheme,
      darkTheme: accessProv.highContrast
          ? AppTheme.highContrastTheme
          : AppTheme.darkTheme,
      themeMode: accessProv.highContrast || accessProv.isDarkMode
          ? ThemeMode.dark
          : ThemeMode.light,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', 'US'),
        Locale('hi', 'IN'),
        Locale('or', 'IN'),
        Locale('bn', 'IN'),
        Locale('te', 'IN'),
      ],
    );
  }
}
