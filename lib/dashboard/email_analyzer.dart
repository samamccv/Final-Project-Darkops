import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/scan_service.dart';
import '../models/scan/scan_models.dart';
import 'email_analysis_results.dart';

/// Email Feature Color Palette
class EmailColorPalette {
  static const Color primary = Color(0xFF3B82F6); // Blue (59, 130, 246)
  static const Color primaryLight = Color(0xFF60A5FA); // Lighter blue
  static const Color primaryDark = Color(0xFF2563EB); // Darker blue

  // Light mode colors
  static const Color lightBackground = Color(0xFFF8FAFF);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSecondary = Color(0xFFF1F5F9);

  // Dark mode colors
  static const Color darkBackground = Color(0xFF0F172A);
  static const Color darkSurface = Color(0xFF1E293B);
  static const Color darkSecondary = Color(0xFF334155);

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

// --- MAIN WIDGET ---
class EmailAnalysisPage extends StatefulWidget {
  const EmailAnalysisPage({super.key});

  @override
  State<EmailAnalysisPage> createState() => _EmailAnalysisPageState();
}

class _EmailAnalysisPageState extends State<EmailAnalysisPage> {
  // --- STATE AND LOGIC ---
  String? _fileName;
  bool _isAnalyzing = false;
  EmailAnalysisResponse? _analysisResult;
  String? _errorMessage;
  final ScanService _scanService = ScanService();

  void _resetState() {
    setState(() {
      _fileName = null;
      _isAnalyzing = false;
      _analysisResult = null;
      _errorMessage = null;
    });
  }

  Future<void> _pickEmailFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['eml', 'txt', 'msg'],
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);

        setState(() {
          _fileName = result.files.single.name;
          _isAnalyzing = true;
          _errorMessage = null;
        });

        await _analyzeEmail(file);
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
      setState(() {
        _isAnalyzing = false;
        _errorMessage = 'Error picking file: $e';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking file: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _analyzeEmail(File emailFile) async {
    try {
      final result = await _scanService.analyzeEmailWithSubmission(emailFile);

      if (mounted) {
        setState(() {
          _isAnalyzing = false;
          _analysisResult = result;
        });

        // Try to capture screenshot if analysis was successful
        try {
          // Use a simple message ID for screenshot capture
          final messageId = DateTime.now().millisecondsSinceEpoch.toString();
          print('Attempting to capture screenshot with messageId: $messageId');

          final screenshotUrl = await _scanService.captureEmailScreenshot(
            messageId,
            emailFile,
          );

          print('Screenshot capture result: $screenshotUrl');

          if (screenshotUrl != null && screenshotUrl.isNotEmpty) {
            print('Screenshot captured successfully: $screenshotUrl');
            // Create updated results with screenshot URL
            final updatedResults = EmailAnalysisResponse(
              headers: result.headers,
              senderIp: result.senderIp,
              ipInfo: result.ipInfo,
              attachments: result.attachments,
              phishingDetection: result.phishingDetection,
              analysisTimestamp: result.analysisTimestamp,
              screenshotUrl: screenshotUrl,
              scanEngines: result.scanEngines,
            );

            await Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => EmailAnalysisResults(
                      results: updatedResults,
                      fileName: _fileName!,
                      onAnalyzeAgain: () {
                        Navigator.pop(context);
                        _resetState();
                      },
                    ),
              ),
            );
          } else {
            print('Screenshot capture returned null or empty URL');
            // Use original results without screenshot
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => EmailAnalysisResults(
                      results: result,
                      fileName: _fileName!,
                      onAnalyzeAgain: () {
                        Navigator.pop(context);
                        _resetState();
                      },
                    ),
              ),
            );
          }
        } catch (screenshotError) {
          // If screenshot capture fails, proceed with original results
          print('Screenshot capture failed with error: $screenshotError');
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => EmailAnalysisResults(
                    results: result,
                    fileName: _fileName!,
                    onAnalyzeAgain: () {
                      Navigator.pop(context);
                      _resetState();
                    },
                  ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
          _errorMessage = 'Analysis failed: $e';
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Analysis failed: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  // --- UI STRUCTURE ---
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: EmailColorPalette.getBackgroundColor(isDarkMode),
      appBar: AppBar(
        backgroundColor: EmailColorPalette.getBackgroundColor(isDarkMode),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: colorScheme.onSurface),
          tooltip: 'Back to Dashboard',
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
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color: EmailColorPalette.getSurfaceColor(isDarkMode),
                borderRadius: BorderRadius.circular(16.0),
                border: Border.all(
                  color: EmailColorPalette.getPrimaryWithOpacity(
                    isDarkMode,
                    0.1,
                  ),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: EmailColorPalette.getPrimaryWithOpacity(
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
                  if (_errorMessage != null)
                    _buildErrorMessage(theme, isDarkMode),
                  if (_errorMessage != null) const SizedBox(height: 24),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (child, animation) {
                      return FadeTransition(opacity: animation, child: child);
                    },
                    child:
                        _isAnalyzing
                            ? _buildAnalyzingState(theme, isDarkMode)
                            : _buildDropzone(theme, isDarkMode),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0);
  }

  // --- UI HELPER WIDGETS ---

  Widget _buildHeader(ThemeData theme, bool isDarkMode) {
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: EmailColorPalette.getPrimaryGradient(isDarkMode),
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(
              color: EmailColorPalette.getPrimaryWithOpacity(isDarkMode, 0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: EmailColorPalette.getPrimaryWithOpacity(isDarkMode, 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            Icons.email_outlined,
            color: EmailColorPalette.primary,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Text(
          'Email Analysis',
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
      padding: const EdgeInsets.symmetric(vertical: 48.0, horizontal: 24.0),
      width: double.infinity,
      decoration: BoxDecoration(
        color: EmailColorPalette.getSecondaryColor(isDarkMode),
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: EmailColorPalette.getPrimaryWithOpacity(isDarkMode, 0.2),
          width: 2,
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: EmailColorPalette.getPrimaryGradient(isDarkMode),
              shape: BoxShape.circle,
              border: Border.all(
                color: EmailColorPalette.getPrimaryWithOpacity(isDarkMode, 0.3),
                width: 2,
              ),
            ),
            child: Icon(
              Icons.email_outlined,
              color: EmailColorPalette.primary,
              size: 32,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Upload Email for Analysis',
            style: TextStyle(
              color: colorScheme.onSurface,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Supported formats: EML, TXT, MSG',
            style: TextStyle(
              color: colorScheme.onSurface.withValues(alpha: 0.6),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _pickEmailFile,
            icon: const Icon(Icons.upload_file_rounded, size: 20),
            label: const Text(
              'Select Email File',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: EmailColorPalette.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              elevation: 3,
              shadowColor: EmailColorPalette.getPrimaryWithOpacity(
                isDarkMode,
                0.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyzingState(ThemeData theme, bool isDarkMode) {
    final colorScheme = theme.colorScheme;

    return Container(
      key: const ValueKey('analyzing'),
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: EmailColorPalette.getSecondaryColor(isDarkMode),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: EmailColorPalette.primary.withValues(alpha: 0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: EmailColorPalette.primary.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: EmailColorPalette.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  EmailColorPalette.primary,
                ),
                strokeWidth: 3,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Analyzing Email',
            style: TextStyle(
              color: colorScheme.onSurface,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Scanning "$_fileName" for threats...',
            style: TextStyle(
              color: colorScheme.onSurface.withValues(alpha: 0.7),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'This may take a few moments',
            style: TextStyle(
              color: colorScheme.onSurface.withValues(alpha: 0.5),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorMessage(ThemeData theme, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: EmailColorPalette.danger.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: EmailColorPalette.danger.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: EmailColorPalette.danger, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Analysis Failed',
                  style: TextStyle(
                    color: EmailColorPalette.danger,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _errorMessage!,
                  style: TextStyle(
                    color: EmailColorPalette.danger,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                _errorMessage = null;
              });
            },
            icon: Icon(Icons.close, color: EmailColorPalette.danger, size: 20),
          ),
        ],
      ),
    );
  }
}
