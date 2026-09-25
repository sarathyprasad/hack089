import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/storage/storage_service.dart';
import 'core/localization/app_localizations.dart';
import 'providers/auth_provider.dart';
import 'providers/locale_provider.dart';
import 'providers/location_provider.dart';
import 'routes/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider(create: (_) => LocationProvider()),
      ],
      child: const CitizenApp(),
    ),
  );
}

class CitizenApp extends StatelessWidget {
  const CitizenApp({super.key});

  @override
  Widget build(BuildContext context) {
    final localeProvider = context.watch<LocaleProvider>();

    return MaterialApp.router(
      title: 'Prithvi Fix — Citizen Services',
      debugShowCheckedModeBanner: false,
      routerConfig: AppRouter.router,
      locale: localeProvider.locale,
      theme: AppTheme.lightTheme.copyWith(
        pageTransitionsTheme: PageTransitionsTheme(
          builders: {
            TargetPlatform.android: const FadeUpwardsPageTransitionsBuilder(),
            TargetPlatform.iOS: const FadeUpwardsPageTransitionsBuilder(),
            TargetPlatform.windows: const FadeUpwardsPageTransitionsBuilder(),
            TargetPlatform.linux: const FadeUpwardsPageTransitionsBuilder(),
            TargetPlatform.macOS: const FadeUpwardsPageTransitionsBuilder(),
          },
        ),
      ),
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLanguages.map((l) => Locale(l['code']!)).toList(),
    );
  }
}
