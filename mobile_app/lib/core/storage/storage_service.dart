import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_endpoints.dart';

class StorageService {
  static const String _keyToken = 'auth_token';
  static const String _keyUser = 'auth_user';
  static const String _keyLanguage = 'app_language';
  static const String _keyHighContrast = 'app_high_contrast';
  static const String _keyServerUrl = 'custom_server_url';
  static const String _keyGuestMode = 'is_guest_mode';

  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    final savedUrl = _prefs?.getString(_keyServerUrl);
    if (savedUrl != null && savedUrl.isNotEmpty) {
      ApiEndpoints.setBaseUrl(savedUrl);
    }
  }

  // Token
  static Future<void> saveToken(String token) async {
    await _prefs?.setString(_keyToken, token);
  }

  static String? getToken() {
    return _prefs?.getString(_keyToken);
  }

  static Future<void> clearToken() async {
    await _prefs?.remove(_keyToken);
  }

  // User
  static Future<void> saveUser(Map<String, dynamic> userMap) async {
    await _prefs?.setString(_keyUser, jsonEncode(userMap));
  }

  static Map<String, dynamic>? getUser() {
    final raw = _prefs?.getString(_keyUser);
    if (raw == null) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  static Future<void> clearUser() async {
    await _prefs?.remove(_keyUser);
  }

  // Full Logout
  static Future<void> clearAuth() async {
    await clearToken();
    await clearUser();
  }

  // Language
  static Future<void> saveLanguage(String langCode) async {
    await _prefs?.setString(_keyLanguage, langCode);
  }

  static String getLanguage() {
    return _prefs?.getString(_keyLanguage) ?? 'EN';
  }

  // High Contrast Mode
  static Future<void> saveHighContrast(bool enabled) async {
    await _prefs?.setBool(_keyHighContrast, enabled);
  }

  static bool getHighContrast() {
    return _prefs?.getBool(_keyHighContrast) ?? false;
  }

  // Dark Mode
  static const String _keyDarkMode = 'app_dark_mode';

  static Future<void> saveDarkMode(bool enabled) async {
    await _prefs?.setBool(_keyDarkMode, enabled);
  }

  static bool getDarkMode() {
    return _prefs?.getBool(_keyDarkMode) ?? false;
  }

  // Custom Server URL
  static Future<void> saveServerUrl(String url) async {
    await _prefs?.setString(_keyServerUrl, url);
    ApiEndpoints.setBaseUrl(url);
  }

  static String getServerUrl() {
    return _prefs?.getString(_keyServerUrl) ?? ApiEndpoints.defaultBaseUrl;
  }

  // Guest Mode
  static Future<void> setGuestMode(bool isGuest) async {
    await _prefs?.setBool(_keyGuestMode, isGuest);
  }

  static bool isGuestMode() {
    return _prefs?.getBool(_keyGuestMode) ?? false;
  }

  static Future<void> clearGuestMode() async {
    await _prefs?.remove(_keyGuestMode);
  }

  // Voice & Sound Preferences
  static const String _keyVoiceAlerts = 'pref_voice_alerts';
  static const String _keySoundEffects = 'pref_sound_effects';
  static const String keyNotifBookings = 'pref_notif_bookings';
  static const String keyNotifEscrow = 'pref_notif_escrow';
  static const String keyNotifSafety = 'pref_notif_safety';

  static Future<void> saveVoiceAlerts(bool enabled) async {
    await _prefs?.setBool(_keyVoiceAlerts, enabled);
  }

  static bool getVoiceAlerts() {
    return _prefs?.getBool(_keyVoiceAlerts) ?? false;
  }

  static Future<void> saveSoundEffects(bool enabled) async {
    await _prefs?.setBool(_keySoundEffects, enabled);
  }

  static bool getSoundEffects() {
    return _prefs?.getBool(_keySoundEffects) ?? true;
  }

  static Future<void> saveNotificationPref(String key, bool enabled) async {
    await _prefs?.setBool(key, enabled);
  }

  static bool getNotificationPref(String key, {bool defaultValue = true}) {
    return _prefs?.getBool(key) ?? defaultValue;
  }

  // Location & Area Preferences
  static const String _keySelectedAreaId = 'prithvifix_selected_area_id';
  static const String _keyUnsupportedLocation = 'prithvifix_unsupported_location';
  static const String _keyUseCurrentLocation = 'prithvifix_use_current_location';

  static Future<void> saveSelectedAreaId(int id) async {
    await _prefs?.setInt(_keySelectedAreaId, id);
  }

  static int getSelectedAreaId({int defaultValue = 1}) {
    return _prefs?.getInt(_keySelectedAreaId) ?? defaultValue;
  }

  static Future<void> saveUnsupportedLocation(Map<String, dynamic>? unsupp) async {
    if (unsupp == null) {
      await _prefs?.remove(_keyUnsupportedLocation);
    } else {
      await _prefs?.setString(_keyUnsupportedLocation, jsonEncode(unsupp));
    }
  }

  static Map<String, dynamic>? getUnsupportedLocation() {
    final raw = _prefs?.getString(_keyUnsupportedLocation);
    if (raw == null) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  static Future<void> saveUseCurrentLocation(bool val) async {
    await _prefs?.setBool(_keyUseCurrentLocation, val);
  }

  static bool getUseCurrentLocation() {
    return _prefs?.getBool(_keyUseCurrentLocation) ?? false;
  }

  // Clear Offline Storage & Cache
  static Future<void> clearCache() async {
    // Preserve core credentials and user identity while purging temporary keys
    final keysToPreserve = {
      _keyToken,
      _keyUser,
      _keyLanguage,
      _keyDarkMode,
      _keyHighContrast,
      _keySelectedAreaId,
      _keyUnsupportedLocation,
      _keyUseCurrentLocation,
    };
    final allKeys = _prefs?.getKeys() ?? <String>{};
    for (final k in allKeys) {
      if (!keysToPreserve.contains(k)) {
        await _prefs?.remove(k);
      }
    }
  }
}
