import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../core/network/api_client.dart';
import '../core/storage/storage_service.dart';
import '../core/constants/api_endpoints.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isGuest = false;

  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoggedIn => _currentUser != null;
  bool get isGuest => _isGuest && _currentUser == null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  AuthProvider() {
    _initializeUser();
  }

  void _initializeUser() {
    final cached = StorageService.getUser();
    final token = StorageService.getToken();
    _isGuest = StorageService.isGuestMode();

    if (cached != null && token != null) {
      _currentUser = UserModel.fromJson(cached);
      _isGuest = false;
      notifyListeners();
    }
    // Verify in background
    if (token != null) {
      checkAuth();
    }
  }

  void continueAsGuest() {
    _isGuest = true;
    StorageService.setGuestMode(true);
    notifyListeners();
  }

  void exitGuestMode() {
    _isGuest = false;
    StorageService.clearGuestMode();
    notifyListeners();
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
          await StorageService.saveToken(token);
          await StorageService.saveUser(Map<String, dynamic>.from(userJson));
          await StorageService.clearGuestMode();
          _isGuest = false;
          _currentUser = UserModel.fromJson(Map<String, dynamic>.from(userJson));
          _isLoading = false;
          notifyListeners();
          return true;
        }
      }
      throw ApiException('Invalid response format from server');
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
      final res = await ApiClient().post(
        ApiEndpoints.register,
        data: userData,
      );

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
    } catch (_) {
      // Keep cached session if offline
    }
  }

  Future<void> logout() async {
    await StorageService.clearAuth();
    await StorageService.clearGuestMode();
    _currentUser = null;
    _isGuest = false;
    _errorMessage = null;
    notifyListeners();
  }

  // 1-Click Demo Persona Login Helper for Evaluation
  Future<bool> demoLogin(String role) async {
    switch (role.toUpperCase()) {
      case 'WORKER':
        return await login('ramesh.w@demo.local', 'demo123');
      case 'ADMIN':
      case 'COOPERATIVE_ADMIN':
        return await login('admin@demo.local', 'demo123');
      case 'CUSTOMER':
      default:
        return await login('customer@demo.local', 'demo123');
    }
  }
}
