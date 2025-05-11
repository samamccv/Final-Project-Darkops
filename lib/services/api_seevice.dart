// lib/services/api_service.dart
import 'package:dio/dio.dart';

class ApiService {
  final Dio _dio;
  final String baseUrl = "http://localhost:9999";

  ApiService({String? baseUrl})
    : _dio = Dio(
        BaseOptions(
          baseUrl: baseUrl ?? 'http://localhost:9999',
          connectTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 3),
        ),
      );

  Future<Response> login(String email, String password) async {
    try {
      final response = await _dio.post(
        '/auth/signin',
        data: {'email': email, 'password': password, 'rememberMe': true},
      );
      return response;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> register(String email, String password, String name) async {
    try {
      final response = await _dio.post(
        '/auth/signup',
        data: {'email': email, 'password': password, 'name': name},
      );
      return response;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> forgotPassword(String email) async {
    try {
      final response = await _dio.post(
        '/auth/forgot-password',
        data: {'email': email},
      );
      return response;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> verifyCode(String email, String otp) async {
    try {
      final response = await _dio.post(
        '/auth/verify-email',
        data: {'email': email, 'otp': otp},
      );
      return response;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> resetPassword(
    String email,
    String otp,
    String newPassword,
  ) async {
    try {
      final response = await _dio.post(
        '/auth/reset-password',
        data: {'email': email, 'otp': otp, 'newPassword': newPassword},
      );
      return response;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return Exception('Connection timed out');
        case DioExceptionType.badResponse:
          return Exception(error.response?.data['message'] ?? 'Server error');
        case DioExceptionType.cancel:
          return Exception('Request cancelled');
        default:
          return Exception('Network error occurred');
      }
    }
    return Exception('Something went wrong');
  }
}
