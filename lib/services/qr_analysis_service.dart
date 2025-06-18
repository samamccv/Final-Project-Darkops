// lib/services/qr_analysis_service.dart
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import '../config/app_config.dart';
import 'api_seevice.dart';

/// QR Analysis progress states matching frontend
enum QRAnalysisState { detected, analyzing, phishingCheck, complete, error }

/// QR Analysis request model
class QRAnalysisRequest extends Equatable {
  final String content;
  final String contentType;

  const QRAnalysisRequest({required this.content, required this.contentType});

  Map<String, dynamic> toJson() => {
    'content': content,
    'contentType': contentType,
  };

  @override
  List<Object?> get props => [content, contentType];
}

/// Basic QR Analysis response model
class QRAnalysisResponse extends Equatable {
  final String id;
  final String content;
  final String contentType;
  final String status;
  final DateTime createdAt;

  const QRAnalysisResponse({
    required this.id,
    required this.content,
    required this.contentType,
    required this.status,
    required this.createdAt,
  });

  factory QRAnalysisResponse.fromJson(Map<String, dynamic> json) {
    return QRAnalysisResponse(
      id: json['id'] ?? '',
      content: json['content'] ?? '',
      contentType: json['contentType'] ?? '',
      status: json['status'] ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [id, content, contentType, status, createdAt];
}

/// Phishing analysis request model
class PhishingAnalysisRequest extends Equatable {
  final String url;

  const PhishingAnalysisRequest({required this.url});

  Map<String, dynamic> toJson() => {'url': url};

  @override
  List<Object?> get props => [url];
}

/// DNS information model
class DNSInfo extends Equatable {
  final List<String> aRecords;
  final List<String> mxRecords;
  final List<String> nsRecords;
  final String? txtRecord;

  const DNSInfo({
    required this.aRecords,
    required this.mxRecords,
    required this.nsRecords,
    this.txtRecord,
  });

  factory DNSInfo.fromJson(Map<String, dynamic> json) {
    return DNSInfo(
      aRecords: List<String>.from(json['aRecords'] ?? []),
      mxRecords: List<String>.from(json['mxRecords'] ?? []),
      nsRecords: List<String>.from(json['nsRecords'] ?? []),
      txtRecord: json['txtRecord'],
    );
  }

  @override
  List<Object?> get props => [aRecords, mxRecords, nsRecords, txtRecord];
}

/// Domain analysis model
class DomainAnalysis extends Equatable {
  final String domain;
  final int domainAge;
  final String registrar;
  final bool isNewDomain;
  final bool hasSuspiciousPatterns;
  final DNSInfo dnsInfo;

  const DomainAnalysis({
    required this.domain,
    required this.domainAge,
    required this.registrar,
    required this.isNewDomain,
    required this.hasSuspiciousPatterns,
    required this.dnsInfo,
  });

  factory DomainAnalysis.fromJson(Map<String, dynamic> json) {
    return DomainAnalysis(
      domain: json['domain'] ?? '',
      domainAge: json['domainAge'] ?? 0,
      registrar: json['registrar'] ?? '',
      isNewDomain: json['isNewDomain'] ?? false,
      hasSuspiciousPatterns: json['hasSuspiciousPatterns'] ?? false,
      dnsInfo: DNSInfo.fromJson(json['dnsInfo'] ?? {}),
    );
  }

  @override
  List<Object?> get props => [
    domain,
    domainAge,
    registrar,
    isNewDomain,
    hasSuspiciousPatterns,
    dnsInfo,
  ];
}

/// Phishing analysis response model
class PhishingAnalysisResponse extends Equatable {
  final String status;
  final double confidence;
  final String riskLevel;
  final List<String> indicators;
  final List<String> recommendations;
  final DomainAnalysis domainAnalysis;

  const PhishingAnalysisResponse({
    required this.status,
    required this.confidence,
    required this.riskLevel,
    required this.indicators,
    required this.recommendations,
    required this.domainAnalysis,
  });

  factory PhishingAnalysisResponse.fromJson(Map<String, dynamic> json) {
    return PhishingAnalysisResponse(
      status: json['status'] ?? '',
      confidence: (json['confidence'] ?? 0.0).toDouble(),
      riskLevel: json['riskLevel'] ?? '',
      indicators: List<String>.from(json['indicators'] ?? []),
      recommendations: List<String>.from(json['recommendations'] ?? []),
      domainAnalysis: DomainAnalysis.fromJson(json['domainAnalysis'] ?? {}),
    );
  }

  @override
  List<Object?> get props => [
    status,
    confidence,
    riskLevel,
    indicators,
    recommendations,
    domainAnalysis,
  ];
}

/// QR Analysis Service matching frontend functionality
class QRAnalysisService {
  final ApiService _apiService;

  QRAnalysisService({ApiService? apiService})
    : _apiService = apiService ?? ApiService();

  /// Analyze QR code content (basic analysis and tracking)
  Future<QRAnalysisResponse> analyzeQRCode(QRAnalysisRequest request) async {
    try {
      debugPrint('QR Analysis Service: Starting basic QR analysis');
      debugPrint('QR Analysis Service: Request data: ${request.toJson()}');
      final response = await _apiService.analyzeQRCode(request);
      debugPrint('QR Analysis Service: Basic analysis completed successfully');
      return response;
    } catch (e) {
      debugPrint('QR Analysis Service: Basic analysis failed with error: $e');
      throw _handleError(e);
    }
  }

  /// Detect phishing for URL content
  Future<PhishingAnalysisResponse> detectPhishing(
    PhishingAnalysisRequest request,
  ) async {
    try {
      debugPrint('QR Analysis Service: Starting phishing detection');
      debugPrint(
        'QR Analysis Service: Phishing request data: ${request.toJson()}',
      );
      final response = await _apiService.detectPhishing(request);
      debugPrint(
        'QR Analysis Service: Phishing detection completed successfully',
      );
      return response;
    } catch (e) {
      debugPrint(
        'QR Analysis Service: Phishing detection failed with error: $e',
      );
      throw _handleError(e);
    }
  }

  /// Content type detection matching frontend logic
  static String detectContentType(String content) {
    if (content.isEmpty) return 'text';

    final lowerContent = content.toLowerCase();

    // URL detection
    if (lowerContent.startsWith('http://') ||
        lowerContent.startsWith('https://')) {
      return 'url';
    }

    // WiFi detection
    if (lowerContent.startsWith('wifi:')) {
      return 'wifi';
    }

    // Email detection
    if (lowerContent.startsWith('mailto:') ||
        lowerContent.startsWith('matmsg:')) {
      return 'email';
    }

    // Phone detection
    if (lowerContent.startsWith('tel:')) {
      return 'phone';
    }

    // SMS detection
    if (lowerContent.startsWith('sms:') || lowerContent.startsWith('smsto:')) {
      return 'sms';
    }

    // Default to text
    return 'text';
  }

  /// Enhanced error handling with detailed logging
  Exception _handleError(dynamic error) {
    // Log the original error for debugging
    debugPrint('QR Analysis Service Error: $error');

    if (error is DioException) {
      debugPrint('DioException Type: ${error.type}');
      debugPrint('Response Status: ${error.response?.statusCode}');
      debugPrint('Response Data: ${error.response?.data}');
      debugPrint('Request Path: ${error.requestOptions.path}');

      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return Exception(
            'Connection timed out. Please check your internet connection.',
          );
        case DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode;
          final responseData = error.response?.data;
          String message = 'Server error';

          // Try to extract error message from response
          if (responseData is Map<String, dynamic>) {
            message =
                responseData['message'] ??
                responseData['error'] ??
                responseData['detail'] ??
                'Server error';
          } else if (responseData is String) {
            message = responseData;
          }

          switch (statusCode) {
            case 400:
              return Exception('Bad request: $message');
            case 401:
              debugPrint(
                '401 Unauthorized - Full response: ${error.response?.data}',
              );
              debugPrint('401 Unauthorized - Message extracted: $message');
              return Exception('Authentication failed: $message');
            case 403:
              return Exception('Access denied: $message');
            case 404:
              return Exception(
                'API endpoint not found. Please check server configuration.',
              );
            case 422:
              return Exception('Invalid data: $message');
            case 500:
              return Exception('Server error: $message');
            case 502:
              return Exception('Bad gateway. Server may be down.');
            case 503:
              return Exception('Service unavailable. Please try again later.');
            default:
              return Exception('HTTP $statusCode: $message');
          }
        case DioExceptionType.cancel:
          return Exception('Request cancelled');
        case DioExceptionType.connectionError:
          return Exception(
            'No internet connection. Please check your network.',
          );
        case DioExceptionType.unknown:
          return Exception(
            'Network error: ${error.message ?? 'Unknown error'}',
          );
        default:
          return Exception(
            'Network error occurred: ${error.message ?? 'Unknown'}',
          );
      }
    }

    // Handle other types of errors
    if (error is Exception) {
      return Exception('Analysis error: ${error.toString()}');
    }

    return Exception('Unexpected error occurred: ${error.toString()}');
  }
}
