import 'package:flutter/material.dart';
import '../models/worker_model.dart';
import '../models/booking_model.dart';
import '../core/network/api_client.dart';
import '../core/constants/api_endpoints.dart';

class AdminProvider extends ChangeNotifier {
  Map<String, dynamic> _kpis = {};
  List<WorkerModel> _adminWorkers = [];
  final List<BookingModel> _adminBookings = [];
  List<dynamic> _forecastList = [];
  List<dynamic> _allocationGaps = [];
  List<dynamic> _sosAlerts = [];
  Map<String, dynamic> _liveMapData = {};
  bool _isLoading = false;
  String? _errorMessage;

  Map<String, dynamic> get kpis => _kpis;
  List<WorkerModel> get adminWorkers => _adminWorkers;
  List<BookingModel> get adminBookings => _adminBookings;
  List<dynamic> get forecastList => _forecastList;
  List<dynamic> get allocationGaps => _allocationGaps;
  List<dynamic> get sosAlerts => _sosAlerts;
  Map<String, dynamic> get liveMapData => _liveMapData;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchDashboard() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await ApiClient().get(ApiEndpoints.adminDashboard);
      if (res is Map) {
        _kpis = Map<String, dynamic>.from(res['kpis'] ?? res['stats'] ?? res);
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchAdminWorkers({String? status}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final Map<String, dynamic> params = {};
      if (status != null && status != 'ALL') params['status'] = status;

      final dynamic res = await ApiClient().get(ApiEndpoints.adminWorkers, queryParameters: params);
      if (res is Map && res['workers'] is List) {
        _adminWorkers = (res['workers'] as List)
            .map((w) => WorkerModel.fromJson(Map<String, dynamic>.from(w)))
            .toList();
      } else if (res is List) {
        _adminWorkers = res
            .map((w) => WorkerModel.fromJson(Map<String, dynamic>.from(w)))
            .toList();
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> verifyWorker(int workerId, String status, {String rejectionReason = ''}) async {
    try {
      final res = await ApiClient().put(
        ApiEndpoints.adminVerifyWorker(workerId),
        data: {'status': status, 'rejectionReason': rejectionReason},
      );
      await fetchAdminWorkers();
      await fetchDashboard();
      return res is Map && res['success'] == true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> fetchSmartForecast() async {
    try {
      final res = await ApiClient().get(ApiEndpoints.demandForecast);
      if (res is Map && res['forecasts'] is List) {
        _forecastList = res['forecasts'];
      }
      final allocRes = await ApiClient().get(ApiEndpoints.workforceAllocation);
      if (allocRes is Map && allocRes['gaps'] is List) {
        _allocationGaps = allocRes['gaps'];
      }
      notifyListeners();
    } catch (_) {}
  }

  Future<bool> approveMutualAid(int proposalId) async {
    try {
      await ApiClient().post(ApiEndpoints.approveMutualAid(proposalId));
      await fetchSmartForecast();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> fetchSosAlerts() async {
    try {
      final dynamic res = await ApiClient().get(ApiEndpoints.sosAlerts);
      if (res is Map && res['alerts'] is List) {
        _sosAlerts = res['alerts'];
      } else if (res is List) {
        _sosAlerts = res;
      }
      notifyListeners();
    } catch (_) {}
  }

  Future<void> fetchLiveMap() async {
    try {
      final res = await ApiClient().get(ApiEndpoints.liveMap);
      if (res is Map) {
        _liveMapData = Map<String, dynamic>.from(res);
        notifyListeners();
      }
    } catch (_) {}
  }
}
