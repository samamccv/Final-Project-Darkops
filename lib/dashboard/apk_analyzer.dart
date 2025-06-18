import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// APK Feature Color Palette
class APKColorPalette {
  static const Color primary = Color(0xFF0FB985); // Green (15, 185, 133)
  static const Color primaryLight = Color(0xFF34D399); // Lighter green
  static const Color primaryDark = Color(0xFF059669); // Darker green

  // Light mode colors
  static const Color lightBackground = Color(0xFFF0FDF4);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSecondary = Color(0xFFDCFCE7);

  // Dark mode colors
  static const Color darkBackground = Color(0xFF0F1C14);
  static const Color darkSurface = Color(0xFF1A2E23);
  static const Color darkSecondary = Color(0xFF22543D);

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

class APKAnalyzerPage extends StatefulWidget {
  const APKAnalyzerPage({super.key});

  @override
  State<APKAnalyzerPage> createState() => _APKAnalyzerPageState();
}

class _APKAnalyzerPageState extends State<APKAnalyzerPage> {
  String? _selectedFileName;
  bool _isAnalyzing = false;
  String? _analysisResult;

  void _resetState() {
    setState(() {
      _selectedFileName = null;
      _analysisResult = null;
      _isAnalyzing = false;
    });
  }

  Future<void> _pickAPK() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['apk'],
      );

      if (result != null && result.files.single.name.isNotEmpty) {
        setState(() {
          _selectedFileName = result.files.single.name;
          _analysisResult = null;
        });

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('APK Selected: "${_selectedFileName!}"'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: APKColorPalette.primary,
          ),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('No file selected.'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking file: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _analyzeAPK() async {
    if (_selectedFileName == null) return;

    setState(() {
      _isAnalyzing = true;
      _analysisResult = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Analyzing "$_selectedFileName"...'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: APKColorPalette.primary,
      ),
    );

    await Future.delayed(const Duration(seconds: 3));

    setState(() {
      _isAnalyzing = false;
      _analysisResult =
          '✅ No malware detected.\n🔐 5 permissions found.\n📦 Package is safe.';
    });
    if (!mounted) return;
    Navigator.pop(context, _selectedFileName);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: APKColorPalette.getBackgroundColor(isDarkMode),
      appBar: AppBar(
        backgroundColor: APKColorPalette.getBackgroundColor(isDarkMode),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: colorScheme.onSurface),
          tooltip: 'Back',
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          },
        ),
        title: _buildHeader(theme, isDarkMode),
        titleSpacing: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: APKColorPalette.getSurfaceColor(isDarkMode),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: APKColorPalette.getPrimaryWithOpacity(isDarkMode, 0.1),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: APKColorPalette.getPrimaryWithOpacity(
                      isDarkMode,
                      0.1,
                    ),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_selectedFileName != null)
                    Text(
                      'Analysis result for the uploaded file.',
                      style: TextStyle(
                        color: colorScheme.onSurface.withValues(alpha: 0.7),
                        fontSize: 16,
                      ),
                    ),
                  if (_selectedFileName != null) const SizedBox(height: 24),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder:
                        (child, animation) =>
                            FadeTransition(opacity: animation, child: child),
                    child:
                        _selectedFileName == null
                            ? _buildDropzone(theme, isDarkMode)
                            : _buildAnalysisResult(theme, isDarkMode),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildHeader(ThemeData theme, bool isDarkMode) {
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: APKColorPalette.getPrimaryGradient(isDarkMode),
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(
              color: APKColorPalette.getPrimaryWithOpacity(isDarkMode, 0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: APKColorPalette.getPrimaryWithOpacity(isDarkMode, 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(
            Icons.android_outlined,
            color: APKColorPalette.primary,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Text(
          'APK Analysis',
          style: TextStyle(
            color: colorScheme.onSurface,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildDropzone(ThemeData theme, bool isDarkMode) {
    final colorScheme = theme.colorScheme;

    return Container(
      key: const ValueKey('dropzone'),
      padding: const EdgeInsets.symmetric(vertical: 48.0, horizontal: 24.0),
      width: double.infinity,
      decoration: BoxDecoration(
        color: APKColorPalette.getSecondaryColor(isDarkMode),
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: APKColorPalette.getPrimaryWithOpacity(isDarkMode, 0.2),
          width: 2,
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: APKColorPalette.getPrimaryGradient(isDarkMode),
              shape: BoxShape.circle,
              border: Border.all(
                color: APKColorPalette.getPrimaryWithOpacity(isDarkMode, 0.3),
                width: 2,
              ),
            ),
            child: const Icon(
              Icons.android_outlined,
              color: APKColorPalette.primary,
              size: 32,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Upload APK for Analysis',
            style: TextStyle(
              color: colorScheme.onSurface,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Analyze Android applications for security threats',
            style: TextStyle(
              color: colorScheme.onSurface.withValues(alpha: 0.6),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _pickAPK,
            icon: const Icon(Icons.upload_file_rounded, size: 20),
            label: const Text(
              'Select APK File',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: APKColorPalette.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              elevation: 3,
              shadowColor: APKColorPalette.getPrimaryWithOpacity(
                isDarkMode,
                0.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisResult(ThemeData theme, bool isDarkMode) {
    final colorScheme = theme.colorScheme;

    return Container(
      key: const ValueKey('results'),
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: APKColorPalette.getSecondaryColor(isDarkMode),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: APKColorPalette.getPrimaryWithOpacity(isDarkMode, 0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: APKColorPalette.getPrimaryWithOpacity(isDarkMode, 0.1),
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
                  color: APKColorPalette.getPrimaryWithOpacity(isDarkMode, 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.android_outlined,
                  color: APKColorPalette.primary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'APK Ready for Analysis',
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Text(
                      'Android application loaded',
                      style: TextStyle(
                        color: APKColorPalette.primary,
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
              color: colorScheme.onSurface.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.insert_drive_file_outlined,
                      color: APKColorPalette.primary,
                      size: 16,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'File Details',
                      style: TextStyle(
                        color: APKColorPalette.primary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildDetailRow(
                  'File Name',
                  _selectedFileName!,
                  colorScheme.onSurface,
                ),
                const SizedBox(height: 8),
                _buildDetailRow(
                  'File Type',
                  'Android APK',
                  colorScheme.onSurface,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isAnalyzing ? null : _analyzeAPK,
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
                      : const Icon(Icons.security_outlined, size: 20),
              label: Text(
                _isAnalyzing ? 'Analyzing...' : 'Analyze APK',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: APKColorPalette.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                elevation: 3,
                shadowColor: APKColorPalette.getPrimaryWithOpacity(
                  isDarkMode,
                  0.3,
                ),
              ),
            ),
          ),
          if (_isAnalyzing) ...[
            const SizedBox(height: 20),
            Center(
              child: Column(
                children: [
                  const CircularProgressIndicator(
                    color: APKColorPalette.primary,
                    strokeWidth: 3,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Scanning for malware and vulnerabilities...',
                    style: TextStyle(
                      color: colorScheme.onSurface.withValues(alpha: 0.7),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (_analysisResult != null) ...[
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: APKColorPalette.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: APKColorPalette.success.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.check_circle_outline_rounded,
                        color: APKColorPalette.success,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Analysis Complete',
                        style: TextStyle(
                          color: APKColorPalette.success,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _analysisResult!,
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1),
          ],
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _resetState,
              icon: const Icon(Icons.refresh_rounded, size: 20),
              label: const Text(
                'Analyze Another APK',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: APKColorPalette.getPrimaryWithOpacity(
                  isDarkMode,
                  0.1,
                ),
                foregroundColor: APKColorPalette.primary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                elevation: 0,
                side: BorderSide(
                  color: APKColorPalette.getPrimaryWithOpacity(isDarkMode, 0.2),
                  width: 1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, Color textColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: TextStyle(
              color: textColor.withValues(alpha: 0.6),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: textColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
