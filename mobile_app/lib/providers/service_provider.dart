import 'package:flutter/material.dart';
import '../models/service_model.dart';
import '../core/network/api_client.dart';
import '../core/constants/api_endpoints.dart';

class ServiceProvider extends ChangeNotifier {
  List<ServiceModel> _services = [];
  List<ServiceModel> _filteredServices = [];
  ServiceModel? _selectedService;
  String _selectedCategory = 'ALL';
  String _searchQuery = '';
  bool _isLoading = false;
  String? _errorMessage;

  List<ServiceModel> get services => _filteredServices;
  List<ServiceModel> get allServices => _services;
  ServiceModel? get selectedService => _selectedService;
  String get selectedCategory => _selectedCategory;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<String> get categories {
    final Set<String> cats = {'ALL'};
    for (var s in _services) {
      if (s.category.isNotEmpty) cats.add(s.category);
    }
    return cats.toList();
  }

  Future<void> fetchServices() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final dynamic res = await ApiClient().get(ApiEndpoints.services);
      if (res is Map && res['services'] is List) {
        _services = (res['services'] as List)
            .map((item) => ServiceModel.fromJson(Map<String, dynamic>.from(item)))
            .toList();
      } else if (res is List) {
        _services = res
            .map((item) => ServiceModel.fromJson(Map<String, dynamic>.from(item)))
            .toList();
      }
      _applyFilters();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchServiceById(int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await ApiClient().get('${ApiEndpoints.services}/$id');
      if (res is Map && res['service'] != null) {
        _selectedService = ServiceModel.fromJson(Map<String, dynamic>.from(res['service']));
      } else if (res is Map) {
        _selectedService = ServiceModel.fromJson(Map<String, dynamic>.from(res));
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectCategory(String category) {
    _selectedCategory = category;
    _applyFilters();
    notifyListeners();
  }

  void search(String query) {
    _searchQuery = query.toLowerCase();
    _applyFilters();
    notifyListeners();
  }

  void _applyFilters() {
    _filteredServices = _services.where((s) {
      final matchesCategory = _selectedCategory == 'ALL' || s.category.toUpperCase() == _selectedCategory.toUpperCase();
      final matchesQuery = _searchQuery.isEmpty ||
          s.name.toLowerCase().contains(_searchQuery) ||
          s.category.toLowerCase().contains(_searchQuery) ||
          s.description.toLowerCase().contains(_searchQuery);
      return matchesCategory && matchesQuery;
    }).toList();
  }
}
