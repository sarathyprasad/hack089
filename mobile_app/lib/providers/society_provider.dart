import 'package:flutter/material.dart';
import '../models/society_model.dart';
import '../core/network/api_client.dart';
import '../core/constants/api_endpoints.dart';

class SocietyProvider extends ChangeNotifier {
  SocietyModel? _trackedSociety;
  List<SocietyModel> _societies = [];
  List<TenderModel> _tenders = [];
  Map<String, dynamic> _federationAdminData = {};
  Map<String, dynamic> _federationTreasurerData = {};
  bool _isLoading = false;
  String? _errorMessage;

  SocietyModel? get trackedSociety => _trackedSociety;
  List<SocietyModel> get societies => _societies;
  List<TenderModel> get tenders => _tenders;
  Map<String, dynamic> get federationAdminData => _federationAdminData;
  Map<String, dynamic> get federationTreasurerData => _federationTreasurerData;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<String?> registerSociety(Map<String, dynamic> formData) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await ApiClient().post(ApiEndpoints.societiesRegister, data: formData);
      _isLoading = false;
      notifyListeners();
      if (res is Map && res['trackingId'] != null) {
        return res['trackingId'].toString();
      }
      return 'OD-COOP-2026-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  Future<SocietyModel?> trackSociety(String trackingId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await ApiClient().get(ApiEndpoints.societyTrack(trackingId.trim()));
      if (res is Map && res['society'] != null) {
        _trackedSociety = SocietyModel.fromJson(Map<String, dynamic>.from(res['society']));
      } else if (res is Map) {
        _trackedSociety = SocietyModel.fromJson(Map<String, dynamic>.from(res));
      }
      return _trackedSociety;
    } catch (e) {
      _errorMessage = e.toString();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchSocieties() async {
    try {
      final dynamic res = await ApiClient().get(ApiEndpoints.societiesList);
      if (res is Map && res['societies'] is List) {
        _societies = (res['societies'] as List)
            .map((s) => SocietyModel.fromJson(Map<String, dynamic>.from(s)))
            .toList();
      } else if (res is List) {
        _societies = res
            .map((s) => SocietyModel.fromJson(Map<String, dynamic>.from(s)))
            .toList();
      }
      notifyListeners();
    } catch (_) {}
  }

  Future<void> fetchFederationConsoles() async {
    _isLoading = true;
    notifyListeners();

    try {
      final adminRes = await ApiClient().get(ApiEndpoints.federationAdminDashboard);
      if (adminRes is Map) _federationAdminData = Map<String, dynamic>.from(adminRes);

      final treasRes = await ApiClient().get(ApiEndpoints.federationTreasurerDashboard);
      if (treasRes is Map) _federationTreasurerData = Map<String, dynamic>.from(treasRes);

      final tendersRes = await ApiClient().get(ApiEndpoints.federationTenders);
      if (tendersRes is Map && tendersRes['tenders'] is List) {
        _tenders = (tendersRes['tenders'] as List)
            .map((t) => TenderModel.fromJson(Map<String, dynamic>.from(t)))
            .toList();
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> applyNcct(Map<String, dynamic> data) async {
    try {
      await ApiClient().post(ApiEndpoints.federationApplyNcct, data: data);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
}
