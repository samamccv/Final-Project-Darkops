// lib/widgets/enhanced_qr_scanner.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/qr_content_service.dart';
import '../dashboard/qr_code_scanner.dart';

class EnhancedQRScanner extends StatefulWidget {
  final Function(QRContentData) onQRDetected;
  final bool showImageUpload;
  final bool autoAnalyze;

  const EnhancedQRScanner({
    super.key,
    required this.onQRDetected,
    this.showImageUpload = true,
    this.autoAnalyze = true,
  });

  @override
  State<EnhancedQRScanner> createState() => _EnhancedQRScannerState();
}

class _EnhancedQRScannerState extends State<EnhancedQRScanner> {
  MobileScannerController controller = MobileScannerController();
  bool hasScanned = false;
  bool isCameraActive = true;
  bool isFlashOn = false;
  bool isFrontCamera = false;
  String? lastScannedCode;
  final ImagePicker _imagePicker = ImagePicker();

  // Platform-specific performance settings
  bool get _isLowEndDevice => Platform.isAndroid;
  bool get _shouldReduceAnimations => _isLowEndDevice;
  Duration get _animationDuration => _shouldReduceAnimations ? 200.ms : 300.ms;

  @override
  void initState() {
    super.initState();
    _checkCameraPermission();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> _checkCameraPermission() async {
    final status = await Permission.camera.status;
    if (status.isDenied) {
      await Permission.camera.request();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24), // More rounded for Material 3
        border: Border.all(
          color: QRColorPalette.getPrimaryWithOpacity(isDarkMode, 0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 12),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: QRColorPalette.getPrimaryWithOpacity(isDarkMode, 0.05),
            blurRadius: 40,
            offset: const Offset(0, 20),
            spreadRadius: -8,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Container(
          decoration: BoxDecoration(
            color: QRColorPalette.getSurfaceColor(isDarkMode),
            borderRadius: BorderRadius.circular(22),
          ),
          child: Stack(
            children: [
              // Camera view or placeholder
              if (isCameraActive)
                MobileScanner(controller: controller, onDetect: _onDetect)
              else
                _buildCameraPausedState(theme, isDarkMode, colorScheme),

              // QR Code overlay with animation
              if (isCameraActive) _buildScanningOverlay(isDarkMode),

              // Control buttons
              _buildControlButtons(theme, isDarkMode),

              // Upload button (if enabled)
              if (widget.showImageUpload) _buildUploadButton(theme, isDarkMode),

              // Status indicator
              if (hasScanned) _buildSuccessIndicator(colorScheme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCameraPausedState(
    ThemeData theme,
    bool isDarkMode,
    ColorScheme colorScheme,
  ) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            QRColorPalette.getSecondaryColor(isDarkMode),
            QRColorPalette.getSecondaryColor(isDarkMode).withValues(alpha: 0.8),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: QRColorPalette.getPrimaryGradient(isDarkMode),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: QRColorPalette.primary.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(
                Icons.qr_code_scanner_rounded,
                color: Colors.white,
                size: 52,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Camera Paused',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the play button to resume scanning',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.7),
                letterSpacing: 0.1,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessIndicator(ColorScheme colorScheme) {
    return Positioned(
          top: 20,
          left: 20,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: QRColorPalette.success,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: QRColorPalette.success.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check_circle_rounded,
                  color: Colors.white,
                  size: 18,
                ),
                const SizedBox(width: 6),
                Text(
                  'Detected',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        )
        .animate()
        .scale(
          begin: const Offset(0.8, 0.8),
          duration: 300.ms,
          curve: Curves.elasticOut,
        )
        .fadeIn(duration: 200.ms);
  }

  Widget _buildScanningOverlay(bool isDarkMode) {
    return Center(
          child: SizedBox(
            width: 280,
            height: 280,
            child: Stack(
              children: [
                // Main scanning frame with gradient border
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.transparent, width: 0),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      gradient: LinearGradient(
                        colors: [
                          QRColorPalette.primary.withValues(alpha: 0.8),
                          QRColorPalette.primaryLight.withValues(alpha: 0.6),
                          QRColorPalette.primary.withValues(alpha: 0.8),
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ),
                    ),
                    child: Container(
                      margin: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(22),
                        color: Colors.transparent,
                      ),
                    ),
                  ),
                ),

                // Animated scanning line
                Positioned.fill(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Stack(
                          children: [
                            Container(
                              height: 3,
                              margin: const EdgeInsets.symmetric(
                                horizontal: 24,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(2),
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.transparent,
                                    QRColorPalette.primary.withValues(
                                      alpha: 0.3,
                                    ),
                                    QRColorPalette.primary,
                                    QRColorPalette.primaryLight,
                                    QRColorPalette.primary,
                                    QRColorPalette.primary.withValues(
                                      alpha: 0.3,
                                    ),
                                    Colors.transparent,
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: QRColorPalette.primary.withValues(
                                      alpha: 0.5,
                                    ),
                                    blurRadius: 8,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .animate(onPlay: (controller) => controller.repeat())
                    .moveY(
                      begin: -140,
                      end: 140,
                      duration: _shouldReduceAnimations ? 2000.ms : 2500.ms,
                      curve: Curves.easeInOut,
                    ),

                // Enhanced corner indicators
                ...List.generate(4, (index) {
                  return Positioned(
                    left: index % 2 == 0 ? -2 : null,
                    right: index % 2 == 1 ? -2 : null,
                    top: index < 2 ? -2 : null,
                    bottom: index >= 2 ? -2 : null,
                    child: _buildCornerIndicator(index),
                  );
                }),

                // Center guide dot
                Center(
                  child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: QRColorPalette.primary.withValues(alpha: 0.6),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: QRColorPalette.primary.withValues(
                                alpha: 0.3,
                              ),
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                      )
                      .animate(onPlay: (controller) => controller.repeat())
                      .scale(
                        begin: const Offset(0.8, 0.8),
                        end: const Offset(1.2, 1.2),
                        duration: 1500.ms,
                        curve: Curves.easeInOut,
                      )
                      .then()
                      .scale(
                        begin: const Offset(1.2, 1.2),
                        end: const Offset(0.8, 0.8),
                        duration: 1500.ms,
                        curve: Curves.easeInOut,
                      ),
                ),
              ],
            ),
          ),
        )
        .animate(onPlay: (controller) => controller.repeat())
        .shimmer(
          duration: _shouldReduceAnimations ? 2000.ms : 3000.ms,
          color: QRColorPalette.primary.withValues(
            alpha: _shouldReduceAnimations ? 0.05 : 0.1,
          ),
        );
  }

  Widget _buildCornerIndicator(int index) {
    return SizedBox(
          width: 40,
          height: 40,
          child: Stack(
            children: [
              // Outer glow
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft:
                        index == 0 ? const Radius.circular(24) : Radius.zero,
                    topRight:
                        index == 1 ? const Radius.circular(24) : Radius.zero,
                    bottomLeft:
                        index == 2 ? const Radius.circular(24) : Radius.zero,
                    bottomRight:
                        index == 3 ? const Radius.circular(24) : Radius.zero,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: QRColorPalette.primary.withValues(alpha: 0.3),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
              // Inner indicator
              Container(
                width: 32,
                height: 32,
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: QRColorPalette.primary,
                  borderRadius: BorderRadius.only(
                    topLeft:
                        index == 0 ? const Radius.circular(20) : Radius.zero,
                    topRight:
                        index == 1 ? const Radius.circular(20) : Radius.zero,
                    bottomLeft:
                        index == 2 ? const Radius.circular(20) : Radius.zero,
                    bottomRight:
                        index == 3 ? const Radius.circular(20) : Radius.zero,
                  ),
                ),
              ),
            ],
          ),
        )
        .animate(onPlay: (controller) => controller.repeat())
        .scale(
          begin: const Offset(0.9, 0.9),
          end: const Offset(1.1, 1.1),
          duration: 2000.ms,
          curve: Curves.easeInOut,
        )
        .then()
        .scale(
          begin: const Offset(1.1, 1.1),
          end: const Offset(0.9, 0.9),
          duration: 2000.ms,
          curve: Curves.easeInOut,
        );
  }

  Widget _buildControlButtons(ThemeData theme, bool isDarkMode) {
    return Positioned(
      top: 20,
      right: 20,
      child: Column(
        children: [
          // Play/Pause button
          _buildControlButton(
                icon:
                    isCameraActive
                        ? Icons.pause_rounded
                        : Icons.play_arrow_rounded,
                onPressed: _toggleCamera,
                theme: theme,
                isDarkMode: isDarkMode,
                isActive: true,
              )
              .animate()
              .scale(
                begin: const Offset(0.8, 0.8),
                duration: 300.ms,
                curve: Curves.elasticOut,
              )
              .fadeIn(duration: 200.ms),

          const SizedBox(height: 12),

          // Flash button
          if (isCameraActive)
            _buildControlButton(
                  icon:
                      isFlashOn
                          ? Icons.flash_on_rounded
                          : Icons.flash_off_rounded,
                  onPressed: _toggleFlash,
                  theme: theme,
                  isDarkMode: isDarkMode,
                  isActive: isFlashOn,
                )
                .animate()
                .slideX(begin: 1.0, duration: 400.ms, curve: Curves.easeOutBack)
                .fadeIn(duration: 300.ms),

          if (isCameraActive) const SizedBox(height: 12),

          // Camera switch button
          if (isCameraActive)
            _buildControlButton(
                  icon: Icons.flip_camera_ios_rounded,
                  onPressed: _switchCamera,
                  theme: theme,
                  isDarkMode: isDarkMode,
                  isActive: false,
                )
                .animate()
                .slideX(begin: 1.0, duration: 500.ms, curve: Curves.easeOutBack)
                .fadeIn(duration: 400.ms),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onPressed,
    required ThemeData theme,
    required bool isDarkMode,
    bool isActive = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color:
            isActive
                ? QRColorPalette.primary.withValues(alpha: 0.15)
                : QRColorPalette.getSurfaceColor(
                  isDarkMode,
                ).withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color:
              isActive
                  ? QRColorPalette.primary.withValues(alpha: 0.4)
                  : QRColorPalette.getPrimaryWithOpacity(isDarkMode, 0.15),
          width: isActive ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color:
                isActive
                    ? QRColorPalette.primary.withValues(alpha: 0.2)
                    : Colors.black.withValues(alpha: 0.08),
            blurRadius: isActive ? 12 : 8,
            offset: const Offset(0, 4),
            spreadRadius: isActive ? 1 : 0,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onPressed,
          child: Container(
            padding: const EdgeInsets.all(12),
            constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
            child: Icon(
              icon,
              color:
                  isActive
                      ? QRColorPalette.primary
                      : QRColorPalette.primary.withValues(alpha: 0.8),
              size: 24,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUploadButton(ThemeData theme, bool isDarkMode) {
    return Positioned(
      bottom: 20,
      left: 20,
      child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  QRColorPalette.primary.withValues(alpha: 0.1),
                  QRColorPalette.primaryLight.withValues(alpha: 0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: QRColorPalette.primary.withValues(alpha: 0.2),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: QRColorPalette.primary.withValues(alpha: 0.1),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: _pickImageFromGallery,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  constraints: const BoxConstraints(
                    minWidth: 48,
                    minHeight: 48,
                  ),
                  child: const Icon(
                    Icons.photo_library_rounded,
                    color: QRColorPalette.primary,
                    size: 24,
                  ),
                ),
              ),
            ),
          )
          .animate()
          .scale(
            begin: const Offset(0.8, 0.8),
            duration: 400.ms,
            curve: Curves.elasticOut,
          )
          .slideY(begin: 1.0, duration: 500.ms, curve: Curves.easeOutBack)
          .fadeIn(duration: 300.ms),
    );
  }

  void _toggleCamera() {
    // Platform-specific haptic feedback
    if (Platform.isIOS) {
      HapticFeedback.lightImpact();
    } else {
      HapticFeedback.selectionClick();
    }

    setState(() {
      isCameraActive = !isCameraActive;
      if (isCameraActive) {
        controller.start();
        hasScanned = false; // Reset scan state when resuming
      } else {
        controller.stop();
      }
    });

    // Show feedback snackbar with platform-appropriate duration
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isCameraActive ? 'Camera resumed' : 'Camera paused'),
        backgroundColor: QRColorPalette.primary,
        behavior: SnackBarBehavior.floating,
        duration: Duration(milliseconds: _shouldReduceAnimations ? 800 : 1000),
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _toggleFlash() {
    // Platform-specific haptic feedback
    if (Platform.isIOS) {
      HapticFeedback.selectionClick();
    } else {
      HapticFeedback.lightImpact();
    }

    setState(() {
      isFlashOn = !isFlashOn;
      controller.toggleTorch();
    });

    // Show feedback snackbar with platform-appropriate styling
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isFlashOn ? 'Flash enabled' : 'Flash disabled'),
        backgroundColor: isFlashOn ? Colors.amber : QRColorPalette.primary,
        behavior: SnackBarBehavior.floating,
        duration: Duration(milliseconds: _shouldReduceAnimations ? 800 : 1000),
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _switchCamera() {
    // Platform-specific haptic feedback
    if (Platform.isIOS) {
      HapticFeedback.mediumImpact();
    } else {
      HapticFeedback.heavyImpact();
    }

    controller.switchCamera();
    setState(() {
      isFrontCamera = !isFrontCamera;
    });

    // Show feedback snackbar with platform-appropriate styling
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Switched to ${isFrontCamera ? 'front' : 'back'} camera'),
        backgroundColor: QRColorPalette.primary,
        behavior: SnackBarBehavior.floating,
        duration: Duration(milliseconds: _shouldReduceAnimations ? 800 : 1000),
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 100,
      );

      if (image != null) {
        // For now, show a message that image scanning is not yet implemented
        // In a full implementation, you would use a QR code detection library
        // that can process static images
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Image QR scanning will be implemented in a future update',
              ),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _onDetect(BarcodeCapture capture) {
    final List<Barcode> barcodes = capture.barcodes;
    if (!hasScanned && barcodes.isNotEmpty && isCameraActive) {
      final String? code = barcodes.first.rawValue;

      if (code != null && code != lastScannedCode) {
        hasScanned = true;
        lastScannedCode = code;

        // Parse the QR content
        final qrData = QRContentService.parseContent(code);

        // Platform-specific haptic feedback for successful scan
        if (Platform.isIOS) {
          HapticFeedback.heavyImpact();
        } else {
          HapticFeedback.mediumImpact();
        }

        // Call the callback
        widget.onQRDetected(qrData);

        // Reset scan state after a delay to allow for new scans
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            setState(() {
              hasScanned = false;
            });
          }
        });
      }
    }
  }
}
