// lib/services/scan_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/scan/scan_models.dart';
import '../config/app_config.dart';

class ScanService {
  final Dio _dio;
  final FlutterSecureStorage _storage;

  ScanService({String? baseUrl})
    : _dio = Dio(
        BaseOptions(
          baseUrl: baseUrl ?? AppConfig.baseUrl,
          connectTimeout: AppConfig.scanTimeout,
          receiveTimeout: AppConfig.scanTimeout,
          headers: AppConfig.defaultHeaders,
        ),
      ),
      _storage = const FlutterSecureStorage() {
    _setupInterceptors();
  }

  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.read(key: 'auth_token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) {
          print('Scan API Error: ${error.message}');
          handler.next(error);
        },
      ),
    );
  }

  // SMS Analysis
  Future<SMSAnalysisResponse> analyzeSMS(SMSAnalysisRequest request) async {
    try {
      final response = await _dio.post(
        '/ai/sms/detect-phishing',
        data: request.toJson(),
      );
      return SMSAnalysisResponse.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // URL Analysis
  Future<URLAnalysisResponse> analyzeURL(URLAnalysisRequest request) async {
    try {
      final response = await _dio.post(
        '/ai/url/scan-url',
        data: request.toJson(),
      );
      return URLAnalysisResponse.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // URL Full Analysis (legacy)
  Future<Map<String, dynamic>> analyzeURLFull(
    URLAnalysisRequest request,
  ) async {
    try {
      final response = await _dio.post(
        '/ai/url/full-analysis',
        data: request.toJson(),
      );
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Comprehensive URL Analysis (matches web frontend)
  Future<UrlAnalysisResponse> analyzeUrlComprehensive(String url) async {
    try {
      final response = await _dio.post(
        '/ai/url/full-analysis',
        data: {'url': url},
      );
      return UrlAnalysisResponse.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Email Analysis
  Future<EmailAnalysisResponse> analyzeEmail(File emailFile) async {
    try {
      final formData = FormData.fromMap({
        'email_file': await MultipartFile.fromFile(
          emailFile.path,
          filename: emailFile.path.split('/').last,
        ),
      });

      final response = await _dio.post(
        '/ai/email/analyze',
        data: formData,
        options: Options(headers: {'Content-Type': 'multipart/form-data'}),
      );
      return EmailAnalysisResponse.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Email Screenshot Capture
  Future<String?> captureEmailScreenshot(
    String messageId,
    File emailFile,
  ) async {
    try {
      final formData = FormData.fromMap({
        'message_id': messageId,
        'email_file': await MultipartFile.fromFile(
          emailFile.path,
          filename: emailFile.path.split('/').last,
        ),
      });

      final response = await _dio.post(
        '/ai/email/capture-screenshot',
        data: formData,
        options: Options(
          headers: {'Content-Type': 'multipart/form-data'},
          responseType: ResponseType.bytes, // Expect binary data
        ),
      );

      // Convert binary JPEG data to base64 data URL
      if (response.data != null && response.data is List<int>) {
        final bytes = response.data as List<int>;
        final base64String = base64Encode(bytes);
        return 'data:image/jpeg;base64,$base64String';
      }

      return null;
    } catch (e) {
      print('Screenshot capture failed: $e');
      return null;
    }
  }

  // QR Code Analysis
  Future<QRAnalysisResponse> analyzeQR(QRAnalysisRequest request) async {
    try {
      final response = await _dio.post(
        '/ai/qr/analyze',
        data: request.toJson(),
      );
      return QRAnalysisResponse.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // QR Code Phishing Detection (matching Frontend functionality)
  Future<QRPhishingAnalysisResponse> detectQRPhishing(String content) async {
    try {
      final response = await _dio.post(
        '/ai/qr/detect-phishing',
        data: {'content': content},
      );
      return QRPhishingAnalysisResponse.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // APK Analysis
  Future<APKAnalysisResponse> analyzeAPK(File apkFile) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          apkFile.path,
          filename: apkFile.path.split('/').last,
        ),
      });

      final response = await _dio.post(
        '/ai/apk/analyze',
        data: formData,
        options: Options(
          headers: {'Content-Type': 'multipart/form-data'},
          receiveTimeout: const Duration(
            minutes: 5,
          ), // APK analysis takes longer
        ),
      );
      return APKAnalysisResponse.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // APK Malware Detection
  Future<Map<String, dynamic>> detectAPKMalware(File apkFile) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          apkFile.path,
          filename: apkFile.path.split('/').last,
        ),
      });

      final response = await _dio.post(
        '/ai/apk/malware-detection',
        data: formData,
        options: Options(
          headers: {'Content-Type': 'multipart/form-data'},
          receiveTimeout: const Duration(minutes: 5),
        ),
      );
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Submit scan result to backend for storage
  Future<void> submitScanResult(ScanResultSubmission result) async {
    try {
      const mutation = '''
        mutation SubmitScanResult(\$input: ScanResultInput!) {
          submitScanResult(input: \$input) {
            id
            success
            message
          }
        }
      ''';

      await _dio.post(
        '/graphql',
        data: {
          'query': mutation,
          'variables': {'input': result.toJson()},
        },
      );
    } catch (e) {
      print('Failed to submit scan result: $e');
      // Don't throw error for scan result submission failures
      // The scan analysis should still succeed even if storage fails
    }
  }

  // Helper method to convert scan responses to submission format
  ScanResultSubmission _createScanSubmission({
    required String scanType,
    required String target,
    required dynamic scanResponse,
  }) {
    double threatScore = 0.0;
    String threatLevel = 'LOW';
    String sr = 'LOW';
    List<Finding> findings = [];
    double? confidence;

    // Convert different scan response types to unified format
    if (scanResponse is SMSAnalysisResponse) {
      threatScore = scanResponse.isPhishing ? 8.0 : 2.0;
      threatLevel = scanResponse.isPhishing ? 'HIGH' : 'LOW';
      sr = scanResponse.isPhishing ? 'HIGH' : 'LOW';
      confidence = scanResponse.confidence;
      findings = [
        Finding(
          type: scanResponse.isPhishing ? 'PHISHING' : 'SAFE',
          severity: threatLevel,
          description: scanResponse.prediction,
        ),
      ];
    } else if (scanResponse is URLAnalysisResponse) {
      threatScore = scanResponse.isSafe ? 2.0 : 7.0;
      threatLevel = scanResponse.isSafe ? 'LOW' : 'HIGH';
      sr = scanResponse.isSafe ? 'LOW' : 'HIGH';
      confidence = scanResponse.confidence;
      findings = [
        Finding(
          type: scanResponse.isSafe ? 'SAFE' : 'MALICIOUS',
          severity: threatLevel,
          description: scanResponse.prediction,
        ),
      ];
    } else if (scanResponse is UrlAnalysisResponse) {
      final phishingAnalysis = scanResponse.phishingAnalysis;
      final isSafe = phishingAnalysis?.isSafe ?? true;
      final analysisConfidence = phishingAnalysis?.confidence ?? 0.0;

      threatScore = isSafe ? 2.0 : 8.0;
      threatLevel = isSafe ? 'LOW' : 'HIGH';
      sr = isSafe ? 'LOW' : 'HIGH';
      confidence = analysisConfidence;
      findings = [
        Finding(
          type: isSafe ? 'SAFE' : 'MALICIOUS',
          severity: threatLevel,
          description: phishingAnalysis?.prediction ?? 'URL analyzed',
        ),
      ];
    } else if (scanResponse is QRAnalysisResponse) {
      threatScore = scanResponse.isUrl ? 5.0 : 2.0;
      threatLevel = scanResponse.isUrl ? 'MEDIUM' : 'LOW';
      sr = scanResponse.isUrl ? 'MEDIUM' : 'LOW';
      findings = [
        Finding(
          type: scanResponse.contentType,
          severity: threatLevel,
          description: 'QR Code contains: ${scanResponse.contentType}',
        ),
      ];
    } else if (scanResponse is APKAnalysisResponse) {
      threatScore = scanResponse.threatsDetected.isNotEmpty ? 9.0 : 3.0;
      threatLevel =
          scanResponse.threatsDetected.isNotEmpty ? 'CRITICAL' : 'LOW';
      sr = scanResponse.threatsDetected.isNotEmpty ? 'CRITICAL' : 'LOW';
      findings =
          scanResponse.threatsDetected
              .map(
                (threat) => Finding(
                  type: 'MALWARE',
                  severity: 'CRITICAL',
                  description: threat,
                ),
              )
              .toList();
    } else if (scanResponse is EmailAnalysisResponse) {
      final hasPhishing = scanResponse.phishingDetection.prediction != null;
      threatScore = hasPhishing ? 7.0 : 3.0;
      threatLevel = hasPhishing ? 'HIGH' : 'LOW';
      sr = hasPhishing ? 'HIGH' : 'LOW';
      findings = [
        Finding(
          type: hasPhishing ? 'PHISHING' : 'SAFE',
          severity: threatLevel,
          description:
              scanResponse.phishingDetection.prediction ?? 'Email analyzed',
        ),
      ];
    }

    return ScanResultSubmission(
      scanType: scanType,
      target: target,
      threatScore: threatScore,
      threatLevel: threatLevel,
      sr: sr,
      findings: findings,
      confidence: confidence,
    );
  }

  // Convenience methods that include result submission
  Future<SMSAnalysisResponse> analyzeSMSWithSubmission(String message) async {
    final request = SMSAnalysisRequest(message: message);
    final response = await analyzeSMS(request);

    final submission = _createScanSubmission(
      scanType: 'SMS',
      target: message,
      scanResponse: response,
    );
    await submitScanResult(submission);

    return response;
  }

  Future<URLAnalysisResponse> analyzeURLWithSubmission(String url) async {
    final request = URLAnalysisRequest(url: url);
    final response = await analyzeURL(request);

    final submission = _createScanSubmission(
      scanType: 'URL',
      target: url,
      scanResponse: response,
    );
    await submitScanResult(submission);

    return response;
  }

  Future<UrlAnalysisResponse> analyzeUrlComprehensiveWithSubmission(
    String url,
  ) async {
    final response = await analyzeUrlComprehensive(url);

    final submission = _createScanSubmission(
      scanType: 'URL',
      target: url,
      scanResponse: response,
    );
    await submitScanResult(submission);

    return response;
  }

  Future<EmailAnalysisResponse> analyzeEmailWithSubmission(
    File emailFile,
  ) async {
    final response = await analyzeEmail(emailFile);

    final submission = _createScanSubmission(
      scanType: 'EMAIL',
      target: emailFile.path.split('/').last,
      scanResponse: response,
    );
    await submitScanResult(submission);

    return response;
  }

  Exception _handleError(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return Exception('Analysis timed out. Please try again.');
        case DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode;
          final message = error.response?.data?['message'] ?? 'Analysis failed';
          return Exception('Analysis failed: $message (Status: $statusCode)');
        case DioExceptionType.connectionError:
          return Exception(
            'No internet connection. Please check your network.',
          );
        default:
          return Exception('Analysis failed. Please try again.');
      }
    }
    return Exception('Something went wrong during analysis.');
  }
}
