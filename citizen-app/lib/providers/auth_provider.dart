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
  UserModel? get user => _currentUser;
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
    if (token != null) {
      checkAuth();
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await ApiClient().post(
        ApiEndpoints.login,
        data: {'email': email.trim(), 'password': password.trim()},
      );

      if (res is Map) {
        final token = res['token']?.toString();
        final userJson = res['user'];

        if (token != null && userJson is Map) {
          final userMap = Map<String, dynamic>.from(userJson);
          final role = userMap['role']?.toString().toUpperCase() ?? '';

          // 🔒 Citizen App only accepts CUSTOMER role
          if (role != 'CUSTOMER') {
            _errorMessage = 'This app is for citizens only. Workers and admins have separate apps.';
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
      throw ApiException('Invalid response from server');
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(Map<String, dynamic> userData) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await ApiClient().post(ApiEndpoints.register, data: userData);
      if (res is Map) {
        final token = res['token']?.toString();
        final userJson = res['user'];
        if (token != null && userJson is Map) {
          await StorageService.saveToken(token);
          await StorageService.saveUser(Map<String, dynamic>.from(userJson));
          _currentUser = UserModel.fromJson(Map<String, dynamic>.from(userJson));
          _isLoading = false;
          notifyListeners();
          return true;
        }
      }
      return true;
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

  /// 1-Click demo login for evaluation
  Future<bool> demoLogin() async {
    return await login('customer@demo.local', 'demo123');
  }
}
