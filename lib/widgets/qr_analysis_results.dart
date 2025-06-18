// lib/widgets/qr_analysis_results.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/scan/scan_models.dart';
import '../dashboard/qr_code_scanner.dart';

class QRAnalysisResults extends StatefulWidget {
  final QRPhishingAnalysisResponse analysisResult;
  final String originalUrl;
  final VoidCallback? onScanAgain;

  const QRAnalysisResults({
    super.key,
    required this.analysisResult,
    required this.originalUrl,
    this.onScanAgain,
  });

  @override
  State<QRAnalysisResults> createState() => _QRAnalysisResultsState();
}

class _QRAnalysisResultsState extends State<QRAnalysisResults> {
  bool isVisible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        isVisible = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return AnimatedOpacity(
      opacity: isVisible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 500),
      child: Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: QRColorPalette.getSurfaceColor(isDarkMode),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _getBorderColor(),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: _getBorderColor().withValues(alpha: 0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(theme, isDarkMode),
            _buildStatusAlert(theme, isDarkMode),
            _buildBasicInfo(theme, isDarkMode),
            if (widget.analysisResult.riskFactors?.isNotEmpty == true ||
                widget.analysisResult.safetyIndicators?.isNotEmpty == true)
              _buildRiskAndSafetyFactors(theme, isDarkMode),
            if (widget.analysisResult.recommendations != null)
              _buildRecommendations(theme, isDarkMode),
            _buildActionButtons(theme, isDarkMode),
          ],
        ),
      ),
    )
        .animate()
        .slideY(begin: 0.3, duration: 500.ms, curve: Curves.easeOutBack)
        .fadeIn(duration: 500.ms);
  }

  Color _getBorderColor() {
    return widget.analysisResult.isPhishing
        ? QRColorPalette.danger
        : QRColorPalette.success;
  }

  Widget _buildHeader(ThemeData theme, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _getBorderColor().withValues(alpha: 0.1),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(14),
          topRight: Radius.circular(14),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _getBorderColor().withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              widget.analysisResult.isPhishing
                  ? Icons.warning_rounded
                  : Icons.verified_user_rounded,
              color: _getBorderColor(),
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Security Analysis',
                  style: TextStyle(
                    fontSize: 18,
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  widget.analysisResult.isPhishing
                      ? 'Threat Detected'
                      : 'URL Appears Safe',
                  style: TextStyle(
                    fontSize: 12,
                    color: _getBorderColor(),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          if (widget.onScanAgain != null)
            IconButton(
              icon: const Icon(Icons.refresh),
              color: QRColorPalette.primary,
              onPressed: widget.onScanAgain,
              tooltip: 'Scan Again',
            ),
        ],
      ),
    );
  }

  Widget _buildStatusAlert(ThemeData theme, bool isDarkMode) {
    final status = _getStatusMessage();
    
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: status['bgColor'],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: status['borderColor']),
      ),
      child: Row(
        children: [
          Icon(
            widget.analysisResult.isPhishing
                ? Icons.warning_rounded
                : Icons.check_circle_rounded,
            color: _getBorderColor(),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  status['title'],
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: status['textColor'],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  status['description'],
                  style: TextStyle(
                    fontSize: 12,
                    color: status['textColor'],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfo(ThemeData theme, bool isDarkMode) {
    final urlAnalysis = widget.analysisResult.urlAnalysis;
    final basicInfo = urlAnalysis?.basicInfo;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Basic Information',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          _buildInfoCard('URL', widget.originalUrl, theme, isDarkMode),
          if (basicInfo?.domain != null)
            _buildInfoCard('Domain', basicInfo!.domain!, theme, isDarkMode),
          if (basicInfo?.ip != null)
            _buildInfoCard('IP Address', basicInfo!.ip!, theme, isDarkMode),
          if (basicInfo?.country != null)
            _buildInfoCard('Country', basicInfo!.country!, theme, isDarkMode),
          _buildInfoCard(
            'Confidence',
            '${(widget.analysisResult.confidence * 100).toStringAsFixed(1)}%',
            theme,
            isDarkMode,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String label, String value, ThemeData theme, bool isDarkMode) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: QRColorPalette.getPrimaryWithOpacity(isDarkMode, 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: QRColorPalette.getPrimaryWithOpacity(isDarkMode, 0.1),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 12,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12,
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRiskAndSafetyFactors(ThemeData theme, bool isDarkMode) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.analysisResult.riskFactors?.isNotEmpty == true) ...[
            Text(
              'Risk Factors',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            ...widget.analysisResult.riskFactors!.map(
              (factor) => _buildFactorItem(factor, true, theme, isDarkMode),
            ),
            const SizedBox(height: 16),
          ],
          if (widget.analysisResult.safetyIndicators?.isNotEmpty == true) ...[
            Text(
              'Safety Indicators',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            ...widget.analysisResult.safetyIndicators!.map(
              (indicator) => _buildFactorItem(indicator, false, theme, isDarkMode),
            ),
            const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }

  Widget _buildFactorItem(String text, bool isRisk, ThemeData theme, bool isDarkMode) {
    final color = isRisk ? QRColorPalette.danger : QRColorPalette.success;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(
            isRisk ? Icons.warning_rounded : Icons.check_circle_rounded,
            color: color,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendations(ThemeData theme, bool isDarkMode) {
    final recommendations = widget.analysisResult.recommendations!;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recommendations',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: QRColorPalette.warning.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: QRColorPalette.warning.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Action: ${recommendations.userAction}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                ...recommendations.safetyTips.map(
                  (tip) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('• ', style: TextStyle(fontSize: 12)),
                        Expanded(
                          child: Text(
                            tip,
                            style: TextStyle(
                              fontSize: 12,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildActionButtons(ThemeData theme, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
          ),
        ),
      ),
      child: Row(
        children: [
          if (widget.onScanAgain != null)
            Expanded(
              child: OutlinedButton.icon(
                onPressed: widget.onScanAgain,
                icon: const Icon(Icons.qr_code_scanner),
                label: const Text('Scan Another'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: QRColorPalette.primary,
                  side: BorderSide(color: QRColorPalette.primary),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Map<String, dynamic> _getStatusMessage() {
    if (widget.analysisResult.isPhishing) {
      return {
        'title': '⚠️ Phishing Threat Detected',
        'description': 'This URL has been identified as a potential phishing threat. Do not enter personal information.',
        'bgColor': QRColorPalette.danger.withValues(alpha: 0.1),
        'borderColor': QRColorPalette.danger.withValues(alpha: 0.3),
        'textColor': QRColorPalette.danger,
      };
    }
    return {
      'title': '✅ URL Appears Safe',
      'description': 'This URL appears to be legitimate based on our comprehensive analysis.',
      'bgColor': QRColorPalette.success.withValues(alpha: 0.1),
      'borderColor': QRColorPalette.success.withValues(alpha: 0.3),
      'textColor': QRColorPalette.success,
    };
  }
}
