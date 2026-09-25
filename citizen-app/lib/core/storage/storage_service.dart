import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_endpoints.dart';

class StorageService {
  static const String _keyToken = 'citizen_auth_token';
  static const String _keyUser = 'citizen_auth_user';
  static const String _keyLanguage = 'app_language';
  static const String _keyServerUrl = 'custom_server_url';

  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    final savedUrl = _prefs?.getString(_keyServerUrl);
    if (savedUrl != null && savedUrl.isNotEmpty) {
      ApiEndpoints.setBaseUrl(savedUrl);
    }
  }

  static Future<void> saveToken(String token) async {
    await _prefs?.setString(_keyToken, token);
  }

  static String? getToken() => _prefs?.getString(_keyToken);

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

  static Future<void> clearAuth() async {
    await _prefs?.remove(_keyToken);
    await _prefs?.remove(_keyUser);
  }

  static Future<void> saveLanguage(String langCode) async {
    await _prefs?.setString(_keyLanguage, langCode);
  }

  static String getLanguage() => _prefs?.getString(_keyLanguage) ?? 'EN';

  static const String _keyLocation = 'selected_location_id';

  static Future<void> saveSelectedLocationId(int id) async {
    await _prefs?.setInt(_keyLocation, id);
  }

  static int? getSelectedLocationId() => _prefs?.getInt(_keyLocation);

  static Future<void> saveServerUrl(String url) async {
    await _prefs?.setString(_keyServerUrl, url);
    ApiEndpoints.setBaseUrl(url);
  }

  static String getServerUrl() =>
      _prefs?.getString(_keyServerUrl) ?? ApiEndpoints.defaultBaseUrl;
}
