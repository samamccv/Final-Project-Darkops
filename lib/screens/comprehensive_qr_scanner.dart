// lib/screens/comprehensive_qr_scanner.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/qr_content_service.dart';
import '../services/scan_service.dart';
import '../models/scan/scan_models.dart';
import '../widgets/enhanced_qr_scanner.dart';
import '../widgets/qr_result_display.dart';
import '../widgets/qr_analysis_results.dart';
import '../dashboard/qr_code_scanner.dart';

class ComprehensiveQRScanner extends StatefulWidget {
  const ComprehensiveQRScanner({super.key});

  @override
  State<ComprehensiveQRScanner> createState() => _ComprehensiveQRScannerState();
}

class _ComprehensiveQRScannerState extends State<ComprehensiveQRScanner> {
  QRContentData? scannedData;
  QRAnalysisResponse? analysisResult;
  QRPhishingAnalysisResponse? phishingResult;
  bool isAnalyzing = false;
  String? analysisError;
  final ScanService _scanService = ScanService();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final mediaQuery = MediaQuery.of(context);
    final safeAreaBottom = mediaQuery.padding.bottom;

    return Scaffold(
      backgroundColor: QRColorPalette.getBackgroundColor(isDarkMode),
      appBar: AppBar(
        backgroundColor: QRColorPalette.getBackgroundColor(isDarkMode),
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: theme.colorScheme.onSurface,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: _buildHeader(theme, isDarkMode),
        actions: [
          if (scannedData != null)
            IconButton(
              icon: const Icon(Icons.refresh),
              color: QRColorPalette.primary,
              onPressed: _resetScanner,
              tooltip: 'Scan Again',
            ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final availableHeight = constraints.maxHeight;
            final isCompactScreen = availableHeight < 600;

            return Column(
              children: [
                // Scanner Section
                Expanded(
                  flex: _getScannerFlex(isCompactScreen),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: isCompactScreen ? 8 : 16,
                    ),
                    child:
                        scannedData == null
                            ? EnhancedQRScanner(
                              onQRDetected: _onQRDetected,
                              showImageUpload: true,
                              autoAnalyze: true,
                            )
                            : _buildScannerPreview(theme, isDarkMode),
                  ),
                ),

                // Results Section
                if (scannedData != null)
                  Expanded(
                    flex: _getResultsFlex(isCompactScreen),
                    child: Container(
                      constraints: BoxConstraints(
                        maxHeight: availableHeight * 0.5,
                      ),
                      child: SingleChildScrollView(
                        padding: EdgeInsets.only(bottom: safeAreaBottom + 16),
                        child: QRResultDisplay(
                          qrData: scannedData!,
                          onScanAgain: _resetScanner,
                          showAnalysisButton:
                              scannedData!.type == QRContentType.url,
                          onAnalyze: _analyzeQRContent,
                        ),
                      ),
                    ),
                  ),

                // Analysis Results Section
                if (phishingResult != null)
                  Expanded(
                    flex: _getAnalysisFlex(isCompactScreen),
                    child: Container(
                      constraints: BoxConstraints(
                        maxHeight: availableHeight * 0.4,
                      ),
                      child: SingleChildScrollView(
                        padding: EdgeInsets.only(bottom: safeAreaBottom + 16),
                        child: QRAnalysisResults(
                          analysisResult: phishingResult!,
                          originalUrl: scannedData?.rawContent ?? '',
                          onScanAgain: _resetScanner,
                        ),
                      ),
                    ),
                  )
                else if (isAnalyzing || analysisError != null)
                  Flexible(
                    child: Container(
                      constraints: BoxConstraints(
                        maxHeight: availableHeight * 0.25,
                      ),
                      child: _buildAnalysisSection(theme, isDarkMode),
                    ),
                  ),

                // Instructions Section (when no QR is scanned)
                if (scannedData == null)
                  Expanded(
                    flex: _getInstructionsFlex(isCompactScreen),
                    child: Container(
                      constraints: BoxConstraints(
                        maxHeight: availableHeight * 0.3,
                      ),
                      child: SingleChildScrollView(
                        padding: EdgeInsets.only(bottom: safeAreaBottom + 16),
                        child: _buildInstructions(theme, isDarkMode),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  int _getScannerFlex(bool isCompactScreen) {
    if (scannedData == null) {
      return isCompactScreen ? 2 : 3;
    }
    return isCompactScreen ? 1 : 2;
  }

  int _getResultsFlex(bool isCompactScreen) {
    return isCompactScreen ? 2 : 2;
  }

  int _getAnalysisFlex(bool isCompactScreen) {
    return isCompactScreen ? 1 : 2;
  }

  int _getInstructionsFlex(bool isCompactScreen) {
    return isCompactScreen ? 1 : 1;
  }

  Widget _buildHeader(ThemeData theme, bool isDarkMode) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: QRColorPalette.getPrimaryGradient(isDarkMode),
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(
              color: QRColorPalette.getPrimaryWithOpacity(isDarkMode, 0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: QRColorPalette.getPrimaryWithOpacity(isDarkMode, 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(
            Icons.qr_code_scanner,
            color: QRColorPalette.primary,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Text(
          'QR Scanner',
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildScannerPreview(ThemeData theme, bool isDarkMode) {
    return Container(
      decoration: BoxDecoration(
        color: QRColorPalette.getSurfaceColor(isDarkMode),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: QRColorPalette.success.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: QRColorPalette.success.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                color: QRColorPalette.success,
                size: 48,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'QR Code Detected',
              style: TextStyle(
                color: theme.colorScheme.onSurface,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              QRContentService.getContentTypeDisplayName(scannedData!.type),
              style: TextStyle(
                color: QRColorPalette.success,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructions(ThemeData theme, bool isDarkMode) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: QRColorPalette.getSurfaceColor(isDarkMode),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: QRColorPalette.getPrimaryWithOpacity(isDarkMode, 0.2),
          width: 2,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.qr_code_2,
            color: QRColorPalette.primary.withValues(alpha: 0.7),
            size: 32,
          ),
          const SizedBox(height: 12),
          Text(
            'Scan QR Codes',
            style: TextStyle(
              fontSize: 18,
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Position the QR code within the camera frame or upload an image',
            style: TextStyle(
              fontSize: 14,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              _buildFeatureChip('URLs', Icons.language, theme),
              _buildFeatureChip('WiFi', Icons.wifi, theme),
              _buildFeatureChip('Contacts', Icons.contact_page, theme),
              _buildFeatureChip('Location', Icons.location_on, theme),
              _buildFeatureChip('Text', Icons.text_fields, theme),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureChip(String label, IconData icon, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: QRColorPalette.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: QRColorPalette.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: QRColorPalette.primary),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: QRColorPalette.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisSection(ThemeData theme, bool isDarkMode) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: QRColorPalette.getSurfaceColor(isDarkMode),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color:
              isAnalyzing
                  ? QRColorPalette.warning.withValues(alpha: 0.3)
                  : analysisError != null
                  ? QRColorPalette.danger.withValues(alpha: 0.3)
                  : QRColorPalette.success.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isAnalyzing
                    ? Icons.security
                    : analysisError != null
                    ? Icons.error
                    : Icons.verified_user,
                color:
                    isAnalyzing
                        ? QRColorPalette.warning
                        : analysisError != null
                        ? QRColorPalette.danger
                        : QRColorPalette.success,
              ),
              const SizedBox(width: 8),
              Text(
                isAnalyzing
                    ? 'Analyzing Security...'
                    : analysisError != null
                    ? 'Analysis Failed'
                    : 'Security Analysis',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (isAnalyzing)
            const LinearProgressIndicator(color: QRColorPalette.warning)
          else if (analysisError != null)
            Text(
              analysisError!,
              style: TextStyle(color: QRColorPalette.danger, fontSize: 14),
            )
          else if (analysisResult != null)
            Text(
              'Content Type: ${analysisResult!.contentType}\n'
              'Analysis completed successfully',
              style: TextStyle(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                fontSize: 14,
              ),
            ),
        ],
      ),
    );
  }

  void _onQRDetected(QRContentData qrData) {
    setState(() {
      scannedData = qrData;
      analysisResult = null;
      phishingResult = null;
      analysisError = null;
      isAnalyzing = false;
    });

    // Show success feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${QRContentService.getContentTypeDisplayName(qrData.type)} detected!',
        ),
        backgroundColor: QRColorPalette.success,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );

    // Auto-analyze URLs for security
    if (qrData.type == QRContentType.url) {
      Future.delayed(const Duration(milliseconds: 500), () {
        _analyzeQRContent();
      });
    }
  }

  void _resetScanner() {
    setState(() {
      scannedData = null;
      analysisResult = null;
      phishingResult = null;
      analysisError = null;
      isAnalyzing = false;
    });
  }

  Future<void> _analyzeQRContent() async {
    if (scannedData == null) return;

    setState(() {
      isAnalyzing = true;
      analysisError = null;
      phishingResult = null;
    });

    try {
      // For URLs, use phishing detection
      if (scannedData!.type == QRContentType.url) {
        final result = await _scanService.detectQRPhishing(
          scannedData!.rawContent,
        );
        setState(() {
          phishingResult = result;
          isAnalyzing = false;
        });
      } else {
        // For other content types, use general QR analysis
        final request = QRAnalysisRequest(content: scannedData!.rawContent);
        final result = await _scanService.analyzeQR(request);
        setState(() {
          analysisResult = result;
          isAnalyzing = false;
        });
      }
    } catch (e) {
      setState(() {
        analysisError = 'Failed to analyze QR content: ${e.toString()}';
        isAnalyzing = false;
      });
    }
  }
}
