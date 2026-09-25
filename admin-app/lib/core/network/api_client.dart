import 'package:dio/dio.dart';
import '../constants/api_endpoints.dart';
import '../storage/storage_service.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  ApiException(this.message, {this.statusCode, this.data});

  @override
  String toString() => message;
}

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  late Dio dio;

  ApiClient._internal() {
    dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'ngrok-skip-browser-warning': 'true',
        },
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          options.baseUrl = ApiEndpoints.activeBaseUrl;
          final token = StorageService.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException error, handler) {
          if (error.response?.statusCode == 401) {
            StorageService.clearAuth();
          }
          return handler.next(error);
        },
      ),
    );
  }

  ApiException _handleDioError(DioException e) {
    if (e.response != null && e.response?.data != null) {
      final data = e.response!.data;
      if (data is Map) {
        final msg = data['message'] ?? data['error'] ?? 'Server error occurred';
        return ApiException(msg.toString(), statusCode: e.response?.statusCode, data: data);
      }
      return ApiException('HTTP ${e.response?.statusCode}: ${e.response?.statusMessage}', statusCode: e.response?.statusCode);
    }
    if (e.type == DioExceptionType.connectionTimeout || e.type == DioExceptionType.receiveTimeout) {
      return ApiException('Connection timeout. Check your network.');
    }
    if (e.type == DioExceptionType.connectionError) {
      return ApiException('Unable to reach server at ${ApiEndpoints.activeBaseUrl}');
    }
    return ApiException(e.message ?? 'Unknown network error.');
  }

  Future<dynamic> get(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await dio.get(path, queryParameters: queryParameters);
      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<dynamic> post(String path, {dynamic data}) async {
    try {
      final response = await dio.post(path, data: data);
      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<dynamic> put(String path, {dynamic data}) async {
    try {
      final response = await dio.put(path, data: data);
      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<dynamic> patch(String path, {dynamic data}) async {
    try {
      final response = await dio.patch(path, data: data);
      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<dynamic> delete(String path, {dynamic data}) async {
    try {
      final response = await dio.delete(path, data: data);
      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }
}
