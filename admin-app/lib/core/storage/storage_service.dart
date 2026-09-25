import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/user_model.dart';
import '../constants/api_endpoints.dart';

class StorageService {
  static late SharedPreferences _prefs;

  static const String _keyToken = 'admin_auth_token';
  static const String _keyUser = 'admin_auth_user';
  static const String _keyCustomBaseUrl = 'admin_custom_base_url';

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    final customUrl = _prefs.getString(_keyCustomBaseUrl);
    if (customUrl != null && customUrl.isNotEmpty) {
      ApiEndpoints.setBaseUrl(customUrl);
    }
  }

  // Auth Token
  static Future<void> saveToken(String token) async {
    await _prefs.setString(_keyToken, token);
  }

  static String? getToken() {
    return _prefs.getString(_keyToken);
  }

  static bool hasToken() {
    final token = getToken();
    return token != null && token.isNotEmpty;
  }

  // User
  static Future<void> saveUser(UserModel user) async {
    await _prefs.setString(_keyUser, jsonEncode(user.toJson()));
  }

  static UserModel? getUser() {
    final userStr = _prefs.getString(_keyUser);
    if (userStr == null || userStr.isEmpty) return null;
    try {
      return UserModel.fromJson(jsonDecode(userStr));
    } catch (_) {
      return null;
    }
  }

  // Clear Auth
  static Future<void> clearAuth() async {
    await _prefs.remove(_keyToken);
    await _prefs.remove(_keyUser);
  }

  // Base URL
  static Future<void> saveCustomBaseUrl(String url) async {
    await _prefs.setString(_keyCustomBaseUrl, url);
    ApiEndpoints.setBaseUrl(url);
  }

  static String? getCustomBaseUrl() {
    return _prefs.getString(_keyCustomBaseUrl);
  }
}
