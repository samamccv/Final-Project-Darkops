import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/scan_service.dart';
import 'url_analysis_results.dart';

/// URL Feature Color Palette
class URLColorPalette {
  static const Color primary = Color(0xFFF59E0B); // Orange (245, 158, 11)
  static const Color primaryLight = Color(0xFFFBBF24); // Lighter orange
  static const Color primaryDark = Color(0x00ed8936); // Darker orange

  // Light mode colors
  static const Color lightBackground = Color(0xFFFFFBF5);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSecondary = Color(0xFFFEF3C7);

  // Dark mode colors
  static const Color darkBackground = Color(0xFF1C1917);
  static const Color darkSurface = Color(0xFF292524);
  static const Color darkSecondary = Color(0xFF44403C);

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

class URLScannerPage extends StatefulWidget {
  const URLScannerPage({super.key});

  @override
  State<URLScannerPage> createState() => _URLScannerPageState();
}

class _URLScannerPageState extends State<URLScannerPage> {
  final TextEditingController _controller = TextEditingController();
  final ScanService _scanService = ScanService();
  bool _isAnalyzing = false;
  String? _error;

  bool _validateUrl(String url) {
    try {
      Uri.parse(url);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> _scanURL() async {
    final url = _controller.text.trim();

    if (url.isEmpty) {
      setState(() {
        _error = 'Please enter a URL';
      });
      return;
    }

    // Add https:// if protocol is missing
    String urlToScan = url;
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      urlToScan = 'https://$url';
    }

    if (!_validateUrl(urlToScan)) {
      setState(() {
        _error = 'Please enter a valid URL';
      });
      return;
    }

    setState(() {
      _error = null;
      _isAnalyzing = true;
    });

    try {
      final results = await _scanService.analyzeUrlComprehensiveWithSubmission(
        urlToScan,
      );

      if (mounted) {
        setState(() {
          _isAnalyzing = false;
        });

        await Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => UrlAnalysisResults(
                  results: results,
                  scannedUrl: urlToScan,
                  onScanAgain: () {
                    Navigator.pop(context);
                    _reset();
                  },
                ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
          _error = 'Analysis failed: ${e.toString()}';
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('URL Analysis Failed: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _reset() {
    setState(() {
      _controller.clear();
      _error = null;
      _isAnalyzing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: URLColorPalette.getBackgroundColor(isDarkMode),
      appBar: AppBar(
        backgroundColor: URLColorPalette.getBackgroundColor(isDarkMode),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: _buildHeader(theme, isDarkMode),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: URLColorPalette.getSurfaceColor(isDarkMode),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: URLColorPalette.getPrimaryWithOpacity(isDarkMode, 0.1),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: URLColorPalette.getPrimaryWithOpacity(
                      isDarkMode,
                      0.1,
                    ),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Analyze URLs for phishing, redirection, or security threats',
                    style: TextStyle(
                      color: colorScheme.onSurface.withValues(alpha: 0.7),
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Input field
                  Container(
                    decoration: BoxDecoration(
                      color: URLColorPalette.getSecondaryColor(isDarkMode),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: URLColorPalette.getPrimaryWithOpacity(
                          isDarkMode,
                          0.2,
                        ),
                        width: 1,
                      ),
                    ),
                    child: TextField(
                      controller: _controller,
                      keyboardType: TextInputType.url,
                      enabled: !_isAnalyzing,
                      style: TextStyle(color: colorScheme.onSurface),
                      decoration: InputDecoration(
                        hintText: 'Enter a URL (e.g., https://example.com)',
                        hintStyle: TextStyle(
                          color: colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                        prefixIcon: const Icon(
                          Icons.link_rounded,
                          color: URLColorPalette.primary,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(16),
                      ),
                      onChanged: (value) {
                        if (_error != null) {
                          setState(() {
                            _error = null;
                          });
                        }
                      },
                      onSubmitted: (_) => _scanURL(),
                    ),
                  ).animate().slide(
                    begin: const Offset(-1, 0),
                    curve: Curves.easeOut,
                    duration: 500.ms,
                  ),

                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      _error!,
                      style: TextStyle(
                        fontSize: 14,
                        color: colorScheme.error,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],

                  const SizedBox(height: 20),

                  // Analyze button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isAnalyzing ? null : _scanURL,
                      icon:
                          _isAnalyzing
                              ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                              : const Icon(Icons.security_outlined),
                      label: Text(
                        _isAnalyzing ? 'Analyzing...' : 'Analyze URL',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: URLColorPalette.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 3,
                        shadowColor: URLColorPalette.getPrimaryWithOpacity(
                          isDarkMode,
                          0.3,
                        ),
                      ),
                    ),
                  ).animate().slide(
                    begin: const Offset(-1, 0),
                    curve: Curves.easeOut,
                    duration: 500.ms,
                  ),
                ],
              ),
            ),
          ),
        ),
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
            gradient: URLColorPalette.getPrimaryGradient(isDarkMode),
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(
              color: URLColorPalette.getPrimaryWithOpacity(isDarkMode, 0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: URLColorPalette.getPrimaryWithOpacity(isDarkMode, 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(
            Icons.language_outlined,
            color: URLColorPalette.primary,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Text(
          'URL Scanner',
          style: TextStyle(
            color: colorScheme.onSurface,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
