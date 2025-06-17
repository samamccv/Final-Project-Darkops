// lib/dashboard/sms_analyzer.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:permission_handler/permission_handler.dart';
import '../blocs/scan/scan_bloc.dart';
import '../blocs/scan/scan_event.dart';
import '../blocs/scan/scan_state.dart';
import '../models/scan/scan_models.dart';

/// SMS Feature Color Palette
class SMSColorPalette {
  static const Color primary = Color(0xFF8B5CF6); // Purple (139, 92, 246)
  static const Color primaryLight = Color(0xFFA78BFA); // Lighter purple
  static const Color primaryDark = Color(0xFF7C3AED); // Darker purple

  // Light mode colors
  static const Color lightBackground = Color(0xFFFAF9FF);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSecondary = Color(0xFFF3F4F6);

  // Dark mode colors
  static const Color darkBackground = Color(0xFF0F0B1F);
  static const Color darkSurface = Color(0xFF1A1625);
  static const Color darkSecondary = Color(0xFF2D2438);

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

class SMSAnalyzerPage extends StatefulWidget {
  const SMSAnalyzerPage({super.key});

  @override
  State<SMSAnalyzerPage> createState() => _SMSAnalyzerPageState();
}

class _SMSAnalyzerPageState extends State<SMSAnalyzerPage> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _analyzeSMS() {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter an SMS message'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    context.read<ScanBloc>().add(AnalyzeSMSEvent(text));
  }

  void _readDeviceSMS() async {
    final permission = await Permission.sms.status;
    if (permission.isDenied) {
      final result = await Permission.sms.request();
      if (result.isDenied && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('SMS permission is required to read messages'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
        return;
      }
    }

    if (mounted) {
      context.read<ScanBloc>().add(const ParseSMSFromDeviceEvent());
    }
  }

  void _resetState() {
    _controller.clear();
    context.read<ScanBloc>().add(const ClearScanResultEvent());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: SMSColorPalette.getBackgroundColor(isDarkMode),
      appBar: AppBar(
        backgroundColor: SMSColorPalette.getBackgroundColor(isDarkMode),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: colorScheme.onSurface),
          tooltip: 'Back',
          onPressed: () => Navigator.pop(context),
        ),
        title: _buildHeader(theme, isDarkMode),
        titleSpacing: 0,
      ),
      body: BlocConsumer<ScanBloc, ScanState>(
        listener: (context, state) {
          if (state.hasError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? 'Analysis failed'),
                backgroundColor: colorScheme.error,
              ),
            );
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 32),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: Column(
                    children: [
                      // Input Section
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: colorScheme.surface,
                          borderRadius: BorderRadius.circular(16.0),
                          border: Border.all(
                            color: colorScheme.outline.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildInputOptions(theme, isDarkMode),
                            const SizedBox(height: 16),
                            _buildInputSection(theme, isDarkMode, state),
                          ],
                        ),
                      ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.3),

                      const SizedBox(height: 24),

                      // Results Section
                      if (state.isLoading)
                        _buildLoadingSection(
                          theme,
                          isDarkMode,
                        ).animate().fadeIn(duration: 400.ms),

                      if (state.hasResult &&
                          state.currentScanType == ScanType.sms)
                        _buildResultSection(
                          state.smsResult!,
                          theme,
                          isDarkMode,
                        ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.3),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
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
            gradient: SMSColorPalette.getPrimaryGradient(isDarkMode),
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(
              color: SMSColorPalette.getPrimaryWithOpacity(isDarkMode, 0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: SMSColorPalette.getPrimaryWithOpacity(isDarkMode, 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            Icons.sms_outlined,
            color: SMSColorPalette.primary,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Text(
          'SMS Analysis',
          style: TextStyle(
            color: colorScheme.onSurface,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildInputOptions(ThemeData theme, bool isDarkMode) {
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Choose SMS Input Method:',
          style: TextStyle(
            color: colorScheme.onSurface,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  // Focus on text input
                },
                icon: const Icon(Icons.edit_outlined, size: 20),
                label: const Text('Manual Input'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: SMSColorPalette.getPrimaryWithOpacity(
                    isDarkMode,
                    0.1,
                  ),
                  foregroundColor: SMSColorPalette.primary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _readDeviceSMS,
                icon: const Icon(Icons.smartphone_outlined, size: 20),
                label: const Text('Read from Device'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: SMSColorPalette.getPrimaryWithOpacity(
                    isDarkMode,
                    0.1,
                  ),
                  foregroundColor: SMSColorPalette.primary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                  side: BorderSide(
                    color: SMSColorPalette.getPrimaryWithOpacity(
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
      ],
    );
  }

  Widget _buildInputSection(ThemeData theme, bool isDarkMode, ScanState state) {
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Enter SMS message below:',
          style: TextStyle(
            color: colorScheme.onSurface.withValues(alpha: 0.8),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Card(
          color: SMSColorPalette.getSurfaceColor(isDarkMode),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: SMSColorPalette.getPrimaryWithOpacity(isDarkMode, 0.1),
              width: 1,
            ),
          ),
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _controller,
              maxLines: 6,
              style: TextStyle(color: colorScheme.onSurface),
              decoration: InputDecoration(
                hintText: 'Paste the SMS message to analyze...',
                hintStyle: TextStyle(
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                border: InputBorder.none,
              ),
              enabled: !state.isLoading,
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: state.isLoading ? null : _analyzeSMS,
            icon:
                state.isLoading
                    ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: colorScheme.onPrimary,
                      ),
                    )
                    : const Icon(Icons.security_outlined),
            label: Text(
              state.isLoading ? 'Analyzing...' : 'Analyze SMS',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: SMSColorPalette.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              elevation: 3,
              shadowColor: SMSColorPalette.getPrimaryWithOpacity(
                isDarkMode,
                0.3,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingSection(ThemeData theme, bool isDarkMode) {
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: SMSColorPalette.getSurfaceColor(isDarkMode),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: SMSColorPalette.getPrimaryWithOpacity(isDarkMode, 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: SMSColorPalette.getPrimaryWithOpacity(isDarkMode, 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          CircularProgressIndicator(
            color: SMSColorPalette.primary,
            strokeWidth: 3,
          ),
          const SizedBox(height: 16),
          Text(
            'Analyzing SMS for threats...',
            style: TextStyle(
              color: colorScheme.onSurface,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'This may take a few seconds',
            style: TextStyle(
              color: colorScheme.onSurface.withValues(alpha: 0.7),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultSection(
    SMSAnalysisResponse result,
    ThemeData theme,
    bool isDarkMode,
  ) {
    final colorScheme = theme.colorScheme;
    final isDarkMode = theme.brightness == Brightness.dark;

    // Use primary result (combined assessment if available, otherwise legacy)
    final isPhishing = result.primaryIsPhishing;
    final threatColor =
        isPhishing
            ? (isDarkMode ? Colors.red.shade400 : Colors.red.shade700)
            : (isDarkMode ? Colors.green.shade400 : Colors.green.shade700);
    final threatIcon =
        isPhishing ? Icons.warning_rounded : Icons.check_circle_rounded;
    final threatText = isPhishing ? 'PHISHING DETECTED' : 'SAFE MESSAGE';

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: threatColor.withValues(alpha: 0.3), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Threat Level Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: threatColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(threatIcon, color: threatColor, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      threatText,
                      style: TextStyle(
                        color: threatColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      result.prediction,
                      style: TextStyle(
                        color: colorScheme.onSurface.withValues(alpha: 0.8),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Combined Assessment (if available)
          if (result.combinedAssessment != null) ...[
            _buildCombinedAssessmentSection(result, theme),
            const SizedBox(height: 20),
          ],

          // Individual Model Results (if available)
          if (result.isDualModel) ...[
            _buildDualModelSection(result, theme),
            const SizedBox(height: 20),
          ],

          // Legacy Analysis Details (fallback)
          if (!result.isDualModel && result.combinedAssessment == null)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.onSurface.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Analysis Details',
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (result.confidence != null)
                    _buildDetailRow(
                      'Confidence',
                      _formatConfidence(result.confidence!),
                      colorScheme.onSurface,
                    ),
                  _buildDetailRow(
                    'Threat Level',
                    result.primaryRiskLevel.toUpperCase(),
                    colorScheme.onSurface,
                  ),
                  _buildDetailRow(
                    'Analysis Time',
                    result.analysisTimestamp ?? 'Just now',
                    colorScheme.onSurface,
                  ),
                ],
              ),
            ),

          const SizedBox(height: 24),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _resetState,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Analyze Another'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
                    foregroundColor: colorScheme.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Share or save result
                  },
                  icon: const Icon(Icons.share_rounded),
                  label: const Text('Share Result'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, Color textColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: textColor.withValues(alpha: 0.7),
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: textColor,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// Formats confidence value properly handling both decimal and percentage formats
  String _formatConfidence(double confidence) {
    // Check if confidence is already in percentage format (greater than 1)
    if (confidence > 1) {
      return '${confidence.toStringAsFixed(1)}%';
    }
    // Otherwise, convert from decimal to percentage
    return '${(confidence * 100).toStringAsFixed(1)}%';
  }

  Widget _buildCombinedAssessmentSection(
    SMSAnalysisResponse result,
    ThemeData theme,
  ) {
    final colorScheme = theme.colorScheme;
    final assessment = result.combinedAssessment!;
    final isDarkMode = theme.brightness == Brightness.dark;
    final consensusColor =
        assessment.consensus
            ? (isDarkMode ? Colors.green.shade400 : Colors.green.shade600)
            : (isDarkMode ? Colors.orange.shade400 : Colors.orange.shade600);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: consensusColor.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: consensusColor.withValues(alpha: isDarkMode ? 0.2 : 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: consensusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  assessment.consensus
                      ? Icons.verified_outlined
                      : Icons.warning_amber_outlined,
                  color: consensusColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Combined Assessment',
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: consensusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            assessment.consensus
                                ? Icons.check_circle
                                : Icons.info,
                            color: consensusColor,
                            size: 14,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            assessment.consensus
                                ? 'Models Agree'
                                : 'Models Disagree',
                            style: TextStyle(
                              color: consensusColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Metrics Grid
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.onSurface.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildAssessmentMetric(
                        'Final Confidence',
                        _formatConfidence(assessment.confidence),
                        Icons.analytics_outlined,
                        colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildAssessmentMetric(
                        'Risk Level',
                        assessment.riskLevel.toUpperCase(),
                        Icons.security_outlined,
                        _getRiskLevelColor(assessment.riskLevel, isDarkMode),
                      ),
                    ),
                  ],
                ),
                if (result.modelsUsed != null) ...[
                  const SizedBox(height: 16),
                  _buildAssessmentMetric(
                    'Models Used',
                    '${result.modelsUsed!.length} AI Models',
                    Icons.psychology_outlined,
                    colorScheme.primary,
                  ),
                ],
              ],
            ),
          ),

          // Explanation Section
          if (assessment.explanation.isNotEmpty) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: colorScheme.primary.withValues(alpha: 0.1),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        color: colorScheme.primary,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'AI Reasoning',
                        style: TextStyle(
                          color: colorScheme.primary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    assessment.explanation,
                    style: TextStyle(
                      color: colorScheme.onSurface.withValues(alpha: 0.8),
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAssessmentMetric(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: color.withValues(alpha: 0.7)),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: color.withValues(alpha: 0.7),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildDualModelSection(SMSAnalysisResponse result, ThemeData theme) {
    final colorScheme = theme.colorScheme;
    final isDarkMode = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.onSurface.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.analytics_outlined,
                  color: colorScheme.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Individual Model Results',
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'Detailed analysis from each AI model',
                    style: TextStyle(
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Check screen size and adjust layout accordingly
          LayoutBuilder(
            builder: (context, constraints) {
              // If screen is wide enough, show models side by side
              if (constraints.maxWidth > 600) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (result.hasModel1)
                      Expanded(
                        child: _buildModelCard(
                          result.model1!,
                          result.displayModelName1,
                          theme,
                        ),
                      ),
                    if (result.hasModel1 && result.hasModel2)
                      const SizedBox(width: 16),
                    if (result.hasModel2)
                      Expanded(
                        child: _buildModelCard(
                          result.model2!,
                          result.displayModelName2,
                          theme,
                        ),
                      ),
                  ],
                );
              } else {
                // On smaller screens, stack models vertically
                return Column(
                  children: [
                    if (result.hasModel1) ...[
                      _buildModelCard(
                        result.model1!,
                        result.displayModelName1,
                        theme,
                      ),
                      if (result.hasModel2) const SizedBox(height: 16),
                    ],
                    if (result.hasModel2)
                      _buildModelCard(
                        result.model2!,
                        result.displayModelName2,
                        theme,
                      ),
                  ],
                );
              }
            },
          ),

          // Add summary information if both models are available
          if (result.hasModel1 && result.hasModel2) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: colorScheme.primary.withValues(alpha: 0.1),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.compare_arrows_rounded,
                        color: colorScheme.primary,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Model Comparison',
                        style: TextStyle(
                          color: colorScheme.primary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildComparisonRow(
                    'Agreement',
                    result.model1!.isPhishing == result.model2!.isPhishing
                        ? 'Models Agree'
                        : 'Models Disagree',
                    result.model1!.isPhishing == result.model2!.isPhishing
                        ? (isDarkMode
                            ? Colors.green.shade400
                            : Colors.green.shade600)
                        : (isDarkMode
                            ? Colors.orange.shade400
                            : Colors.orange.shade600),
                    colorScheme.onSurface,
                  ),
                  const SizedBox(height: 8),
                  _buildComparisonRow(
                    'Confidence Diff',
                    '${(result.model1!.confidence - result.model2!.confidence).abs().toStringAsFixed(1)}%',
                    colorScheme.onSurface,
                    colorScheme.onSurface,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildComparisonRow(
    String label,
    String value,
    Color valueColor,
    Color textColor,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: textColor.withValues(alpha: 0.7),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildModelCard(
    ModelResult model,
    String displayName,
    ThemeData theme,
  ) {
    final colorScheme = theme.colorScheme;
    final isDarkMode = theme.brightness == Brightness.dark;
    final isPhishing = model.isPhishing;
    final statusColor =
        isPhishing
            ? (isDarkMode ? Colors.red.shade400 : Colors.red.shade600)
            : (isDarkMode ? Colors.green.shade400 : Colors.green.shade600);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: statusColor.withValues(alpha: isDarkMode ? 0.2 : 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with model name and status badge
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  isPhishing
                      ? Icons.warning_rounded
                      : Icons.check_circle_rounded,
                  color: statusColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        isPhishing ? 'PHISHING' : 'SAFE',
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Analysis metrics in a grid
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.onSurface.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildMetricItem(
                        'Confidence',
                        _formatConfidence(model.confidence),
                        Icons.analytics_outlined,
                        colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildMetricItem(
                        'Risk Level',
                        model.riskLevel.toUpperCase(),
                        Icons.security_outlined,
                        _getRiskLevelColor(model.riskLevel, isDarkMode),
                      ),
                    ),
                  ],
                ),
                if (model.status.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _buildMetricItem(
                    'Status',
                    model.status.toUpperCase(),
                    Icons.info_outline,
                    colorScheme.onSurface,
                  ),
                ],
              ],
            ),
          ),

          // Model explanation section (if available)
          if (model.explanation != null && model.explanation!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: colorScheme.primary.withValues(alpha: 0.1),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.psychology_outlined,
                        color: colorScheme.primary,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Model Analysis',
                        style: TextStyle(
                          color: colorScheme.primary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    model.explanation!,
                    style: TextStyle(
                      color: colorScheme.onSurface.withValues(alpha: 0.8),
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Technical details section
          const SizedBox(height: 16),
          Theme(
            data: theme.copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              tilePadding: EdgeInsets.zero,
              childrenPadding: const EdgeInsets.only(top: 8),
              title: Row(
                children: [
                  Icon(
                    Icons.settings_outlined,
                    color: colorScheme.onSurface.withValues(alpha: 0.7),
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Technical Details',
                    style: TextStyle(
                      color: colorScheme.onSurface.withValues(alpha: 0.7),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colorScheme.onSurface.withValues(alpha: 0.02),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      _buildTechnicalDetailRow(
                        'Model Name',
                        model.modelName,
                        colorScheme.onSurface,
                      ),
                      const SizedBox(height: 8),
                      _buildTechnicalDetailRow(
                        'Confidence Score',
                        '${(model.confidence * 100).toStringAsFixed(2)}%',
                        colorScheme.onSurface,
                      ),
                      const SizedBox(height: 8),
                      _buildTechnicalDetailRow(
                        'Risk Assessment',
                        model.riskLevel,
                        colorScheme.onSurface,
                      ),
                      const SizedBox(height: 8),
                      _buildTechnicalDetailRow(
                        'Analysis Status',
                        model.status,
                        colorScheme.onSurface,
                      ),
                      const SizedBox(height: 8),
                      _buildTechnicalDetailRow(
                        'Detection Result',
                        isPhishing ? 'Phishing Detected' : 'Safe Message',
                        colorScheme.onSurface,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: color.withValues(alpha: 0.7)),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: color.withValues(alpha: 0.7),
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildTechnicalDetailRow(String label, String value, Color textColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: textColor.withValues(alpha: 0.6),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            value,
            style: TextStyle(
              color: textColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Color _getRiskLevelColor(String riskLevel, bool isDarkMode) {
    switch (riskLevel.toLowerCase()) {
      case 'high':
        return isDarkMode ? Colors.red.shade400 : Colors.red.shade600;
      case 'medium':
        return isDarkMode ? Colors.orange.shade400 : Colors.orange.shade600;
      case 'low':
        return isDarkMode ? Colors.green.shade400 : Colors.green.shade600;
      default:
        return isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600;
    }
  }
}
