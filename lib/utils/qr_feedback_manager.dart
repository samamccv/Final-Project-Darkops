// lib/utils/qr_feedback_manager.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/qr_content_service.dart';
import '../dashboard/qr_code_scanner.dart';

/// Manages user feedback for QR scanning operations
class QRFeedbackManager {
  /// Show success feedback for QR detection
  static void showQRDetectedFeedback(
    BuildContext context,
    QRContentData qrData, {
    Duration duration = const Duration(seconds: 3),
  }) {
    final contentTypeName = QRContentService.getContentTypeDisplayName(qrData.type);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getContentTypeIcon(qrData.type),
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$contentTypeName Detected!',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    _getTruncatedContent(qrData.rawContent),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: QRColorPalette.success,
        behavior: SnackBarBehavior.floating,
        duration: duration,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );

    // Provide haptic feedback
    HapticFeedback.mediumImpact();
  }

  /// Show error feedback for scanning failures
  static void showScanErrorFeedback(
    BuildContext context,
    String error, {
    Duration duration = const Duration(seconds: 4),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.error_outline,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Scan Failed',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    error,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: QRColorPalette.danger,
        behavior: SnackBarBehavior.floating,
        duration: duration,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        action: SnackBarAction(
          label: 'Retry',
          textColor: Colors.white,
          onPressed: () {
            // The retry action should be handled by the calling widget
          },
        ),
      ),
    );

    // Provide haptic feedback
    HapticFeedback.heavyImpact();
  }

  /// Show analysis progress feedback
  static void showAnalysisStartedFeedback(
    BuildContext context,
    String contentType, {
    Duration duration = const Duration(seconds: 2),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Analyzing $contentType for security threats...',
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
        backgroundColor: QRColorPalette.warning,
        behavior: SnackBarBehavior.floating,
        duration: duration,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  /// Show analysis completion feedback
  static void showAnalysisCompleteFeedback(
    BuildContext context,
    bool isSafe, {
    Duration duration = const Duration(seconds: 3),
  }) {
    final color = isSafe ? QRColorPalette.success : QRColorPalette.danger;
    final icon = isSafe ? Icons.verified_user : Icons.warning;
    final title = isSafe ? 'Safe Content' : 'Threat Detected';
    final message = isSafe 
        ? 'No security threats detected'
        : 'Potential security threat identified';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    message,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        duration: duration,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );

    // Provide haptic feedback
    if (isSafe) {
      HapticFeedback.lightImpact();
    } else {
      HapticFeedback.heavyImpact();
    }
  }

  /// Show permission denied feedback
  static void showPermissionDeniedFeedback(
    BuildContext context, {
    Duration duration = const Duration(seconds: 5),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(
              Icons.camera_alt_outlined,
              color: Colors.white,
              size: 20,
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Camera Permission Required',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Please grant camera permission to scan QR codes',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: QRColorPalette.warning,
        behavior: SnackBarBehavior.floating,
        duration: duration,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        action: SnackBarAction(
          label: 'Settings',
          textColor: Colors.white,
          onPressed: () {
            // Open app settings - this should be handled by the calling widget
          },
        ),
      ),
    );
  }

  /// Show copy success feedback
  static void showCopySuccessFeedback(
    BuildContext context,
    String contentType, {
    Duration duration = const Duration(seconds: 2),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.check_circle_outline,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              '$contentType copied to clipboard',
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
        backgroundColor: QRColorPalette.success,
        behavior: SnackBarBehavior.floating,
        duration: duration,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );

    HapticFeedback.lightImpact();
  }

  /// Get icon for content type
  static IconData _getContentTypeIcon(QRContentType type) {
    switch (type) {
      case QRContentType.url:
        return Icons.language;
      case QRContentType.wifi:
        return Icons.wifi;
      case QRContentType.email:
        return Icons.email;
      case QRContentType.phone:
        return Icons.phone;
      case QRContentType.sms:
        return Icons.message;
      case QRContentType.vcard:
        return Icons.contact_page;
      case QRContentType.geo:
        return Icons.location_on;
      case QRContentType.text:
        return Icons.text_fields;
      case QRContentType.unknown:
      default:
        return Icons.qr_code;
    }
  }

  /// Truncate content for display
  static String _getTruncatedContent(String content, {int maxLength = 50}) {
    if (content.length <= maxLength) return content;
    return '${content.substring(0, maxLength)}...';
  }
}
