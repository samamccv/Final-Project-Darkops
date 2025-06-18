// lib/widgets/qr_scanner/url_detection_results.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/qr_analysis_manager.dart';
import '../../services/api_seevice.dart';

/// Widget for displaying basic URL detection results with opt-in security analysis
class UrlDetectionResults extends StatefulWidget {
  final QRAnalysisResult analysisResult;
  final VoidCallback? onClose;
  final Function(QRAnalysisResult)? onSecurityAnalysisComplete;

  const UrlDetectionResults({
    super.key,
    required this.analysisResult,
    this.onClose,
    this.onSecurityAnalysisComplete,
  });

  @override
  State<UrlDetectionResults> createState() => _UrlDetectionResultsState();
}

class _UrlDetectionResultsState extends State<UrlDetectionResults> {
  bool _isAnalyzing = false;
  QRAnalysisManager? _analysisManager;

  @override
  void initState() {
    super.initState();
    _analysisManager = QRAnalysisManager(apiService: ApiService());
  }

  @override
  void dispose() {
    _analysisManager?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final contentData = widget.analysisResult.contentData;
    final url = contentData.rawContent;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.link, color: Colors.blue, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'URL Detected',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'QR code contains a web link',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.7,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (widget.onClose != null)
                  IconButton(
                    onPressed: widget.onClose,
                    icon: const Icon(Icons.close),
                  ),
              ],
            ),
          ),

          // URL Information Card
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorScheme.outline.withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'URL Information',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Text(
                        'Detected URL:',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          url,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.blue,
                            fontFamily: 'monospace',
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        onPressed: () => _copyToClipboard(context, url),
                        icon: const Icon(Icons.copy, size: 20),
                        tooltip: 'Copy URL',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Security Analysis Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.security, color: Colors.orange, size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'URL Security Analysis',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Colors.orange.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'This URL has been automatically analyzed for phishing threats. '
                    'Click below to view detailed security analysis including domain information, '
                    'risk assessment, and safety recommendations.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isAnalyzing ? null : _performSecurityAnalysis,
                      icon:
                          _isAnalyzing
                              ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    theme.colorScheme.onPrimary,
                                  ),
                                ),
                              )
                              : const Icon(Icons.security),
                      label: Text(
                        _isAnalyzing
                            ? 'Analyzing Security...'
                            : 'Scan URL for Security Analysis',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Action Buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _openUrl(context, url),
                    icon: const Icon(Icons.open_in_new),
                    label: const Text('Open URL'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _copyToClipboard(context, url),
                    icon: const Icon(Icons.copy),
                    label: const Text('Copy URL'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Future<void> _performSecurityAnalysis() async {
    if (_isAnalyzing || _analysisManager == null) return;

    setState(() {
      _isAnalyzing = true;
    });

    try {
      final securityResult = await _analysisManager!.analyzeUrlSecurity(
        widget.analysisResult,
      );

      if (mounted) {
        widget.onSecurityAnalysisComplete?.call(securityResult);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Security analysis completed successfully!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        // Check if it's an authentication error
        final errorMessage = e.toString();
        final isAuthError =
            errorMessage.contains('Authentication failed') ||
            errorMessage.contains('login again') ||
            errorMessage.contains('Unauthorized') ||
            errorMessage.contains('No Bearer token');

        if (isAuthError) {
          _showAuthenticationRequiredDialog();
        } else {
          // Show specific error message
          String displayMessage = errorMessage;
          if (displayMessage.startsWith('Exception: ')) {
            displayMessage = displayMessage.substring(11);
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Security analysis failed: $displayMessage'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 4),
              action: SnackBarAction(
                label: 'Retry',
                textColor: Colors.white,
                onPressed: _performSecurityAnalysis,
              ),
            ),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
        });
      }
    }
  }

  void _showAuthenticationRequiredDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            icon: const Icon(Icons.security, color: Colors.orange, size: 48),
            title: const Text('Login Required'),
            content: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Advanced security analysis requires authentication.',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 12),
                Text(
                  'Login to access:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text('• Comprehensive phishing detection'),
                Text('• Malware scanning'),
                Text('• Threat intelligence analysis'),
                Text('• Detailed security reports'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Maybe Later'),
              ),
              TextButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  _performBasicAnalysis();
                },
                icon: const Icon(Icons.info_outline),
                label: const Text('Basic Analysis'),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pushNamed('/login');
                },
                icon: const Icon(Icons.login),
                label: const Text('Login Now'),
              ),
            ],
          ),
    );
  }

  void _performBasicAnalysis() {
    // Provide basic URL analysis without authentication
    final url = widget.analysisResult.contentData.rawContent;
    final uri = Uri.tryParse(url);

    String analysisText = 'Basic URL Analysis:\n\n';

    if (uri != null) {
      analysisText += '• Domain: ${uri.host}\n';
      analysisText += '• Scheme: ${uri.scheme}\n';
      if (uri.port != 80 && uri.port != 443) {
        analysisText += '• Port: ${uri.port}\n';
      }

      // Basic security checks
      if (uri.scheme == 'https') {
        analysisText += '• ✅ Uses HTTPS encryption\n';
      } else {
        analysisText += '• ⚠️ Uses unencrypted HTTP\n';
      }

      // Check for suspicious patterns
      final suspiciousPatterns = [
        'bit.ly',
        'tinyurl.com',
        'short.link',
        't.co',
        'login',
        'verify',
        'secure',
        'update',
        'confirm',
      ];

      bool hasSuspiciousPattern = false;
      for (final pattern in suspiciousPatterns) {
        if (url.toLowerCase().contains(pattern)) {
          hasSuspiciousPattern = true;
          break;
        }
      }

      if (hasSuspiciousPattern) {
        analysisText += '• ⚠️ Contains potentially suspicious patterns\n';
      } else {
        analysisText += '• ✅ No obvious suspicious patterns detected\n';
      }

      analysisText +=
          '\n💡 For comprehensive security analysis including phishing detection and threat intelligence, please login.';
    } else {
      analysisText += '• ❌ Invalid URL format\n';
    }

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Basic URL Analysis'),
            content: SingleChildScrollView(child: Text(analysisText)),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pushNamed('/login');
                },
                child: const Text('Login for Full Analysis'),
              ),
            ],
          ),
    );
  }

  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('URL copied to clipboard'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _openUrl(BuildContext context, String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw Exception('Could not launch URL');
      }
    } catch (e) {
      if (mounted && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to open URL: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}
