import 'dart:async';
import 'package:flutter/material.dart';
import '../models/booking_model.dart';
import '../core/network/api_client.dart';
import '../core/constants/api_endpoints.dart';

class WorkerPortalProvider extends ChangeNotifier {
  String _availability = 'AVAILABLE';
  double _totalEarnings = 0.0;
  int _completedTasks = 0;
  double _averageRating = 4.8;
  List<BookingModel> _incomingQueue = [];
  List<BookingModel> _activeOrders = [];
  Map<String, dynamic> _welfareData = {};
  bool _isLoading = false;
  String? _errorMessage;
  Timer? _pollingTimer;

  String get availability => _availability;
  double get totalEarnings => _totalEarnings;
  int get completedTasks => _completedTasks;
  double get averageRating => _averageRating;
  List<BookingModel> get incomingQueue => _incomingQueue;
  List<BookingModel> get activeOrders => _activeOrders;
  Map<String, dynamic> get welfareData => _welfareData;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  bool get isAvailable => _availability.toUpperCase() == 'AVAILABLE';

  WorkerPortalProvider() {
    startAutoPolling();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  void startAutoPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (isAvailable) {
        fetchDashboardSilently();
      }
    });
  }

  Future<void> fetchDashboardSilently() async {
    try {
      final res = await ApiClient().get(ApiEndpoints.workerDashboard);
      if (res is Map) {
        _parseDashboard(res);
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> fetchDashboard() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await ApiClient().get(ApiEndpoints.workerDashboard);
      if (res is Map) {
        _parseDashboard(res);
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _parseDashboard(Map res) {
    if (res['worker'] != null) {
      _availability = res['worker']['availability']?.toString().toUpperCase() ?? _availability;
    }
    _totalEarnings = double.tryParse(res['total_earnings']?.toString() ?? '0') ?? _totalEarnings;
    _completedTasks = int.tryParse(res['completed_tasks']?.toString() ?? '0') ?? _completedTasks;
    _averageRating = double.tryParse(res['rating']?.toString() ?? '4.8') ?? _averageRating;

    if (res['incoming_queue'] is List) {
      _incomingQueue = (res['incoming_queue'] as List)
          .map((b) => BookingModel.fromJson(Map<String, dynamic>.from(b)))
          .toList();
    }
    if (res['active_orders'] is List) {
      _activeOrders = (res['active_orders'] as List)
          .map((b) => BookingModel.fromJson(Map<String, dynamic>.from(b)))
          .toList();
    }
  }

  Future<bool> updateAvailability(String newStatus) async {
    try {
      final res = await ApiClient().put(
        ApiEndpoints.workerAvailability,
        data: {'availability': newStatus},
      );
      if (res is Map && res['availability'] != null) {
        _availability = res['availability'].toString().toUpperCase();
        notifyListeners();
        return true;
      }
      _availability = newStatus;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> handleJobAction(int bookingId, String action) async {
    _isLoading = true;
    notifyListeners();

    try {
      final res = await ApiClient().put(
        ApiEndpoints.workerJobAction(bookingId),
        data: {'action': action},
      );
      await fetchDashboard();
      _isLoading = false;
      notifyListeners();
      return res is Map && res['success'] == true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> fetchWelfare() async {
    _isLoading = true;
    notifyListeners();

    try {
      final res = await ApiClient().get(ApiEndpoints.workerWelfare);
      if (res is Map) {
        _welfareData = Map<String, dynamic>.from(res);
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> enrollWelfare(Map<String, dynamic> data) async {
    try {
      await ApiClient().post(ApiEndpoints.workerWelfareEnroll, data: data);
      await fetchWelfare();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
}
