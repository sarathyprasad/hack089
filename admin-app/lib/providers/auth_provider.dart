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

  String get roleDisplay {
    final role = _currentUser?.role.toUpperCase() ?? '';
    if (role == 'SUPER_ADMIN') return 'Apex Federation Head';
    if (role == 'COOPERATIVE_ADMIN') return 'District Cooperative Officer (DCO)';
    if (role == 'ADMIN') return 'Cooperative Society Secretary';
    return 'Governance Officer';
  }

  AuthProvider() {
    _initializeUser();
  }

  void _initializeUser() {
    final cached = StorageService.getUser();
    final token = StorageService.getToken();
    if (cached != null && token != null) {
      _currentUser = cached;
      notifyListeners();
    }
    if (token != null) checkAuth();
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await ApiClient().post(ApiEndpoints.login, data: {
        'email': email.trim(),
        'password': password.trim(),
      });
      if (res is Map) {
        final token = res['token']?.toString();
        final userJson = res['user'];
        if (token != null && userJson is Map) {
          final userMap = Map<String, dynamic>.from(userJson);
          final role = userMap['role']?.toString().toUpperCase() ?? '';

          // 🔒 Admin App only accepts COOPERATIVE_ADMIN, ADMIN, or SUPER_ADMIN
          if (role != 'COOPERATIVE_ADMIN' && role != 'ADMIN' && role != 'SUPER_ADMIN') {
            _errorMessage = 'Access restricted: This application is exclusively for Cooperative Administrators & Federation Officers. Please use the Citizen or Prithvi Worker mobile app.';
            _isLoading = false;
            notifyListeners();
            return false;
          }

          await StorageService.saveToken(token);
          final user = UserModel.fromJson(userMap);
          await StorageService.saveUser(user);
          _currentUser = user;
          _isLoading = false;
          notifyListeners();
          return true;
        }
      }
      throw ApiException('Invalid credentials or server response');
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
        final user = UserModel.fromJson(userMap);
        await StorageService.saveUser(user);
        _currentUser = user;
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

  /// 1-Click demo logins for different administrative roles
  Future<bool> loginAsApexHead() async {
    return await login('fedhead@demo.local', 'demo123');
  }

  Future<bool> loginAsDco() async {
    return await login('dco.khordha@demo.local', 'demo123');
  }

  Future<bool> loginAsSocietyAdmin() async {
    return await login('society.khordha@demo.local', 'demo123');
  }
}
