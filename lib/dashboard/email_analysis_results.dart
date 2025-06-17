import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/scan/scan_models.dart';

class EmailAnalysisResults extends StatefulWidget {
  final EmailAnalysisResponse results;
  final String fileName;
  final VoidCallback onAnalyzeAgain;

  const EmailAnalysisResults({
    super.key,
    required this.results,
    required this.fileName,
    required this.onAnalyzeAgain,
  });

  @override
  State<EmailAnalysisResults> createState() => _EmailAnalysisResultsState();
}

class _EmailAnalysisResultsState extends State<EmailAnalysisResults>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
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
                color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.email_outlined,
                color: Color(0xFF3B82F6),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Email Analysis Results',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildHeader(),
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(),
                _buildHeadersTab(),
                _buildTechnicalTab(),
                _buildScreenshotTab(),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _buildHeader() {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _getSurfaceColor(isDarkMode),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color:
              widget.results.isPhishing
                  ? Colors.red.withValues(alpha: 0.3)
                  : Colors.green.withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: TextButton.icon(
                  onPressed: widget.onAnalyzeAgain,
                  icon: const Icon(Icons.arrow_back, size: 16),
                  label: const Text(
                    'Analyze Another Email',
                    overflow: TextOverflow.ellipsis,
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF3B82F6),
                  ),
                ),
              ),
              Flexible(
                child: Text(
                  'Analysis: ${_formatTimestamp(widget.results.analysisTimestamp)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: widget.results.isPhishing ? Colors.red : Colors.green,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  widget.results.isPhishing ? 'PHISHING' : 'LEGIT',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.results.isPhishing
                      ? 'This email appears to be a phishing attempt'
                      : 'This email appears to be legitimate and safe',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onSurface,
                  ),
                  softWrap: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Confidence: ${widget.results.confidence.toStringAsFixed(2)}%',
            style: TextStyle(
              fontSize: 14,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: TabBar(
        controller: _tabController,
        labelColor: const Color(0xFF3B82F6),
        unselectedLabelColor: Colors.grey,
        indicatorColor: const Color(0xFF3B82F6),
        indicatorWeight: 3,
        labelStyle: const TextStyle(fontWeight: FontWeight.w600),
        tabs: const [
          Tab(text: 'Overview'),
          Tab(text: 'Headers'),
          Tab(text: 'Technical'),
          Tab(text: 'Screenshot'),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.results.headers.isEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
              ),
              child: const Text(
                'Debug: Email headers are empty - this might indicate a parsing issue.',
                style: TextStyle(fontSize: 12, color: Colors.orange),
              ),
            ),
          if (widget.results.headers.isEmpty) const SizedBox(height: 16),

          _buildEmailInformationSection(),
          const SizedBox(height: 24),
          _buildSenderInformationSection(),
          const SizedBox(height: 24),
          _buildSecurityInformationSection(),
          const SizedBox(height: 24),

          _buildScanEnginesSection(),

          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Debug Information:',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text('Headers count: ${widget.results.headers.length}'),
                Text('Attachments count: ${widget.results.attachments.length}'),
                Text(
                  'Scan engines count: ${widget.results.scanEngines?.length ?? 0}',
                ),
                Text('Sender IP: ${widget.results.senderIp ?? "null"}'),
                Text('Analysis timestamp: ${widget.results.analysisTimestamp}'),
                Text('Confidence: ${widget.results.confidence}'),
                Text('Is phishing: ${widget.results.isPhishing}'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmailInformationSection() {
    return _buildSection(
      title: 'Email Information',
      children: [
        Row(
          children: [
            Expanded(
              child: _buildInfoCard(
                'From',
                widget.results.fromEmail.isNotEmpty
                    ? widget.results.fromEmail
                    : 'Not available',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildInfoCard(
                'To',
                widget.results.toEmail.isNotEmpty
                    ? widget.results.toEmail
                    : 'Not available',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildInfoCard(
                'Subject',
                widget.results.subject.isNotEmpty
                    ? widget.results.subject
                    : 'No Subject',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildInfoCard(
                'Date',
                widget.results.dateString.isNotEmpty
                    ? widget.results.dateString
                    : 'Unknown',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSenderInformationSection() {
    final ipInfo = widget.results.ipInfo?.ipinfo;
    final abuseInfo = widget.results.ipInfo?.abuseipdb;

    final locationText =
        ipInfo?.locationString != null && ipInfo!.locationString!.isNotEmpty
            ? ipInfo.locationString!
            : 'Unknown';
    final ispText =
        ipInfo?.org != null && ipInfo!.org!.isNotEmpty
            ? ipInfo.org!
            : 'Unknown';
    final senderIpText =
        widget.results.senderIp != null && widget.results.senderIp!.isNotEmpty
            ? widget.results.senderIp!
            : 'Unknown';

    return _buildSection(
      title: 'Sender Information',
      children: [
        Row(
          children: [
            Expanded(child: _buildInfoCard('IP Address', senderIpText)),
            const SizedBox(width: 12),
            Expanded(child: _buildInfoCard('Location', locationText)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildInfoCard('ISP', ispText)),
            const SizedBox(width: 12),
            Expanded(
              child: _buildInfoCard(
                'Abuse Score',
                '${abuseInfo?.abuseConfidenceScore ?? 0}%',
                valueColor: _getAbuseScoreColor(
                  abuseInfo?.abuseConfidenceScore ?? 0,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSecurityInformationSection() {
    final authResults =
        widget.results.headers['Authentication-Results'] as String?;
    final spfStatus =
        authResults?.contains('spf=pass') == true ? 'PASSED' : 'FAILED';
    final dkimStatus =
        authResults?.contains('dkim=pass') == true ? 'PASSED' : 'FAILED';

    return _buildSection(
      title: 'Security Information',
      children: [
        Row(
          children: [
            Expanded(
              child: _buildInfoCard(
                'SPF',
                spfStatus,
                valueColor: _getAuthStatusColor(spfStatus),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildInfoCard(
                'DKIM',
                dkimStatus,
                valueColor: _getAuthStatusColor(dkimStatus),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildInfoCard(
                'Attachments',
                '${widget.results.attachments.length}',
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(child: SizedBox()),
          ],
        ),
      ],
    );
  }

  Widget _buildScanEnginesSection() {
    return _buildSection(
      title: 'Scan Engines',
      children: [
        if (widget.results.scanEngines?.isNotEmpty == true)
          ...widget.results.scanEngines!.map(
            (engine) => _buildScanEngineCard(engine),
          )
        else
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.grey, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'No scan engine results available for this email.',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildScanEngineCard(EmailScanEngine engine) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                engine.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color:
                      engine.isThreat
                          ? Colors.red.withValues(alpha: 0.1)
                          : Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  engine.result,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: engine.isThreat ? Colors.red : Colors.green,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildEngineDetailRow(
            'Confidence',
            '${engine.confidence.toStringAsFixed(2)}%',
          ),
          if (engine.riskLevel != null)
            _buildEngineDetailRow('Risk Level', engine.riskLevel!),
          if (engine.details != null)
            _buildEngineDetailRow('Details', engine.details!),
          if (engine.updateDate != null)
            _buildEngineDetailRow(
              'Updated',
              _formatTimestamp(engine.updateDate!),
            ),
        ],
      ),
    );
  }

  Widget _buildEngineDetailRow(String label, String value) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 12,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
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

  Widget _buildHeadersTab() {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Container(
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
            const Text(
              'Email Headers',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Container(
                  constraints: BoxConstraints(
                    minWidth: MediaQuery.of(context).size.width - 96,
                  ),
                  child: Text(
                    widget.results.headers.entries
                        .map((entry) => '${entry.key}: ${entry.value}')
                        .join('\n'),
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                      height: 1.4,
                      color: theme.colorScheme.onSurface,
                    ),
                    softWrap: true,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTechnicalTab() {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Container(
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
            const Text(
              'Technical Details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Container(
                  constraints: BoxConstraints(
                    minWidth:
                        MediaQuery.of(context).size.width -
                        96, // Account for padding
                  ),
                  child: Text(
                    _formatJsonForDisplay(),
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                      height: 1.4,
                      color: theme.colorScheme.onSurface,
                    ),
                    softWrap: true,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScreenshotTab() {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Container(
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
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Email Screenshot',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              height: 300,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child:
                    widget.results.screenshotUrl != null &&
                            widget.results.screenshotUrl!.isNotEmpty
                        ? Image.network(
                          widget.results.screenshotUrl!,
                          fit: BoxFit.contain,
                          width: double.infinity,
                          height: 300,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              height: 300,
                              width: double.infinity,
                              child: Center(
                                child: CircularProgressIndicator(
                                  value:
                                      loadingProgress.expectedTotalBytes != null
                                          ? loadingProgress
                                                  .cumulativeBytesLoaded /
                                              loadingProgress
                                                  .expectedTotalBytes!
                                          : null,
                                ),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return _buildScreenshotPlaceholder(
                              'Failed to load email preview',
                              Icons.error_outline,
                            );
                          },
                        )
                        : _buildScreenshotPlaceholder(
                          'Email preview not available for this message',
                          Icons.image_not_supported,
                        ),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                widget.results.screenshotUrl != null &&
                        widget.results.screenshotUrl!.isNotEmpty
                    ? 'This is a screenshot of how the email appears to recipients.'
                    : 'Screenshot generation is not available for this email format.',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
                textAlign: TextAlign.center,
                softWrap: true,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScreenshotPlaceholder([String? message, IconData? icon]) {
    return Container(
      height: 300,
      width: double.infinity,
      color: Colors.grey[200],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon ?? Icons.image_not_supported,
              size: 48,
              color: Colors.grey,
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                message ?? 'Email Preview Not Available',
                style: const TextStyle(color: Colors.grey, fontSize: 14),
                textAlign: TextAlign.center,
                softWrap: true,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildInfoCard(String label, String value, {Color? valueColor}) {
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
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: valueColor ?? theme.colorScheme.onSurface,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            softWrap: true,
          ),
        ],
      ),
    );
  }

  Color _getBackgroundColor(bool isDarkMode) {
    return isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFF8FAFF);
  }

  Color _getSurfaceColor(bool isDarkMode) {
    return isDarkMode ? const Color(0xFF1E293B) : Colors.white;
  }

  Color _getAuthStatusColor(String status) {
    if (status.toLowerCase().contains('pass')) return Colors.green;
    if (status.toLowerCase().contains('fail')) return Colors.red;
    return Colors.grey;
  }

  Color _getAbuseScoreColor(int score) {
    if (score < 20) return Colors.green;
    if (score < 50) return Colors.orange;
    return Colors.red;
  }

  String _formatTimestamp(String timestamp) {
    try {
      final date = DateTime.parse(timestamp);
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return timestamp;
    }
  }

  String _formatJsonForDisplay() {
    final Map<String, dynamic> displayData = {
      'file_name': widget.fileName,
      'analysis_timestamp': widget.results.analysisTimestamp,
      'phishing_detection': {
        'is_phishing': widget.results.isPhishing,
        'confidence': widget.results.confidence,
        'threat_level': widget.results.threatLevel,
        'prediction': widget.results.phishingDetection.prediction,
        'prediction_label': widget.results.phishingDetection.predictionLabel,
      },
      'sender_ip': widget.results.senderIp,
      'ip_info':
          widget.results.ipInfo != null
              ? {
                'location': widget.results.ipInfo!.ipinfo?.locationString,
                'org': widget.results.ipInfo!.ipinfo?.org,
                'abuse_score':
                    widget.results.ipInfo!.abuseipdb?.abuseConfidenceScore,
              }
              : null,
      'attachments_count': widget.results.attachments.length,
      'scan_engines_count': widget.results.scanEngines?.length ?? 0,
    };

    final buffer = StringBuffer();
    _writeJsonObject(buffer, displayData, 0);
    return buffer.toString();
  }

  void _writeJsonObject(
    StringBuffer buffer,
    Map<String, dynamic> obj,
    int indent,
  ) {
    final indentStr = '  ' * indent;
    buffer.writeln('{');
    final entries = obj.entries.toList();
    for (int i = 0; i < entries.length; i++) {
      final entry = entries[i];
      buffer.write('$indentStr  "${entry.key}": ');
      _writeJsonValue(buffer, entry.value, indent + 1);
      if (i < entries.length - 1) buffer.write(',');
      buffer.writeln();
    }
    buffer.write('$indentStr}');
  }

  void _writeJsonValue(StringBuffer buffer, dynamic value, int indent) {
    if (value == null) {
      buffer.write('null');
    } else if (value is String) {
      buffer.write('"$value"');
    } else if (value is num || value is bool) {
      buffer.write(value.toString());
    } else if (value is Map<String, dynamic>) {
      _writeJsonObject(buffer, value, indent);
    } else {
      buffer.write('"${value.toString()}"');
    }
  }
}
