import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:path_provider/path_provider.dart';
import 'package:universal_html/html.dart' as html;
import '../models/scan/scan_models.dart';

class UrlAnalysisResults extends StatefulWidget {
  final UrlAnalysisResponse results;
  final String scannedUrl;
  final VoidCallback? onScanAgain;

  const UrlAnalysisResults({
    super.key,
    required this.results,
    required this.scannedUrl,
    this.onScanAgain,
  });

  @override
  State<UrlAnalysisResults> createState() => _UrlAnalysisResultsState();
}

class _UrlAnalysisResultsState extends State<UrlAnalysisResults>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: _getBackgroundColor(isDarkMode),
      appBar: AppBar(
        backgroundColor: _getBackgroundColor(isDarkMode),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFFBBF24).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.language,
                color: Color(0xFFFBBF24),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'URL Analysis Results',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        actions: [
          if (widget.onScanAgain != null)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: widget.onScanAgain,
              tooltip: 'Scan Another URL',
            ),
        ],
      ),
      body: Column(
        children: [
          // URL Header
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _getSurfaceColor(isDarkMode),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.language,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.scannedUrl,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                _buildThreatIndicator(),
              ],
            ),
          ),

          // Tab Bar
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: _getSurfaceColor(isDarkMode),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              indicator: BoxDecoration(
                color: const Color(0xFFFBBF24),
                borderRadius: BorderRadius.circular(8),
              ),
              labelColor: Colors.white,
              unselectedLabelColor: theme.colorScheme.onSurface.withValues(
                alpha: 0.7,
              ),
              labelStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              tabs: const [
                Tab(text: 'Overview'),
                Tab(text: 'Security'),
                Tab(text: 'Certificates'),
                Tab(text: 'Reputation'),
                Tab(text: 'Screenshot'),
                Tab(text: 'Scan Engines'),
              ],
            ),
          ),

          // Tab Content
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildOverviewTab(),
                  _buildSecurityTab(),
                  _buildCertificatesTab(),
                  _buildReputationTab(),
                  _buildScreenshotTab(),
                  _buildScanEnginesTab(),
                ],
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _buildThreatIndicator() {
    final phishingAnalysis = widget.results.phishingAnalysis;
    final isSafe = phishingAnalysis?.isSafe ?? true;

    Color indicatorColor;
    String indicatorText;
    IconData indicatorIcon;

    if (isSafe) {
      indicatorColor = Colors.green;
      indicatorText = 'Safe';
      indicatorIcon = Icons.check_circle;
    } else {
      indicatorColor = Colors.red;
      indicatorText = 'Threat';
      indicatorIcon = Icons.warning;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: indicatorColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: indicatorColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(indicatorIcon, color: indicatorColor, size: 16),
          const SizedBox(width: 4),
          Text(
            indicatorText,
            style: TextStyle(
              color: indicatorColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSection(
            title: 'Basic Information',
            icon: Icons.info_outline,
            child: _buildBasicInfo(),
          ),
          const SizedBox(height: 16),
          _buildSection(
            title: 'Phishing Analysis',
            icon: Icons.security,
            child: _buildPhishingAnalysis(),
          ),
          const SizedBox(height: 16),
          _buildSection(
            title: 'Behavior Analysis',
            icon: Icons.analytics,
            child: _buildBehaviorAnalysis(),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSection(
            title: 'Security Analysis',
            icon: Icons.security,
            child: _buildSecurityAnalysis(),
          ),
          const SizedBox(height: 16),
          _buildSection(
            title: 'Enhanced Security',
            icon: Icons.enhanced_encryption,
            child: _buildEnhancedSecurity(),
          ),
        ],
      ),
    );
  }

  Widget _buildCertificatesTab() {
    return SingleChildScrollView(
      child: _buildSection(
        title: 'SSL Certificates',
        icon: Icons.verified_user,
        child: _buildCertificates(),
      ),
    );
  }

  Widget _buildReputationTab() {
    return SingleChildScrollView(
      child: _buildSection(
        title: 'Domain Reputation',
        icon: Icons.star_rate,
        child: _buildReputation(),
      ),
    );
  }

  Widget _buildScreenshotTab() {
    return SingleChildScrollView(
      child: _buildSection(
        title: 'Website Screenshot',
        icon: Icons.screenshot,
        child: _buildScreenshot(),
      ),
    );
  }

  Widget _buildScanEnginesTab() {
    return SingleChildScrollView(
      child: _buildSection(
        title: 'Scan Engine Results',
        icon: Icons.radar,
        child: _buildScanEngines(),
      ),
    );
  }

  Color _getBackgroundColor(bool isDarkMode) {
    return isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFF8FAFF);
  }

  Color _getSurfaceColor(bool isDarkMode) {
    return isDarkMode ? const Color(0xFF1E293B) : Colors.white;
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _getSurfaceColor(isDarkMode),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: const Color(0xFFFBBF24)),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildBasicInfo() {
    final basicInfo = widget.results.urlAnalysis?.basicInfo;

    if (basicInfo == null) {
      return const Text('No basic information available');
    }

    return Column(
      children: [
        _buildInfoRow('Domain', basicInfo.domain ?? 'N/A'),
        _buildInfoRow('IP Address', basicInfo.ip ?? 'N/A'),
        _buildInfoRow('Country', basicInfo.country ?? 'N/A'),
        _buildInfoRow('Server', basicInfo.server ?? 'N/A'),
        _buildInfoRow('Security State', basicInfo.securityState ?? 'N/A'),
        if (basicInfo.finalUrl != null &&
            basicInfo.finalUrl != widget.scannedUrl)
          _buildInfoRow('Final URL', basicInfo.finalUrl!),
      ],
    );
  }

  Widget _buildPhishingAnalysis() {
    final phishingAnalysis = widget.results.phishingAnalysis;

    if (phishingAnalysis == null) {
      return const Text('No phishing analysis available');
    }

    return Column(
      children: [
        _buildInfoRow('Prediction', phishingAnalysis.prediction ?? 'N/A'),
        _buildInfoRow(
          'Is Safe',
          phishingAnalysis.isSafe == true ? 'Yes' : 'No',
        ),
        _buildInfoRow(
          'Confidence',
          '${((phishingAnalysis.confidence ?? 0.0) * 100).toStringAsFixed(1)}%',
        ),
      ],
    );
  }

  Widget _buildBehaviorAnalysis() {
    final behavior = widget.results.urlAnalysis?.behavior;

    if (behavior == null) {
      return const Text('No behavior analysis available');
    }

    return Column(
      children: [
        _buildInfoRow('Requests', '${behavior.requests ?? 0}'),
        _buildInfoRow('Domains', '${behavior.domains ?? 0}'),
        _buildInfoRow('Redirects', '${behavior.redirects ?? 0}'),
        _buildInfoRow('Mixed Content', '${behavior.mixedContent ?? 0}'),
      ],
    );
  }

  Widget _buildSecurityAnalysis() {
    final security = widget.results.urlAnalysis?.security;

    if (security == null) {
      return const Text('No security analysis available');
    }

    return Column(
      children: [
        _buildInfoRow('Malicious', security.malicious == true ? 'Yes' : 'No'),
        _buildInfoRow('Security Score', '${security.score ?? 0}/10'),
        if (security.categories?.isNotEmpty == true)
          _buildInfoRow('Categories', security.categories!.join(', ')),
        if (security.threats?.isNotEmpty == true)
          _buildInfoRow('Threats', security.threats!.join(', ')),
      ],
    );
  }

  Widget _buildEnhancedSecurity() {
    final enhancedSecurity = widget.results.urlAnalysis?.enhancedSecurity;

    if (enhancedSecurity == null) {
      return const Text('No enhanced security data available');
    }

    return Column(
      children: [
        _buildInfoRow(
          'Mixed Content',
          enhancedSecurity.mixedContent == true ? 'Yes' : 'No',
        ),
        _buildInfoRow(
          'Suspicious Redirects',
          enhancedSecurity.suspiciousRedirects == true ? 'Yes' : 'No',
        ),
        _buildInfoRow(
          'Insecure Cookies',
          enhancedSecurity.insecureCookies == true ? 'Yes' : 'No',
        ),
      ],
    );
  }

  Widget _buildCertificates() {
    final certificates = widget.results.urlAnalysis?.security?.certificates;

    if (certificates == null || certificates.isEmpty) {
      return const Text('No certificate information available');
    }

    return Column(
      children:
          certificates
              .map(
                (cert) => Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      _buildInfoRow('Subject', cert.subjectName ?? 'N/A'),
                      _buildInfoRow('Issuer', cert.issuer ?? 'N/A'),
                      if (cert.validFrom != null)
                        _buildInfoRow(
                          'Valid From',
                          DateTime.fromMillisecondsSinceEpoch(
                            cert.validFrom! * 1000,
                          ).toString(),
                        ),
                      if (cert.validTo != null)
                        _buildInfoRow(
                          'Valid To',
                          DateTime.fromMillisecondsSinceEpoch(
                            cert.validTo! * 1000,
                          ).toString(),
                        ),
                    ],
                  ),
                ),
              )
              .toList(),
    );
  }

  Widget _buildReputation() {
    final reputation = widget.results.urlAnalysis?.reputation;

    if (reputation == null) {
      return const Text('No reputation data available');
    }

    return Column(
      children: [
        if (reputation.domainAge != null) ...[
          const Text(
            'Domain Age',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          if (reputation.domainAge!.error != null)
            _buildInfoRow('Error', reputation.domainAge!.error!)
          else ...[
            if (reputation.domainAge!.registrationDate != null)
              _buildInfoRow(
                'Registration Date',
                reputation.domainAge!.registrationDate!,
              ),
            if (reputation.domainAge!.ageDays != null)
              _buildInfoRow('Age (Days)', '${reputation.domainAge!.ageDays}'),
          ],
          const SizedBox(height: 16),
        ],
        if (reputation.sslValidity != null) ...[
          const Text(
            'SSL Validity',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            'Valid',
            reputation.sslValidity!.valid == true ? 'Yes' : 'No',
          ),
          if (reputation.sslValidity!.reason != null)
            _buildInfoRow('Reason', reputation.sslValidity!.reason!),
          const SizedBox(height: 16),
        ],
        if (reputation.blacklistStatus != null)
          _buildInfoRow('Blacklist Status', reputation.blacklistStatus!),
      ],
    );
  }

  Widget _buildScreenshot() {
    final scanInfo = widget.results.urlAnalysis?.scanInfo;
    final screenshotUrl = scanInfo?.screenshotUrl ?? scanInfo?.screenshotPath;

    if (screenshotUrl == null || screenshotUrl.isEmpty) {
      return const Center(
        child: Column(
          children: [
            Icon(Icons.image_not_supported, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No screenshot available for this URL'),
          ],
        ),
      );
    }

    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: _buildScreenshotImage(screenshotUrl),
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: () => _downloadScreenshot(screenshotUrl),
          icon: const Icon(Icons.file_download),
          label: const Text('Download Screenshot'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFBBF24),
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildScanEngines() {
    final scanEngines = widget.results.scanEngines;

    if (scanEngines == null || scanEngines.isEmpty) {
      return const Text('No scan engine results available');
    }

    return Column(
      children:
          scanEngines
              .map(
                (engine) => Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      _buildInfoRow('Engine', engine.name),
                      _buildInfoRow('Result', engine.result),
                      _buildInfoRow(
                        'Confidence',
                        '${(engine.confidence * 100).toStringAsFixed(1)}%',
                      ),
                      if (engine.riskLevel != null)
                        _buildInfoRow('Risk Level', engine.riskLevel!),
                      if (engine.details != null)
                        _buildInfoRow('Details', engine.details!),
                    ],
                  ),
                ),
              )
              .toList(),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w400),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScreenshotImage(String screenshotUrl) {
    if (screenshotUrl.startsWith('data:image/')) {
      try {
        final base64Data = screenshotUrl.split(',')[1];
        final bytes = base64Decode(base64Data);
        return Image.memory(
          bytes,
          fit: BoxFit.contain,
          width: double.infinity,
          height: 300,
          errorBuilder: (context, error, stackTrace) {
            return const Center(
              child: Column(
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red),
                  SizedBox(height: 16),
                  Text('Failed to load screenshot'),
                ],
              ),
            );
          },
        );
      } catch (e) {
        return const Center(
          child: Column(
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red),
              SizedBox(height: 16),
              Text('Failed to decode screenshot data'),
            ],
          ),
        );
      }
    } else {
      return Image.network(
        screenshotUrl,
        fit: BoxFit.contain,
        width: double.infinity,
        height: 300,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return SizedBox(
            height: 300,
            child: Center(
              child: CircularProgressIndicator(
                value:
                    loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                        : null,
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return const Center(
            child: Column(
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red),
                SizedBox(height: 16),
                Text('Failed to load screenshot'),
              ],
            ),
          );
        },
      );
    }
  }

  Future<void> _downloadScreenshot(String screenshotUrl) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'url_screenshot_$timestamp.jpg';

      if (kIsWeb) {
        await _downloadScreenshotWeb(screenshotUrl, fileName);
      } else {
        await _downloadScreenshotMobile(screenshotUrl, fileName);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Screenshot saved as $fileName'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to download screenshot: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _downloadScreenshotWeb(
    String screenshotUrl,
    String fileName,
  ) async {
    if (screenshotUrl.startsWith('data:image/')) {
      final base64Data = screenshotUrl.split(',')[1];
      final bytes = base64Decode(base64Data);

      final blob = html.Blob([bytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      html.AnchorElement(href: url)
        ..setAttribute('download', fileName)
        ..click();
      html.Url.revokeObjectUrl(url);
    } else {
      html.AnchorElement(href: screenshotUrl)
        ..setAttribute('download', fileName)
        ..click();
    }
  }

  Future<void> _downloadScreenshotMobile(
    String screenshotUrl,
    String fileName,
  ) async {
    if (screenshotUrl.startsWith('data:image/')) {
      final base64Data = screenshotUrl.split(',')[1];
      final bytes = base64Decode(base64Data);

      final directory = await getDownloadsDirectory();
      if (directory != null) {
        final file = File('${directory.path}/$fileName');
        await file.writeAsBytes(bytes);
      } else {
        final directory = await getExternalStorageDirectory();
        if (directory != null) {
          final file = File('${directory.path}/$fileName');
          await file.writeAsBytes(bytes);
        }
      }
    } else {
      throw Exception('Network URL download not implemented for mobile');
    }
  }
}
