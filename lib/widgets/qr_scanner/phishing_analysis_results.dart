// lib/widgets/qr_scanner/phishing_analysis_results.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/qr_analysis_service.dart';
import '../../services/qr_analysis_manager.dart';

/// Comprehensive phishing analysis results display matching frontend
class PhishingAnalysisResults extends StatelessWidget {
  final PhishingAnalysisResponse analysis;
  final String url;

  const PhishingAnalysisResults({
    super.key,
    required this.analysis,
    required this.url,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 8,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 20),
            _buildStatusAlert(context),
            const SizedBox(height: 16),
            _buildConfidenceScore(context),
            const SizedBox(height: 16),
            _buildRiskLevel(context),
            const SizedBox(height: 20),
            _buildDomainAnalysis(context),
            const SizedBox(height: 20),
            _buildDNSInformation(context),
            const SizedBox(height: 20),
            _buildIndicators(context),
            const SizedBox(height: 20),
            _buildRecommendations(context),
            const SizedBox(height: 20),
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.security,
            color: theme.colorScheme.onPrimaryContainer,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Security Analysis',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Comprehensive phishing detection results',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusAlert(BuildContext context) {
    final theme = Theme.of(context);
    final isPhishing = analysis.status.toLowerCase() == 'phishing';
    final isSuspicious = analysis.status.toLowerCase() == 'suspicious';
    final isSafe = analysis.status.toLowerCase() == 'safe';

    Color alertColor;
    IconData alertIcon;
    String alertTitle;

    if (isPhishing) {
      alertColor = Colors.red;
      alertIcon = Icons.dangerous;
      alertTitle = 'Phishing Detected';
    } else if (isSuspicious) {
      alertColor = Colors.orange;
      alertIcon = Icons.warning;
      alertTitle = 'Suspicious Content';
    } else if (isSafe) {
      alertColor = Colors.green;
      alertIcon = Icons.check_circle;
      alertTitle = 'Safe Content';
    } else {
      alertColor = Colors.grey;
      alertIcon = Icons.help_outline;
      alertTitle = 'Unknown Status';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: alertColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: alertColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(alertIcon, color: alertColor, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alertTitle,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: alertColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  analysis.status,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfidenceScore(BuildContext context) {
    final theme = Theme.of(context);
    final confidence = analysis.confidence;
    final percentage = (confidence * 100).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Confidence Score',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '$percentage%',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: confidence,
          backgroundColor: theme.colorScheme.surfaceContainerHighest,
          valueColor: AlwaysStoppedAnimation<Color>(
            confidence > 0.7 ? Colors.red : 
            confidence > 0.4 ? Colors.orange : Colors.green,
          ),
        ),
      ],
    );
  }

  Widget _buildRiskLevel(BuildContext context) {
    final theme = Theme.of(context);
    final riskLevel = analysis.riskLevel;
    final color = _getRiskLevelColor(riskLevel);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.shield, color: color, size: 20),
          const SizedBox(width: 8),
          Text(
            'Risk Level: $riskLevel',
            style: theme.textTheme.titleSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDomainAnalysis(BuildContext context) {
    final theme = Theme.of(context);
    final domain = analysis.domainAnalysis;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Domain Analysis',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        _buildInfoRow(context, 'Domain', domain.domain),
        _buildInfoRow(context, 'Age', '${domain.domainAge} days'),
        _buildInfoRow(context, 'Registrar', domain.registrar),
        _buildInfoRow(
          context, 
          'New Domain', 
          domain.isNewDomain ? 'Yes' : 'No',
          isWarning: domain.isNewDomain,
        ),
        _buildInfoRow(
          context, 
          'Suspicious Patterns', 
          domain.hasSuspiciousPatterns ? 'Yes' : 'No',
          isWarning: domain.hasSuspiciousPatterns,
        ),
      ],
    );
  }

  Widget _buildDNSInformation(BuildContext context) {
    final theme = Theme.of(context);
    final dns = analysis.domainAnalysis.dnsInfo;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'DNS Information',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        if (dns.aRecords.isNotEmpty)
          _buildInfoRow(context, 'A Records', dns.aRecords.join(', ')),
        if (dns.mxRecords.isNotEmpty)
          _buildInfoRow(context, 'MX Records', dns.mxRecords.join(', ')),
        if (dns.nsRecords.isNotEmpty)
          _buildInfoRow(context, 'NS Records', dns.nsRecords.join(', ')),
        if (dns.txtRecord != null)
          _buildInfoRow(context, 'TXT Record', dns.txtRecord!),
      ],
    );
  }

  Widget _buildIndicators(BuildContext context) {
    final theme = Theme.of(context);

    if (analysis.indicators.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Security Indicators',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        ...analysis.indicators.map((indicator) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.warning,
                color: Colors.orange,
                size: 16,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  indicator,
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildRecommendations(BuildContext context) {
    final theme = Theme.of(context);

    if (analysis.recommendations.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recommendations',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        ...analysis.recommendations.map((recommendation) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.lightbulb,
                color: Colors.blue,
                size: 16,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  recommendation,
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _copyToClipboard(context, url),
            icon: const Icon(Icons.copy),
            label: const Text('Copy URL'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close),
            label: const Text('Close'),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value, {bool isWarning = false}) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isWarning ? Colors.orange : null,
                fontWeight: isWarning ? FontWeight.w600 : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getRiskLevelColor(String riskLevel) {
    switch (riskLevel.toLowerCase()) {
      case 'low':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'high':
        return Colors.red;
      case 'critical':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('URL copied to clipboard'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
