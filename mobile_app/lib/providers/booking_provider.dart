import 'package:flutter/material.dart';
import '../models/booking_model.dart';
import '../models/invoice_model.dart';
import '../core/network/api_client.dart';
import '../core/constants/api_endpoints.dart';

class BookingProvider extends ChangeNotifier {
  List<BookingModel> _bookings = [];
  BookingModel? _currentBooking;
  InvoiceModel? _currentInvoice;
  bool _isLoading = false;
  String? _errorMessage;

  List<BookingModel> get bookings => _bookings;
  BookingModel? get currentBooking => _currentBooking;
  InvoiceModel? get currentInvoice => _currentInvoice;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<BookingModel> get activeBookings => _bookings.where((b) => !b.isCompleted && !b.isCancelled).toList();
  List<BookingModel> get completedBookings => _bookings.where((b) => b.isCompleted || b.isCancelled).toList();

  Future<BookingModel?> createBooking(Map<String, dynamic> data) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await ApiClient().post(ApiEndpoints.bookings, data: data);
      if (res is Map && res['booking'] != null) {
        final booking = BookingModel.fromJson(Map<String, dynamic>.from(res['booking']));
        _currentBooking = booking;
        _bookings.insert(0, booking);
        _isLoading = false;
        notifyListeners();
        return booking;
      }
      throw ApiException('Unexpected booking response format');
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  Future<void> fetchCustomerBookings() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final dynamic res = await ApiClient().get(ApiEndpoints.bookings);
      if (res is Map && res['bookings'] is List) {
        _bookings = (res['bookings'] as List)
            .map((b) => BookingModel.fromJson(Map<String, dynamic>.from(b)))
            .toList();
      } else if (res is List) {
        _bookings = res
            .map((b) => BookingModel.fromJson(Map<String, dynamic>.from(b)))
            .toList();
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchBookingDetail(int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await ApiClient().get(ApiEndpoints.bookingDetail(id));
      if (res is Map && res['booking'] != null) {
        _currentBooking = BookingModel.fromJson(Map<String, dynamic>.from(res['booking']));
      } else if (res is Map) {
        _currentBooking = BookingModel.fromJson(Map<String, dynamic>.from(res));
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> verifyArrivalOtp(int id, String otp) async {
    try {
      final res = await ApiClient().post(ApiEndpoints.verifyArrivalOtp(id), data: {'otp': otp});
      if (res is Map && (res['success'] == true || res['status'] == 'IN_PROGRESS')) {
        await fetchBookingDetail(id);
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> verifyCompletionOtp(int id, String otp) async {
    try {
      final res = await ApiClient().post(ApiEndpoints.verifyCompletionOtp(id), data: {'otp': otp});
      if (res is Map && (res['success'] == true || res['status'] == 'COMPLETED')) {
        await fetchBookingDetail(id);
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> processPayment({
    required int bookingId,
    required String paymentMethod,
    required double amount,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final res = await ApiClient().post(
        ApiEndpoints.processPayment,
        data: {
          'bookingId': bookingId,
          'paymentMethod': paymentMethod,
          'amount': amount,
        },
      );
      if (res is Map && res['status'] == 'PAID') {
        await fetchBookingDetail(bookingId);
        await fetchInvoice(bookingId);
        _isLoading = false;
        notifyListeners();
        return true;
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> fetchInvoice(int bookingId) async {
    try {
      final res = await ApiClient().get(ApiEndpoints.getInvoice(bookingId));
      if (res is Map && res['invoice'] != null) {
        _currentInvoice = InvoiceModel.fromJson(Map<String, dynamic>.from(res['invoice']));
      } else if (res is Map) {
        _currentInvoice = InvoiceModel.fromJson(Map<String, dynamic>.from(res));
      }
      notifyListeners();
    } catch (_) {}
  }

  Future<bool> claimGuarantee(int bookingId) async {
    try {
      await ApiClient().post(ApiEndpoints.claimGuarantee(bookingId));
      await fetchBookingDetail(bookingId);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> submitReview(Map<String, dynamic> reviewData) async {
    try {
      await ApiClient().post(ApiEndpoints.reviews, data: reviewData);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
}
