// lib/services/qr_analysis_manager.dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'qr_analysis_service.dart';
import 'qr_content_service.dart';
import 'api_seevice.dart';

/// QR Analysis progress model
class QRAnalysisProgress {
  final QRAnalysisState state;
  final double progress;
  final String message;
  final String? error;

  const QRAnalysisProgress({
    required this.state,
    required this.progress,
    required this.message,
    this.error,
  });

  QRAnalysisProgress copyWith({
    QRAnalysisState? state,
    double? progress,
    String? message,
    String? error,
  }) {
    return QRAnalysisProgress(
      state: state ?? this.state,
      progress: progress ?? this.progress,
      message: message ?? this.message,
      error: error ?? this.error,
    );
  }
}

/// Complete QR analysis result
class QRAnalysisResult {
  final QRContentData contentData;
  final QRAnalysisResponse? basicAnalysis;
  final PhishingAnalysisResponse? phishingAnalysis;
  final bool isComplete;
  final String? error;

  const QRAnalysisResult({
    required this.contentData,
    this.basicAnalysis,
    this.phishingAnalysis,
    required this.isComplete,
    this.error,
  });

  bool get isUrl => contentData.type == QRContentType.url;
  bool get hasPhishingAnalysis => phishingAnalysis != null;
  bool get hasError => error != null;
}

/// QR Analysis Manager - orchestrates the complete analysis workflow
class QRAnalysisManager extends ChangeNotifier {
  final QRAnalysisService _analysisService;

  QRAnalysisProgress? _currentProgress;
  QRAnalysisResult? _currentResult;
  StreamController<QRAnalysisProgress>? _progressController;

  QRAnalysisManager({
    QRAnalysisService? analysisService,
    ApiService? apiService,
  }) : _analysisService =
           analysisService ?? QRAnalysisService(apiService: apiService);

  QRAnalysisProgress? get currentProgress => _currentProgress;
  QRAnalysisResult? get currentResult => _currentResult;

  /// Start basic QR analysis workflow (without automatic URL security analysis)
  Future<QRAnalysisResult> analyzeQRCode(String content) async {
    _progressController = StreamController<QRAnalysisProgress>.broadcast();

    try {
      // Step 1: QR code detected (10%)
      _updateProgress(QRAnalysisState.detected, 0.1, 'QR code detected');
      await Future.delayed(const Duration(milliseconds: 300));

      // Step 2: Analyze content type (30%)
      _updateProgress(QRAnalysisState.analyzing, 0.3, 'Analyzing content type');
      final contentData = QRContentService.parseContent(content);
      await Future.delayed(const Duration(milliseconds: 500));

      // Step 3: Determine content category (50%)
      _updateProgress(
        QRAnalysisState.analyzing,
        0.5,
        'Determining content category',
      );
      final contentType = QRAnalysisService.detectContentType(content);
      await Future.delayed(const Duration(milliseconds: 300));

      QRAnalysisResponse? basicAnalysis;

      // Step 4: Basic analysis and tracking (90%)
      _updateProgress(
        QRAnalysisState.analyzing,
        0.9,
        'Performing basic analysis',
      );
      try {
        basicAnalysis = await _analysisService.analyzeQRCode(
          QRAnalysisRequest(content: content, contentType: contentType),
        );
      } catch (e) {
        debugPrint('Basic analysis failed: $e');
        // Continue with local analysis even if API fails
      }
      await Future.delayed(const Duration(milliseconds: 500));

      // Step 5: Complete basic analysis (100%)
      _updateProgress(QRAnalysisState.complete, 1.0, 'Analysis complete');

      final result = QRAnalysisResult(
        contentData: contentData,
        basicAnalysis: basicAnalysis,
        phishingAnalysis: null, // No automatic phishing analysis
        isComplete: true,
      );

      _currentResult = result;
      notifyListeners();
      return result;
    } catch (e) {
      final error = 'Analysis failed: ${e.toString()}';
      _updateProgress(QRAnalysisState.error, 0.0, error);

      final result = QRAnalysisResult(
        contentData: QRContentService.parseContent(content),
        isComplete: false,
        error: error,
      );

      _currentResult = result;
      notifyListeners();
      return result;
    } finally {
      _progressController?.close();
      _progressController = null;
    }
  }

  /// Perform comprehensive URL security analysis (opt-in)
  Future<QRAnalysisResult> analyzeUrlSecurity(
    QRAnalysisResult basicResult,
  ) async {
    if (!basicResult.isUrl) {
      throw Exception('Content is not a URL');
    }

    _progressController = StreamController<QRAnalysisProgress>.broadcast();

    try {
      final content = basicResult.contentData.rawContent;

      // Step 1: Starting security analysis (10%)
      _updateProgress(
        QRAnalysisState.phishingCheck,
        0.1,
        'Starting security analysis',
      );
      await Future.delayed(const Duration(milliseconds: 300));

      // Step 2: Checking for phishing threats (50%)
      _updateProgress(
        QRAnalysisState.phishingCheck,
        0.5,
        'Checking for phishing threats',
      );
      PhishingAnalysisResponse? phishingAnalysis;

      try {
        debugPrint('Starting phishing analysis for URL: $content');
        phishingAnalysis = await _analysisService.detectPhishing(
          PhishingAnalysisRequest(url: content),
        );
        debugPrint('Phishing analysis completed successfully');
      } catch (e) {
        debugPrint('Phishing analysis failed: $e');
        // Extract the actual error message instead of wrapping it
        String errorMessage = e.toString();
        if (errorMessage.startsWith('Exception: ')) {
          errorMessage = errorMessage.substring(
            11,
          ); // Remove "Exception: " prefix
        }
        throw Exception(errorMessage);
      }

      await Future.delayed(const Duration(milliseconds: 800));

      // Step 3: Analyzing security threats (80%)
      _updateProgress(
        QRAnalysisState.phishingCheck,
        0.8,
        'Analyzing security threats',
      );
      await Future.delayed(const Duration(milliseconds: 500));

      // Step 4: Complete security analysis (100%)
      _updateProgress(
        QRAnalysisState.complete,
        1.0,
        'Security analysis complete',
      );
      await Future.delayed(const Duration(milliseconds: 300));

      final result = QRAnalysisResult(
        contentData: basicResult.contentData,
        basicAnalysis: basicResult.basicAnalysis,
        phishingAnalysis: phishingAnalysis,
        isComplete: true,
      );

      _currentResult = result;
      notifyListeners();

      return result;
    } catch (e) {
      final errorMessage = 'Analysis failed: ${e.toString()}';
      _updateProgress(QRAnalysisState.error, 0.0, errorMessage);

      final errorResult = QRAnalysisResult(
        contentData: basicResult.contentData,
        basicAnalysis: basicResult.basicAnalysis,
        isComplete: false,
        error: errorMessage,
      );

      _currentResult = errorResult;
      notifyListeners();

      return errorResult;
    } finally {
      _progressController?.close();
      _progressController = null;
    }
  }

  /// Get progress stream for real-time updates
  Stream<QRAnalysisProgress>? get progressStream => _progressController?.stream;

  /// Update progress and notify listeners
  void _updateProgress(
    QRAnalysisState state,
    double progress,
    String message, [
    String? error,
  ]) {
    _currentProgress = QRAnalysisProgress(
      state: state,
      progress: progress,
      message: message,
      error: error,
    );

    _progressController?.add(_currentProgress!);
    notifyListeners();
  }

  /// Clear current analysis
  void clearAnalysis() {
    _currentProgress = null;
    _currentResult = null;
    _progressController?.close();
    _progressController = null;
    notifyListeners();
  }

  /// Get risk level color for UI display
  static String getRiskLevelColor(String riskLevel) {
    switch (riskLevel.toLowerCase()) {
      case 'low':
        return '#4CAF50'; // Green
      case 'medium':
        return '#FF9800'; // Orange
      case 'high':
        return '#F44336'; // Red
      case 'critical':
        return '#9C27B0'; // Purple
      default:
        return '#757575'; // Grey
    }
  }

  /// Get status icon for UI display
  static String getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'safe':
        return 'check_circle';
      case 'suspicious':
        return 'warning';
      case 'malicious':
        return 'dangerous';
      case 'phishing':
        return 'phishing';
      default:
        return 'help_outline';
    }
  }

  /// Format confidence percentage
  static String formatConfidence(double confidence) {
    return '${(confidence * 100).toStringAsFixed(1)}%';
  }

  /// Get progress message for state
  static String getProgressMessage(QRAnalysisState state, double progress) {
    switch (state) {
      case QRAnalysisState.detected:
        return 'QR code detected';
      case QRAnalysisState.analyzing:
        if (progress <= 0.3) return 'Analyzing content type';
        if (progress <= 0.5) return 'Determining content category';
        if (progress <= 0.7) return 'Performing basic analysis';
        return 'Processing content';
      case QRAnalysisState.phishingCheck:
        if (progress <= 0.8) return 'Checking for phishing threats';
        return 'Analyzing security threats';
      case QRAnalysisState.complete:
        return 'Analysis complete';
      case QRAnalysisState.error:
        return 'Analysis failed';
    }
  }

  @override
  void dispose() {
    _progressController?.close();
    super.dispose();
  }
}
