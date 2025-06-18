// lib/widgets/qr_scanner/enhanced_qr_results.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/qr_content_service.dart';
import '../../services/qr_analysis_manager.dart';
import 'phishing_analysis_results.dart';

/// Enhanced QR results display matching frontend patterns
class EnhancedQRResults extends StatelessWidget {
  final QRAnalysisResult analysisResult;
  final VoidCallback? onClose;

  const EnhancedQRResults({
    super.key,
    required this.analysisResult,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final contentData = analysisResult.contentData;

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(context),
          const SizedBox(height: 16),
          if (analysisResult.hasError)
            _buildErrorDisplay(context)
          else if (analysisResult.isUrl && analysisResult.hasPhishingAnalysis)
            _buildPhishingResults(context)
          else
            _buildContentResults(context),
          const SizedBox(height: 20),
          _buildActionButtons(context),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    final contentData = analysisResult.contentData;
    final iconName = QRContentService.getContentTypeIcon(contentData.type);
    final typeName = QRContentService.getContentTypeDisplayName(contentData.type);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primaryContainer,
            theme.colorScheme.primaryContainer.withValues(alpha: 0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getIconData(iconName),
              color: theme.colorScheme.onPrimaryContainer,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'QR Code Detected',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  typeName,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          if (onClose != null)
            IconButton(
              onPressed: onClose,
              icon: Icon(
                Icons.close,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildErrorDisplay(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Icon(Icons.error, color: Colors.red, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Analysis Failed',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    analysisResult.error ?? 'Unknown error occurred',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhishingResults(BuildContext context) {
    return PhishingAnalysisResults(
      analysis: analysisResult.phishingAnalysis!,
      url: analysisResult.contentData.rawContent,
    );
  }

  Widget _buildContentResults(BuildContext context) {
    final theme = Theme.of(context);
    final contentData = analysisResult.contentData;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildContentDisplay(context),
          const SizedBox(height: 16),
          if (contentData.parsedData.isNotEmpty)
            _buildParsedDataDisplay(context),
        ],
      ),
    );
  }

  Widget _buildContentDisplay(BuildContext context) {
    final theme = Theme.of(context);
    final content = analysisResult.contentData.rawContent;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.content_copy,
                size: 16,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              const SizedBox(width: 8),
              Text(
                'Content',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SelectableText(
            content,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParsedDataDisplay(BuildContext context) {
    final theme = Theme.of(context);
    final parsedData = analysisResult.contentData.parsedData;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 16,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              const SizedBox(width: 8),
              Text(
                'Details',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...parsedData.entries.map((entry) => _buildDataRow(context, entry.key, entry.value)),
        ],
      ),
    );
  }

  Widget _buildDataRow(BuildContext context, String key, dynamic value) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              _formatKey(key),
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ),
          Expanded(
            child: Text(
              _formatValue(value),
              style: theme.textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final contentData = analysisResult.contentData;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _copyToClipboard(context, contentData.rawContent),
              icon: const Icon(Icons.copy),
              label: const Text('Copy'),
            ),
          ),
          const SizedBox(width: 12),
          if (contentData.type == QRContentType.url)
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _openUrl(context, contentData.rawContent),
                icon: const Icon(Icons.open_in_new),
                label: const Text('Open'),
              ),
            ),
          if (contentData.type != QRContentType.url)
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _handleAction(context, contentData),
                icon: Icon(_getActionIcon(contentData.type)),
                label: Text(_getActionLabel(contentData.type)),
              ),
            ),
        ],
      ),
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'language':
        return Icons.language;
      case 'wifi':
        return Icons.wifi;
      case 'email':
        return Icons.email;
      case 'phone':
        return Icons.phone;
      case 'message':
        return Icons.message;
      case 'contact_page':
        return Icons.contact_page;
      case 'location_on':
        return Icons.location_on;
      case 'text_fields':
        return Icons.text_fields;
      default:
        return Icons.help_outline;
    }
  }

  IconData _getActionIcon(QRContentType type) {
    switch (type) {
      case QRContentType.phone:
        return Icons.call;
      case QRContentType.sms:
        return Icons.message;
      case QRContentType.email:
        return Icons.email;
      case QRContentType.geo:
        return Icons.map;
      case QRContentType.wifi:
        return Icons.wifi;
      default:
        return Icons.share;
    }
  }

  String _getActionLabel(QRContentType type) {
    switch (type) {
      case QRContentType.phone:
        return 'Call';
      case QRContentType.sms:
        return 'Message';
      case QRContentType.email:
        return 'Email';
      case QRContentType.geo:
        return 'Map';
      case QRContentType.wifi:
        return 'Connect';
      default:
        return 'Share';
    }
  }

  String _formatKey(String key) {
    return key.replaceAllMapped(
      RegExp(r'([A-Z])'),
      (match) => ' ${match.group(1)}',
    ).trim().split(' ').map((word) => 
      word[0].toUpperCase() + word.substring(1)
    ).join(' ');
  }

  String _formatValue(dynamic value) {
    if (value is List) {
      return value.join(', ');
    } else if (value is Map) {
      return value.entries.map((e) => '${e.key}: ${e.value}').join(', ');
    }
    return value.toString();
  }

  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Content copied to clipboard'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _openUrl(BuildContext context, String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        _showErrorSnackBar(context, 'Cannot open URL');
      }
    } catch (e) {
      _showErrorSnackBar(context, 'Invalid URL format');
    }
  }

  void _handleAction(BuildContext context, QRContentData contentData) {
    // Handle different content type actions
    switch (contentData.type) {
      case QRContentType.phone:
        _openUrl(context, 'tel:${contentData.parsedData['phone']}');
        break;
      case QRContentType.sms:
        _openUrl(context, 'sms:${contentData.parsedData['number']}');
        break;
      case QRContentType.email:
        _openUrl(context, 'mailto:${contentData.parsedData['email']}');
        break;
      case QRContentType.geo:
        _openUrl(context, contentData.parsedData['mapsUrl'] ?? contentData.rawContent);
        break;
      default:
        _copyToClipboard(context, contentData.rawContent);
    }
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
