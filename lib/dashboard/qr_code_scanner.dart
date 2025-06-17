import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// QR Feature Color Palette
class QRColorPalette {
  static const Color primary = Color(0xFF6366F1); // Indigo (99, 102, 241)
  static const Color primaryLight = Color(0xFF818CF8); // Lighter indigo
  static const Color primaryDark = Color(0xFF4F46E5); // Darker indigo

  // Light mode colors
  static const Color lightBackground = Color(0xFFFAFAFF);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSecondary = Color(0xFFF1F2FF);

  // Dark mode colors
  static const Color darkBackground = Color(0xFF0F1019);
  static const Color darkSurface = Color(0xFF1E1B2E);
  static const Color darkSecondary = Color(0xFF2D2A3E);

  // Accent colors for different states
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFEF4444);

  static Color getPrimaryColor(bool isDarkMode) => primary;
  static Color getBackgroundColor(bool isDarkMode) =>
      isDarkMode ? darkBackground : lightBackground;
  static Color getSurfaceColor(bool isDarkMode) =>
      isDarkMode ? darkSurface : lightSurface;
  static Color getSecondaryColor(bool isDarkMode) =>
      isDarkMode ? darkSecondary : lightSecondary;

  static Color getPrimaryWithOpacity(bool isDarkMode, double opacity) {
    return primary.withValues(alpha: opacity);
  }

  static LinearGradient getPrimaryGradient(bool isDarkMode) {
    return LinearGradient(
      colors: [
        primary.withValues(alpha: 0.15),
        primary.withValues(alpha: 0.08),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }
}

class QRScannerPage extends StatefulWidget {
  const QRScannerPage({super.key});

  @override
  State<QRScannerPage> createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage> {
  MobileScannerController controller = MobileScannerController();
  String? scannedResult;
  bool hasScanned = false;
  bool isCameraActive = true;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: QRColorPalette.getBackgroundColor(isDarkMode),
      appBar: AppBar(
        backgroundColor: QRColorPalette.getBackgroundColor(isDarkMode),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: _buildHeader(theme, isDarkMode),
        actions: [
          IconButton(
            icon: Icon(
              isCameraActive ? Icons.pause_rounded : Icons.play_arrow_rounded,
              color: QRColorPalette.primary,
            ),
            onPressed: () {
              setState(() {
                isCameraActive = !isCameraActive;
                if (isCameraActive) {
                  controller.start();
                } else {
                  controller.stop();
                }
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Camera Section
          Expanded(
            flex: 4,
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: QRColorPalette.getPrimaryWithOpacity(isDarkMode, 0.3),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: QRColorPalette.getPrimaryWithOpacity(
                      isDarkMode,
                      0.1,
                    ),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Stack(
                  children: [
                    if (isCameraActive)
                      MobileScanner(controller: controller, onDetect: _onDetect)
                    else
                      Container(
                        color: QRColorPalette.getSecondaryColor(isDarkMode),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  gradient: QRColorPalette.getPrimaryGradient(
                                    isDarkMode,
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.qr_code_2_outlined,
                                  color: QRColorPalette.primary,
                                  size: 48,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Camera Paused',
                                style: TextStyle(
                                  color: colorScheme.onSurface,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Tap play to resume scanning',
                                style: TextStyle(
                                  color: colorScheme.onSurface.withValues(
                                    alpha: 0.6,
                                  ),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    // QR Code overlay
                    if (isCameraActive)
                      Center(
                            child: Container(
                              width: 250,
                              height: 250,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: QRColorPalette.primary,
                                  width: 3,
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Stack(
                                children: [
                                  // Corner indicators
                                  ...List.generate(4, (index) {
                                    return Positioned(
                                      left: index % 2 == 0 ? 0 : null,
                                      right: index % 2 == 1 ? 0 : null,
                                      top: index < 2 ? 0 : null,
                                      bottom: index >= 2 ? 0 : null,
                                      child: Container(
                                        width: 30,
                                        height: 30,
                                        decoration: BoxDecoration(
                                          color: QRColorPalette.primary,
                                          borderRadius: BorderRadius.only(
                                            topLeft:
                                                index == 0
                                                    ? const Radius.circular(20)
                                                    : Radius.zero,
                                            topRight:
                                                index == 1
                                                    ? const Radius.circular(20)
                                                    : Radius.zero,
                                            bottomLeft:
                                                index == 2
                                                    ? const Radius.circular(20)
                                                    : Radius.zero,
                                            bottomRight:
                                                index == 3
                                                    ? const Radius.circular(20)
                                                    : Radius.zero,
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                                ],
                              ),
                            ),
                          )
                          .animate(onPlay: (controller) => controller.repeat())
                          .shimmer(
                            duration: 2000.ms,
                            color: QRColorPalette.primary.withValues(
                              alpha: 0.3,
                            ),
                          ),
                  ],
                ),
              ),
            ),
          ),

          // Result Section
          Expanded(
            flex: 1,
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: QRColorPalette.getSurfaceColor(isDarkMode),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color:
                      scannedResult != null
                          ? QRColorPalette.success.withValues(alpha: 0.3)
                          : QRColorPalette.getPrimaryWithOpacity(
                            isDarkMode,
                            0.2,
                          ),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color:
                        scannedResult != null
                            ? QRColorPalette.success.withValues(alpha: 0.1)
                            : QRColorPalette.getPrimaryWithOpacity(
                              isDarkMode,
                              0.1,
                            ),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child:
                  scannedResult != null
                      ? _buildResultDisplay(theme, isDarkMode)
                      : _buildScanningPrompt(theme, isDarkMode),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, bool isDarkMode) {
    final colorScheme = theme.colorScheme;

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
          child: Icon(
            Icons.qr_code_2_outlined,
            color: QRColorPalette.primary,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Text(
          'QR Scanner',
          style: TextStyle(
            color: colorScheme.onSurface,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildScanningPrompt(ThemeData theme, bool isDarkMode) {
    final colorScheme = theme.colorScheme;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.qr_code_scanner_rounded,
          color: QRColorPalette.primary,
          size: 32,
        ),
        const SizedBox(height: 12),
        Text(
          isCameraActive
              ? 'Position QR code within the frame'
              : 'Camera is paused',
          style: TextStyle(
            fontSize: 16,
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          isCameraActive
              ? 'The QR code will be scanned automatically'
              : 'Tap the play button to resume scanning',
          style: TextStyle(
            fontSize: 14,
            color: colorScheme.onSurface.withValues(alpha: 0.6),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildResultDisplay(ThemeData theme, bool isDarkMode) {
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: QRColorPalette.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.check_circle_outline_rounded,
                color: QRColorPalette.success,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'QR Code Detected',
                    style: TextStyle(
                      fontSize: 16,
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'Successfully scanned',
                    style: TextStyle(
                      fontSize: 12,
                      color: QRColorPalette.success,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: QRColorPalette.getPrimaryWithOpacity(isDarkMode, 0.05),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: QRColorPalette.getPrimaryWithOpacity(isDarkMode, 0.1),
            ),
          ),
          child: Text(
            scannedResult ?? '',
            style: TextStyle(
              fontSize: 14,
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w500,
              fontFamily: 'monospace',
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  void _onDetect(BarcodeCapture capture) {
    final List<Barcode> barcodes = capture.barcodes;
    if (!hasScanned && barcodes.isNotEmpty && isCameraActive) {
      hasScanned = true;
      final String? code = barcodes.first.rawValue;

      setState(() {
        scannedResult = code;
        isCameraActive = false;
      });

      controller.stop();

      // Show success feedback
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'QR Code scanned: ${code?.substring(0, 30) ?? ''}${(code?.length ?? 0) > 30 ? '...' : ''}',
          ),
          backgroundColor: QRColorPalette.success,
          behavior: SnackBarBehavior.floating,
        ),
      );

      // Auto navigate after a short delay
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          Navigator.pop(context, scannedResult);
        }
      });
    }
  }
}
