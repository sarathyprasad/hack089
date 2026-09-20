import 'package:flutter/foundation.dart';
import '../core/network/api_client.dart';
import '../core/constants/api_endpoints.dart';
import '../models/review_model.dart';

class ReviewProvider extends ChangeNotifier {
  List<CustomerReview> _customerReviews = [];
  List<WorkerReview> _workerReviews = [];
  ReviewStats? _stats;
  bool _isLoading = false;
  String? _errorMessage;

  String _activeTab = 'ALL'; // 'ALL', 'CUSTOMER', 'WORKER'
  String _selectedTrade = 'all'; // 'all', 'electrical', 'plumbing', 'carpentry'

  List<CustomerReview> get customerReviews => _customerReviews;
  List<WorkerReview> get workerReviews => _workerReviews;
  ReviewStats? get stats => _stats;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get activeTab => _activeTab;
  String get selectedTrade => _selectedTrade;

  List<CustomerReview> get filteredCustomerReviews {
    if (_selectedTrade == 'all') return _customerReviews;
    return _customerReviews.where((r) => r.category.toLowerCase().contains(_selectedTrade)).toList();
  }

  List<WorkerReview> get filteredWorkerReviews {
    if (_selectedTrade == 'all') return _workerReviews;
    return _workerReviews.where((r) => r.category.toLowerCase().contains(_selectedTrade)).toList();
  }

  void setActiveTab(String tab) {
    _activeTab = tab;
    notifyListeners();
  }

  void setSelectedTrade(String trade) {
    _selectedTrade = trade;
    notifyListeners();
  }

  Future<void> fetchFeaturedReviews() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final dynamic res = await ApiClient().get(ApiEndpoints.featuredReviews);
      if (res is Map && res['success'] == true) {
        final custJson = (res['customerReviews'] as List<dynamic>?) ?? [];
        final wrkJson = (res['workerReviews'] as List<dynamic>?) ?? [];
        final statsJson = res['stats'] as Map<String, dynamic>?;

        _customerReviews = custJson.map((e) => CustomerReview.fromJson(Map<String, dynamic>.from(e as Map))).toList();
        _workerReviews = wrkJson.map((e) => WorkerReview.fromJson(Map<String, dynamic>.from(e as Map))).toList();
        if (statsJson != null) {
          _stats = ReviewStats.fromJson(Map<String, dynamic>.from(statsJson));
        }
      }
    } catch (e) {
      _errorMessage = 'Failed to load community reviews.';
      if (kDebugMode) {
        print('Error fetching featured reviews: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> submitReview({
    required int bookingId,
    required int rating,
    required String comment,
  }) async {
    try {
      await ApiClient().post(ApiEndpoints.reviews, data: {
        'bookingId': bookingId,
        'rating': rating,
        'comment': comment,
      });
      await fetchFeaturedReviews();
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error submitting review: $e');
      }
      return false;
    }
  }
}
