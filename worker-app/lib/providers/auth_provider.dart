import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../core/network/api_client.dart';
import '../core/storage/storage_service.dart';
import '../core/constants/api_endpoints.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  AuthProvider() {
    _initializeUser();
  }

  void _initializeUser() {
    final cached = StorageService.getUser();
    final token = StorageService.getToken();
    if (cached != null && token != null) {
      _currentUser = UserModel.fromJson(cached);
      notifyListeners();
    }
    if (token != null) checkAuth();
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await ApiClient().post(ApiEndpoints.login, data: {'email': email.trim(), 'password': password.trim()});
      if (res is Map) {
        final token = res['token']?.toString();
        final userJson = res['user'];
        if (token != null && userJson is Map) {
          final userMap = Map<String, dynamic>.from(userJson);
          final role = userMap['role']?.toString().toUpperCase() ?? '';

          // 🔒 Worker App only accepts WORKER role
          if (role != 'WORKER') {
            _errorMessage = 'This app is for workers only. Citizens and admins have separate apps.';
            _isLoading = false;
            notifyListeners();
            return false;
          }

          await StorageService.saveToken(token);
          await StorageService.saveUser(userMap);
          _currentUser = UserModel.fromJson(userMap);
          _isLoading = false;
          notifyListeners();
          return true;
        }
      }
      throw ApiException('Invalid response');
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> checkAuth() async {
    try {
      final res = await ApiClient().get(ApiEndpoints.me);
      if (res is Map && res['user'] is Map) {
        final userMap = Map<String, dynamic>.from(res['user']);
        await StorageService.saveUser(userMap);
        _currentUser = UserModel.fromJson(userMap);
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> logout() async {
    await StorageService.clearAuth();
    _currentUser = null;
    _errorMessage = null;
    notifyListeners();
  }

  /// 1-Click demo login
  Future<bool> demoLogin() async {
    return await login('ramesh.w@demo.local', 'demo123');
  }
}
