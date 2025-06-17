import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// URL Feature Color Palette
class URLColorPalette {
  static const Color primary = Color(0xFFF59E0B); // Orange (245, 158, 11)
  static const Color primaryLight = Color(0xFFFBBF24); // Lighter orange
  static const Color primaryDark = Color(0xED8936); // Darker orange

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
  bool _scanDone = false;
  String? _scannedURL;
  bool _isAnalyzing = false;

  void _scanURL() {
    final url = _controller.text.trim();
    if (url.isEmpty || Uri.tryParse(url)?.hasAbsolutePath != true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter a valid URL'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    setState(() {
      _isAnalyzing = true;
    });

    // Simulate analysis time
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _scanDone = true;
          _scannedURL = url;
          _isAnalyzing = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('URL analysis completed: "$url"'),
            backgroundColor: URLColorPalette.primary,
          ),
        );
        Navigator.pop(context, url);
      }
    });
  }

  void _reset() {
    setState(() {
      _controller.clear();
      _scanDone = false;
      _scannedURL = null;
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
                      enabled: !_isAnalyzing && !_scanDone,
                      style: TextStyle(color: colorScheme.onSurface),
                      decoration: InputDecoration(
                        hintText: 'Enter a URL (e.g., https://example.com)',
                        hintStyle: TextStyle(
                          color: colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                        prefixIcon: Icon(
                          Icons.link_rounded,
                          color: URLColorPalette.primary,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(16),
                      ),
                    ),
                  ).animate().slide(
                    begin: const Offset(-1, 0),
                    curve: Curves.easeOut,
                    duration: 500.ms,
                  ),

                  const SizedBox(height: 20),

                  // Analyze button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: (_isAnalyzing || _scanDone) ? null : _scanURL,
                      icon:
                          _isAnalyzing
                              ? SizedBox(
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

                  // Results section
                  if (_scanDone) ...[
                    const SizedBox(height: 32),
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: URLColorPalette.getSecondaryColor(isDarkMode),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: URLColorPalette.success.withValues(alpha: 0.3),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: URLColorPalette.success.withValues(
                              alpha: 0.1,
                            ),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: URLColorPalette.success.withValues(
                                    alpha: 0.1,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.check_circle_outline_rounded,
                                  color: URLColorPalette.success,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Analysis Complete',
                                      style: TextStyle(
                                        color: colorScheme.onSurface,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    Text(
                                      'URL security check completed',
                                      style: TextStyle(
                                        color: URLColorPalette.success,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: colorScheme.onSurface.withValues(
                                alpha: 0.03,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.language_outlined,
                                      color: URLColorPalette.primary,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Scanned URL',
                                      style: TextStyle(
                                        color: URLColorPalette.primary,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color:
                                        URLColorPalette.getPrimaryWithOpacity(
                                          isDarkMode,
                                          0.05,
                                        ),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color:
                                          URLColorPalette.getPrimaryWithOpacity(
                                            isDarkMode,
                                            0.1,
                                          ),
                                    ),
                                  ),
                                  child: Text(
                                    _scannedURL ?? '',
                                    style: TextStyle(
                                      color: colorScheme.onSurface.withValues(
                                        alpha: 0.8,
                                      ),
                                      fontFamily: 'monospace',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _reset,
                              icon: const Icon(Icons.refresh_rounded, size: 20),
                              label: const Text(
                                'Analyze Another URL',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    URLColorPalette.getPrimaryWithOpacity(
                                      isDarkMode,
                                      0.1,
                                    ),
                                foregroundColor: URLColorPalette.primary,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                elevation: 0,
                                side: BorderSide(
                                  color: URLColorPalette.getPrimaryWithOpacity(
                                    isDarkMode,
                                    0.2,
                                  ),
                                  width: 1,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ).animate().slide(
                      begin: const Offset(1, 0),
                      curve: Curves.easeOut,
                      duration: 500.ms,
                    ),
                  ],
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
          child: Icon(
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
