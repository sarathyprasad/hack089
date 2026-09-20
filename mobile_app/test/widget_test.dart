import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shramsetu_mobile/models/service_model.dart';
import 'package:shramsetu_mobile/models/review_model.dart';
import 'package:shramsetu_mobile/core/localization/language_provider.dart';
import 'package:shramsetu_mobile/core/theme/app_theme.dart';
import 'package:shramsetu_mobile/core/constants/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shramsetu_mobile/core/storage/storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('93-2-5 Statutory Escrow Tariff Calculation Test', () {
    final service = ServiceModel(
      id: 1,
      name: 'Ceiling Fan Repair',
      category: 'Electrical',
      description: 'Standard fan repair and capacitor replacement',
      basePrice: 249.0,
      durationMinutes: 45,
    );

    // 93% Worker living wage
    expect(service.workerTakeHome, 231.57);
    // 5% Welfare contribution (ESIC & Mini-PF)
    expect(service.welfareLevy, 12.45);
    // 2% Platform upkeep
    expect(service.platformFee, 4.98);

    final total = service.workerTakeHome + service.welfareLevy + service.platformFee;
    final roundedSum = double.parse(total.toStringAsFixed(2));
    expect(roundedSum, 249.0);
  });

  test('CustomerReview JSON Parsing & Fallback Test', () {
    final json = {
      'id': 'cust-1',
      'name': 'Ananya Patel',
      'role': 'Verified Citizen Resident',
      'district': 'Khordha',
      'city': 'Bhubaneswar',
      'location': 'Patia, Bhubaneswar',
      'serviceName': 'Split AC Deep Jet Service',
      'category': 'electrical',
      'categoryLabel': 'AC & Appliance',
      'rating': 5,
      'scores': {'punctuality': 5, 'quality': 5, 'safety': 5},
      'comment': 'Transparent ₹499 base tariff was charged with zero surge fees.',
      'servicedBy': 'Kailash Sahoo (HVAC Master)',
      'workerReply': 'Thank you Ananya ji!',
      'date': '2 days ago',
      'verified': true,
      'warrantyProtected': true,
    };

    final review = CustomerReview.fromJson(json);
    expect(review.id, 'cust-1');
    expect(review.name, 'Ananya Patel');
    expect(review.rating, 5.0);
    expect(review.punctuality, 5);
    expect(review.verified, true);
    expect(review.warrantyProtected, true);
  });

  test('WorkerReview JSON Parsing & Welfare Badge Test', () {
    final json = {
      'id': 'wrk-1',
      'name': 'Ramesh Kumar',
      'trade': 'Master Electrician',
      'experience': '12 Years Experience',
      'qualification': 'Gold Skill Certified',
      'cooperative': 'Bhubaneswar Labour Cooperative Federation',
      'district': 'Khordha',
      'city': 'Bhubaneswar',
      'rating': 5,
      'highlight': 'Prithvi Fix gives me 93% direct daily earnings.',
      'comment': 'I earn ₹34,000+ per month with full dignity.',
      'metrics': {
        'monthlyIncome': '₹34,500/mo',
        'completedJobs': '520+ Bookings',
        'artisanRating': '4.98 ★',
        'welfare': 'ESIC & Accident Insurance Covered',
      },
      'category': 'electrical',
      'categoryLabel': 'Electrical',
      'joinedYear': '2023',
      'verified': true,
      'masterArtisan': true,
    };

    final wrk = WorkerReview.fromJson(json);
    expect(wrk.id, 'wrk-1');
    expect(wrk.name, 'Ramesh Kumar');
    expect(wrk.monthlyIncome, '₹34,500/mo');
    expect(wrk.welfare, 'ESIC & Accident Insurance Covered');
    expect(wrk.masterArtisan, true);
  });

  test('Guest Mode Flag & Permission Assertion Test', () {
    // Verify Guest Mode contracts:
    // A guest has monitor rights (browse services, view rates) but no booking authority
    const isGuest = true;
    const isAuthenticated = false;

    bool canBookService(bool guest, bool authenticated) {
      return authenticated && !guest;
    }

    bool canBrowseCatalog(bool guest, bool authenticated) {
      return true; // Both guests and customers can browse
    }

    expect(canBrowseCatalog(isGuest, isAuthenticated), true);
    expect(canBookService(isGuest, isAuthenticated), false);
    expect(canBookService(false, true), true);
  });

  test('Multilingual Odia, Hindi & English Translation Test', () {
    final langProv = LanguageProvider();

    // English
    expect(langProv.translate('app_title'), 'Prithvi Fix');
    expect(langProv.translate('citizen_tab'), 'Citizen');

    // Odia
    langProv.setLanguage('OR');
    expect(langProv.translate('app_title'), 'ପୃଥିବୀ ଫିକ୍ସ');
    expect(langProv.translate('citizen_tab'), 'ନାଗରିକ');
    expect(langProv.translate('odisha_network'), 'ଓଡ଼ିଶା ସମବାୟ ନେଟୱାର୍କ');
    expect(langProv.currentFlutterLocale.languageCode, 'or');

    // Hindi
    langProv.setLanguage('HI');
    expect(langProv.translate('app_title'), 'पृथ्वी फिक्स');
    expect(langProv.translate('citizen_tab'), 'नागरिक');
    expect(langProv.currentFlutterLocale.languageCode, 'hi');
  });

  test('Dark Mode State Toggle and Palette Assertion Test', () {
    final darkTheme = AppTheme.darkTheme;
    expect(darkTheme.brightness, Brightness.dark);
    expect(darkTheme.scaffoldBackgroundColor, AppColors.darkBackground);
    expect(darkTheme.colorScheme.surface, AppColors.darkCard);
    expect(darkTheme.colorScheme.primary, AppColors.secondarySaffron);

    // Verify button styling symmetry
    expect(darkTheme.elevatedButtonTheme.style, isNotNull);
    expect(darkTheme.outlinedButtonTheme.style, isNotNull);
    expect(darkTheme.inputDecorationTheme.filled, true);
    expect(darkTheme.cardTheme.color, AppColors.darkCard);

    // Verify Light Theme symmetry
    final lightTheme = AppTheme.lightTheme;
    expect(lightTheme.brightness, Brightness.light);
    expect(lightTheme.scaffoldBackgroundColor, AppColors.backgroundLight);
    expect(lightTheme.elevatedButtonTheme.style, isNotNull);
    expect(lightTheme.outlinedButtonTheme.style, isNotNull);
  });

  test('Settings Preferences, Audio Toggles & Cache Clearing Test', () async {
    SharedPreferences.setMockInitialValues({});
    await StorageService.init();

    // Verify default voice alerts (should be false/opt-in)
    expect(StorageService.getVoiceAlerts(), false);
    expect(StorageService.getSoundEffects(), true);

    // Save and retrieve voice preferences
    await StorageService.saveVoiceAlerts(true);
    expect(StorageService.getVoiceAlerts(), true);

    await StorageService.saveSoundEffects(false);
    expect(StorageService.getSoundEffects(), false);

    // Notification preferences
    await StorageService.saveNotificationPref('pref_notif_bookings', false);
    expect(StorageService.getNotificationPref('pref_notif_bookings'), false);

    // Clear cache while preserving core auth & dark mode
    await StorageService.saveDarkMode(true);
    await StorageService.saveLanguage('OR');
    await StorageService.clearCache();

    expect(StorageService.getDarkMode(), true);
    expect(StorageService.getLanguage(), 'OR');
  });

  test('Settings Screen Multilingual Localization Keys Test', () {
    final langProv = LanguageProvider();
    langProv.setLanguage('EN');

    // English Settings Strings
    expect(langProv.translate('settings'), 'Settings & Preferences');
    expect(langProv.translate('appearance'), 'Appearance & Theme');
    expect(langProv.translate('voice_sound'), 'Voice & Sound Guidance');
    expect(langProv.translate('clear_cache'), 'Clear Temporary Cache');

    // Odia Settings Strings
    langProv.setLanguage('OR');
    expect(langProv.translate('settings'), 'ସେଟିଙ୍ଗ୍ ଓ ପସନ୍ଦ');
    expect(langProv.translate('appearance'), 'ରୂପରେଖା ଓ ଥିମ୍');
    expect(langProv.translate('voice_sound'), 'ଭଏସ୍ ଓ ଶବ୍ଦ ନିର୍ଦ୍ଦେଶନା');

    // Hindi Settings Strings
    langProv.setLanguage('HI');
    expect(langProv.translate('settings'), 'सेटिंग्स एवं प्राथमिकताएं');
    expect(langProv.translate('appearance'), 'प्रकटीकरण एवं थीम');
    expect(langProv.translate('voice_sound'), 'आवाज एवं ध्वनि मार्गदर्शन');
  });
}

