// lib/services/api_service.dart
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/auth/auth_models.dart';
import '../models/dashboard/dashboard_stats.dart';
import '../config/app_config.dart';

class ApiService {
  final Dio _dio;
  final FlutterSecureStorage _storage;
  static const String _tokenKey = 'auth_token';

  // Development flag - set to false when backend GraphQL is ready
  static const bool _useMockDashboardData = false;

  ApiService({String? baseUrl})
    : _dio = Dio(
        BaseOptions(
          baseUrl: baseUrl ?? AppConfig.baseUrl,
          connectTimeout: AppConfig.connectTimeout,
          receiveTimeout: AppConfig.receiveTimeout,
          headers: AppConfig.defaultHeaders,
        ),
      ),
      _storage = const FlutterSecureStorage() {
    _setupInterceptors();
    AppConfig.printConfig(); // Print config for debugging
  }

  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Add auth token to requests if available
          final token = await getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) {
          // Handle token expiration
          if (error.response?.statusCode == 401) {
            clearToken();
          }
          handler.next(error);
        },
      ),
    );
  }

  // Token management
  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  Future<void> clearToken() async {
    await _storage.delete(key: _tokenKey);
  }

  // Authentication API methods
  Future<AuthResponse> login(LoginRequest request) async {
    try {
      final response = await _dio.post('/auth/signin', data: request.toJson());
      final authResponse = AuthResponse.fromJson(response.data);

      // Save token if login successful
      if (authResponse.token != null) {
        await saveToken(authResponse.token!);
      }

      return authResponse;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<AuthResponse> register(SignupRequest request) async {
    try {
      final response = await _dio.post('/auth/signup', data: request.toJson());
      return AuthResponse.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<MessageResponse> forgotPassword(ForgotPasswordRequest request) async {
    try {
      final response = await _dio.post(
        '/auth/forgot-password',
        data: request.toJson(),
      );
      return MessageResponse.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<MessageResponse> verifyEmail(VerifyEmailRequest request) async {
    try {
      final response = await _dio.post(
        '/auth/verify-email',
        data: request.toJson(),
      );
      return MessageResponse.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<MessageResponse> resetPassword(ResetPasswordRequest request) async {
    try {
      final response = await _dio.post(
        '/auth/reset-password',
        data: request.toJson(),
      );
      return MessageResponse.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<MessageResponse> resendVerification(
    ResendVerificationRequest request,
  ) async {
    try {
      final response = await _dio.post(
        '/auth/resend-verification',
        data: request.toJson(),
      );
      return MessageResponse.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<AuthResponse> getCurrentUser() async {
    try {
      final response = await _dio.get('/auth/me');
      return AuthResponse.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<MessageResponse> logout() async {
    try {
      final response = await _dio.post('/auth/logout');
      await clearToken();
      return MessageResponse.fromJson(response.data);
    } catch (e) {
      await clearToken(); // Clear token even if logout fails
      throw _handleError(e);
    }
  }

  // Google OAuth methods
  String getGoogleAuthUrl() {
    return '${_dio.options.baseUrl}/auth/google';
  }

  Future<AuthResponse> handleGoogleCallback(
    String code, {
    String? state,
  }) async {
    try {
      final response = await _dio.get(
        '/auth/google/callback',
        queryParameters: {'code': code, if (state != null) 'state': state},
      );
      final authResponse = AuthResponse.fromJson(response.data);

      // Save token if OAuth successful
      if (authResponse.token != null) {
        await saveToken(authResponse.token!);
      }

      return authResponse;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Dashboard API methods
  Future<DashboardStats> getDashboardStats() async {
    // Use mock data during development
    if (_useMockDashboardData) {
      return await _getMockDashboardStats();
    }

    try {
      // Log the request for debugging
      print('Making GraphQL request to: ${_dio.options.baseUrl}/graphql');

      // Real API call using the exact GraphQL query from web frontend
      final response = await _dio.post(
        '/graphql',
        data: {
          'query': '''
            query DashboardData {
              dashboardStats {
                # Total Scans and Scan Counts by Type
                totalScans
                totalScansPercentageChange
                scansByType {
                  type
                  count
                  percentageChange
                  previousWeekCount
                }

                # Threat Score Card Data
                threatScore {
                  score
                  level
                  percentageChange
                  previousScore
                }

                # Recent Scans (Last 10)
                recentScans {
                  id
                  userId
                  scanType
                  target
                  SR
                  createdAt
                  result {
                    threatScore
                    threatLevel
                    confidence
                    findings {
                      type
                      severity
                      description
                    }
                  }
                }
              }
            }
          ''',
        },
      );

      print('GraphQL response status: ${response.statusCode}');

      // Check for GraphQL errors
      if (response.data['errors'] != null) {
        final errorMessage = response.data['errors'][0]['message'];
        print('GraphQL error: $errorMessage');
        throw Exception('GraphQL Error: $errorMessage');
      }

      // Check if data exists
      if (response.data['data'] == null ||
          response.data['data']['dashboardStats'] == null) {
        print('No dashboard data in response');
        throw Exception('No dashboard data received from server');
      }

      final dashboardData = response.data['data']['dashboardStats'];
      print(
        'Successfully received dashboard data with ${dashboardData['totalScans']} total scans',
      );

      return DashboardStats.fromJson(dashboardData);
    } catch (e) {
      // Log the error for debugging
      print('Dashboard API error: $e');

      // Fallback to mock data if API fails
      print('Falling back to mock data due to API error');
      return await _getMockDashboardStats();
    }
  }

  // Mock data for development/testing
  Future<DashboardStats> _getMockDashboardStats() async {
    // Simulate network delay for realistic loading experience
    await Future.delayed(const Duration(milliseconds: 800));

    return DashboardStats.fromJson({
      'totalScans': 42,
      'totalScansPercentageChange': 15.3,
      'threatScore': {
        'score': 7.2,
        'level': 'MEDIUM',
        'percentageChange': -2.1,
        'previousScore': 7.4,
      },
      'scansByType': [
        {
          'type': 'SMS',
          'count': 8,
          'percentageChange': 25.0,
          'previousWeekCount': 6,
        },
        {
          'type': 'EMAIL',
          'count': 12,
          'percentageChange': 9.1,
          'previousWeekCount': 11,
        },
        {
          'type': 'URL',
          'count': 15,
          'percentageChange': -6.3,
          'previousWeekCount': 16,
        },
        {
          'type': 'QR',
          'count': 4,
          'percentageChange': 33.3,
          'previousWeekCount': 3,
        },
        {
          'type': 'APK',
          'count': 3,
          'percentageChange': 0.0,
          'previousWeekCount': 3,
        },
      ],
      'recentScans': [
        {
          'id': '1',
          'userId': 'user123',
          'scanType': 'EMAIL',
          'target': 'suspicious-email@example.com',
          'SR': 'HIGH',
          'result': {
            'threatScore': 8.5,
            'threatLevel': 'HIGH',
            'confidence': 0.92,
            'findings': [
              {
                'type': 'PHISHING',
                'severity': 'HIGH',
                'description': 'Suspicious links detected',
              },
            ],
          },
          'createdAt':
              DateTime.now()
                  .subtract(const Duration(hours: 2))
                  .toIso8601String(),
        },
        {
          'id': '2',
          'userId': 'user123',
          'scanType': 'URL',
          'target': 'https://suspicious-site.com',
          'SR': 'MEDIUM',
          'result': {
            'threatScore': 6.2,
            'threatLevel': 'MEDIUM',
            'confidence': 0.78,
            'findings': [
              {
                'type': 'MALWARE',
                'severity': 'MEDIUM',
                'description': 'Potentially malicious content',
              },
            ],
          },
          'createdAt':
              DateTime.now()
                  .subtract(const Duration(hours: 5))
                  .toIso8601String(),
        },
        {
          'id': '3',
          'userId': 'user123',
          'scanType': 'SMS',
          'target': 'Your account has been compromised...',
          'SR': 'LOW',
          'result': {
            'threatScore': 2.1,
            'threatLevel': 'LOW',
            'confidence': 0.65,
            'findings': [
              {
                'type': 'SPAM',
                'severity': 'LOW',
                'description': 'Potential spam message',
              },
            ],
          },
          'createdAt':
              DateTime.now()
                  .subtract(const Duration(days: 1))
                  .toIso8601String(),
        },
        {
          'id': '4',
          'userId': 'user123',
          'scanType': 'APK',
          'target': 'malicious-app.apk',
          'SR': 'CRITICAL',
          'result': {
            'threatScore': 9.1,
            'threatLevel': 'CRITICAL',
            'confidence': 0.95,
            'findings': [
              {
                'type': 'TROJAN',
                'severity': 'CRITICAL',
                'description': 'Trojan detected in APK',
              },
            ],
          },
          'createdAt':
              DateTime.now()
                  .subtract(const Duration(days: 2))
                  .toIso8601String(),
        },
        {
          'id': '5',
          'userId': 'user123',
          'scanType': 'QR',
          'target': 'QR Code: malicious-redirect',
          'SR': 'MEDIUM',
          'result': {
            'threatScore': 4.7,
            'threatLevel': 'MEDIUM',
            'confidence': 0.71,
            'findings': [
              {
                'type': 'REDIRECT',
                'severity': 'MEDIUM',
                'description': 'Suspicious redirect detected',
              },
            ],
          },
          'createdAt':
              DateTime.now()
                  .subtract(const Duration(days: 3))
                  .toIso8601String(),
        },
      ],
    });
  }

  // Enhanced error handling
  Exception _handleError(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return Exception(
            'Connection timed out. Please check your internet connection.',
          );
        case DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode;
          final message = error.response?.data?['message'] ?? 'Server error';

          switch (statusCode) {
            case 400:
              return Exception(message);
            case 401:
              return Exception('Authentication failed. Please login again.');
            case 403:
              return Exception('Access denied.');
            case 404:
              return Exception('Resource not found.');
            case 409:
              return Exception(message);
            case 500:
              return Exception('Server error. Please try again later.');
            default:
              return Exception(message);
          }
        case DioExceptionType.cancel:
          return Exception('Request cancelled');
        case DioExceptionType.connectionError:
          return Exception(
            'No internet connection. Please check your network.',
          );
        default:
          return Exception('Network error occurred');
      }
    }
    return Exception('Something went wrong. Please try again.');
  }
}
