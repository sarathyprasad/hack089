import 'package:flutter/material.dart';
import '../models/worker_model.dart';
import '../core/network/api_client.dart';
import '../core/constants/api_endpoints.dart';

class WorkerProvider extends ChangeNotifier {
  List<WorkerModel> _workers = [];
  List<WorkerModel> _matchedWorkers = [];
  WorkerModel? _selectedWorker;
  String _selectedDistrict = 'ALL';
  String _selectedTrade = 'ALL';
  bool _isLoading = false;
  bool _isMatching = false;
  String? _errorMessage;

  List<WorkerModel> get workers => _workers;
  List<WorkerModel> get matchedWorkers => _matchedWorkers;
  WorkerModel? get selectedWorker => _selectedWorker;
  String get selectedDistrict => _selectedDistrict;
  String get selectedTrade => _selectedTrade;
  bool get isLoading => _isLoading;
  bool get isMatching => _isMatching;
  String? get errorMessage => _errorMessage;

  Future<void> fetchWorkers({String? trade, String? district, bool? verified}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final Map<String, dynamic> params = {};
      if (trade != null && trade != 'ALL') params['trade'] = trade;
      if (district != null && district != 'ALL') params['district'] = district;
      if (verified != null) params['verified'] = verified.toString();

      final dynamic res = await ApiClient().get(ApiEndpoints.workers, queryParameters: params);
      if (res is Map && res['workers'] is List) {
        _workers = (res['workers'] as List)
            .map((item) => WorkerModel.fromJson(Map<String, dynamic>.from(item)))
            .toList();
      } else if (res is List) {
        _workers = res
            .map((item) => WorkerModel.fromJson(Map<String, dynamic>.from(item)))
            .toList();
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchWorkerById(int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await ApiClient().get('${ApiEndpoints.workers}/$id');
      if (res is Map && res['worker'] != null) {
        _selectedWorker = WorkerModel.fromJson(Map<String, dynamic>.from(res['worker']));
      } else if (res is Map) {
        _selectedWorker = WorkerModel.fromJson(Map<String, dynamic>.from(res));
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Smart Matching Recommendation Engine
  Future<List<WorkerModel>> recommendWorkers({
    required int serviceId,
    required String district,
    required String city,
    bool isEmergency = false,
  }) async {
    _isMatching = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final dynamic res = await ApiClient().post(
        ApiEndpoints.matchRecommend,
        data: {
          'serviceId': serviceId,
          'district': district,
          'city': city,
          'isEmergency': isEmergency,
        },
      );

      if (res is Map && res['workers'] is List) {
        _matchedWorkers = (res['workers'] as List)
            .map((item) => WorkerModel.fromJson(Map<String, dynamic>.from(item)))
            .toList();
      } else if (res is List) {
        _matchedWorkers = res
            .map((item) => WorkerModel.fromJson(Map<String, dynamic>.from(item)))
            .toList();
      }
      return _matchedWorkers;
    } catch (e) {
      _errorMessage = e.toString();
      return [];
    } finally {
      _isMatching = false;
      notifyListeners();
    }
  }

  void setFilter({String? district, String? trade}) {
    if (district != null) _selectedDistrict = district;
    if (trade != null) _selectedTrade = trade;
    fetchWorkers(
      district: _selectedDistrict == 'ALL' ? null : _selectedDistrict,
      trade: _selectedTrade == 'ALL' ? null : _selectedTrade,
    );
  }
}
