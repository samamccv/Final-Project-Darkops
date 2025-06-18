// lib/widgets/qr_result_display.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/qr_content_service.dart';
import '../utils/qr_action_handler.dart';
import '../dashboard/qr_code_scanner.dart';

class QRResultDisplay extends StatefulWidget {
  final QRContentData qrData;
  final VoidCallback? onScanAgain;
  final bool showAnalysisButton;
  final VoidCallback? onAnalyze;

  const QRResultDisplay({
    super.key,
    required this.qrData,
    this.onScanAgain,
    this.showAnalysisButton = true,
    this.onAnalyze,
  });

  @override
  State<QRResultDisplay> createState() => _QRResultDisplayState();
}

class _QRResultDisplayState extends State<QRResultDisplay> {
  bool isVisible = false;

  @override
  void initState() {
    super.initState();
    // Trigger entrance animation
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
    final colorScheme = theme.colorScheme;

    return Card(
          margin: const EdgeInsets.all(16),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(
              color: QRColorPalette.success.withValues(alpha: 0.2),
              width: 1.5,
            ),
          ),
          color: QRColorPalette.getSurfaceColor(isDarkMode),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  QRColorPalette.success.withValues(alpha: 0.03),
                  QRColorPalette.getSurfaceColor(isDarkMode),
                  QRColorPalette.success.withValues(alpha: 0.01),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: QRColorPalette.success.withValues(alpha: 0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                  spreadRadius: 0,
                ),
                BoxShadow(
                  color: colorScheme.shadow.withValues(alpha: 0.05),
                  blurRadius: 40,
                  offset: const Offset(0, 16),
                  spreadRadius: -8,
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(theme, isDarkMode),
                  const SizedBox(height: 20),
                  _buildContentDisplay(theme, isDarkMode),
                  const SizedBox(height: 20),
                  _buildActionButtons(theme, isDarkMode),
                ],
              ),
            ),
          ),
        )
        .animate()
        .scale(
          begin: const Offset(0.9, 0.9),
          duration: 400.ms,
          curve: Curves.easeOutBack,
        )
        .slideY(begin: 0.2, duration: 500.ms, curve: Curves.easeOutCubic)
        .fadeIn(duration: 300.ms);
  }

  Widget _buildHeader(ThemeData theme, bool isDarkMode) {
    return Row(
      children: [
        Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    QRColorPalette.success.withValues(alpha: 0.15),
                    QRColorPalette.success.withValues(alpha: 0.08),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: QRColorPalette.success.withValues(alpha: 0.2),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: QRColorPalette.success.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                _getContentTypeIcon(),
                color: QRColorPalette.success,
                size: 28,
              ),
            )
            .animate()
            .scale(
              begin: const Offset(0.8, 0.8),
              duration: 300.ms,
              curve: Curves.elasticOut,
            )
            .fadeIn(duration: 200.ms),

        const SizedBox(width: 16),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                    QRContentService.getContentTypeDisplayName(
                      widget.qrData.type,
                    ),
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: theme.colorScheme.onSurface,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                    ),
                  )
                  .animate()
                  .slideX(
                    begin: 0.3,
                    duration: 400.ms,
                    curve: Curves.easeOutCubic,
                  )
                  .fadeIn(duration: 300.ms),

              const SizedBox(height: 4),

              Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: QRColorPalette.success.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Successfully detected',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: QRColorPalette.success,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                      ),
                    ),
                  )
                  .animate()
                  .slideX(
                    begin: 0.3,
                    duration: 500.ms,
                    curve: Curves.easeOutCubic,
                  )
                  .fadeIn(duration: 400.ms),
            ],
          ),
        ),

        if (widget.onScanAgain != null)
          Container(
                decoration: BoxDecoration(
                  color: QRColorPalette.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: QRColorPalette.primary.withValues(alpha: 0.2),
                  ),
                ),
                child: IconButton(
                  icon: const Icon(Icons.refresh_rounded),
                  color: QRColorPalette.primary,
                  onPressed: widget.onScanAgain,
                  tooltip: 'Scan Again',
                  iconSize: 20,
                ),
              )
              .animate()
              .scale(
                begin: const Offset(0.8, 0.8),
                duration: 400.ms,
                curve: Curves.elasticOut,
              )
              .fadeIn(duration: 500.ms),
      ],
    );
  }

  Widget _buildContentDisplay(ThemeData theme, bool isDarkMode) {
    switch (widget.qrData.type) {
      case QRContentType.url:
        return _buildUrlContent(theme, isDarkMode);
      case QRContentType.wifi:
        return _buildWifiContent(theme, isDarkMode);
      case QRContentType.email:
        return _buildEmailContent(theme, isDarkMode);
      case QRContentType.phone:
        return _buildPhoneContent(theme, isDarkMode);
      case QRContentType.sms:
        return _buildSmsContent(theme, isDarkMode);
      case QRContentType.vcard:
        return _buildVCardContent(theme, isDarkMode);
      case QRContentType.geo:
        return _buildGeoContent(theme, isDarkMode);
      case QRContentType.text:
      case QRContentType.unknown:
        return _buildTextContent(theme, isDarkMode);
    }
  }

  Widget _buildUrlContent(ThemeData theme, bool isDarkMode) {
    final data = widget.qrData.parsedData;
    final url = data['url'] as String;
    final domain = data['domain'] as String?;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow('URL', url, theme),
        if (domain != null) _buildInfoRow('Domain', domain, theme),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => QRActionHandler.openUrl(url, context),
                icon: const Icon(Icons.open_in_new),
                label: const Text('Open URL'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: QRColorPalette.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: () => QRActionHandler.copyToClipboard(url, context),
              icon: const Icon(Icons.copy),
              color: QRColorPalette.primary,
              tooltip: 'Copy URL',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWifiContent(ThemeData theme, bool isDarkMode) {
    final data = widget.qrData.parsedData;
    final ssid = data['ssid'] as String?;
    final password = data['password'] as String?;
    final security = data['security'] as String?;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (ssid != null) _buildInfoRow('Network Name', ssid, theme),
        if (security != null) _buildInfoRow('Security', security, theme),
        if (password != null)
          _buildInfoRow('Password', password, theme, isPassword: true),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => QRActionHandler.connectToWifi(data, context),
                icon: const Icon(Icons.wifi),
                label: const Text('Connect'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: QRColorPalette.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed:
                  () => QRActionHandler.copyToClipboard(
                    'SSID: $ssid\nPassword: $password',
                    context,
                  ),
              icon: const Icon(Icons.copy),
              color: QRColorPalette.primary,
              tooltip: 'Copy WiFi Info',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEmailContent(ThemeData theme, bool isDarkMode) {
    final data = widget.qrData.parsedData;
    final email = data['email'] as String?;
    final subject = data['subject'] as String?;
    final body = data['body'] as String?;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (email != null) _buildInfoRow('Email', email, theme),
        if (subject != null) _buildInfoRow('Subject', subject, theme),
        if (body != null) _buildInfoRow('Message', body, theme),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed:
                    () => QRActionHandler.sendEmail(
                      email: email ?? '',
                      subject: subject,
                      body: body,
                      context: context,
                    ),
                icon: const Icon(Icons.email),
                label: const Text('Send Email'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: QRColorPalette.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed:
                  () => QRActionHandler.copyToClipboard(email ?? '', context),
              icon: const Icon(Icons.copy),
              color: QRColorPalette.primary,
              tooltip: 'Copy Email',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPhoneContent(ThemeData theme, bool isDarkMode) {
    final data = widget.qrData.parsedData;
    final phone = data['phone'] as String?;
    final displayPhone = data['displayPhone'] as String?;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow('Phone Number', displayPhone ?? phone ?? '', theme),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed:
                    () => QRActionHandler.makePhoneCall(phone ?? '', context),
                icon: const Icon(Icons.phone),
                label: const Text('Call'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: QRColorPalette.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton.icon(
                onPressed:
                    () =>
                        QRActionHandler.sendSMS(phone ?? '', context: context),
                icon: const Icon(Icons.message),
                label: const Text('SMS'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed:
                  () => QRActionHandler.copyToClipboard(phone ?? '', context),
              icon: const Icon(Icons.copy),
              color: QRColorPalette.primary,
              tooltip: 'Copy Number',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSmsContent(ThemeData theme, bool isDarkMode) {
    final data = widget.qrData.parsedData;
    final number = data['number'] as String?;
    final body = data['body'] as String?;
    final displayNumber = data['displayNumber'] as String?;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (number != null)
          _buildInfoRow('Phone Number', displayNumber ?? number, theme),
        if (body != null) _buildInfoRow('Message', body, theme),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed:
                    () => QRActionHandler.sendSMS(
                      number ?? '',
                      body: body,
                      context: context,
                    ),
                icon: const Icon(Icons.message),
                label: const Text('Send SMS'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: QRColorPalette.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed:
                  () => QRActionHandler.copyToClipboard(
                    'Number: $number\nMessage: $body',
                    context,
                  ),
              icon: const Icon(Icons.copy),
              color: QRColorPalette.primary,
              tooltip: 'Copy SMS Info',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildVCardContent(ThemeData theme, bool isDarkMode) {
    final data = widget.qrData.parsedData;
    final fullName = data['fullName'] as String?;
    final organization = data['organization'] as String?;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (fullName != null) _buildInfoRow('Name', fullName, theme),
        if (organization != null)
          _buildInfoRow('Organization', organization, theme),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => QRActionHandler.saveContact(data, context),
                icon: const Icon(Icons.person_add),
                label: const Text('View Contact'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: QRColorPalette.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed:
                  () => QRActionHandler.copyToClipboard(
                    widget.qrData.rawContent,
                    context,
                  ),
              icon: const Icon(Icons.copy),
              color: QRColorPalette.primary,
              tooltip: 'Copy vCard',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGeoContent(ThemeData theme, bool isDarkMode) {
    final data = widget.qrData.parsedData;
    final latitude = data['latitude'] as double?;
    final longitude = data['longitude'] as double?;
    final displayCoordinates = data['displayCoordinates'] as String?;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (displayCoordinates != null)
          _buildInfoRow('Coordinates', displayCoordinates, theme),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed:
                    latitude != null && longitude != null
                        ? () => QRActionHandler.openMaps(
                          latitude,
                          longitude,
                          context,
                        )
                        : null,
                icon: const Icon(Icons.map),
                label: const Text('Open Maps'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: QRColorPalette.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed:
                  () => QRActionHandler.copyToClipboard(
                    displayCoordinates ?? widget.qrData.rawContent,
                    context,
                  ),
              icon: const Icon(Icons.copy),
              color: QRColorPalette.primary,
              tooltip: 'Copy Coordinates',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTextContent(ThemeData theme, bool isDarkMode) {
    final content = widget.qrData.rawContent;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: QRColorPalette.getPrimaryWithOpacity(isDarkMode, 0.05),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: QRColorPalette.getPrimaryWithOpacity(isDarkMode, 0.1),
            ),
          ),
          child: Text(
            content,
            style: TextStyle(
              fontSize: 14,
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => QRActionHandler.copyToClipboard(content, context),
            icon: const Icon(Icons.copy),
            label: const Text('Copy Text'),
            style: ElevatedButton.styleFrom(
              backgroundColor: QRColorPalette.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(
    String label,
    String value,
    ThemeData theme, {
    bool isPassword = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 14,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              isPassword ? '•' * value.length : value,
              style: TextStyle(
                fontSize: 14,
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(ThemeData theme, bool isDarkMode) {
    if (!widget.showAnalysisButton || widget.onAnalyze == null) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 20),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.08),
            width: 1,
          ),
        ),
      ),
      child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  QRColorPalette.primary.withValues(alpha: 0.05),
                  QRColorPalette.primaryLight.withValues(alpha: 0.02),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: QRColorPalette.primary.withValues(alpha: 0.2),
                width: 1.5,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: widget.onAnalyze,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 20,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.security_rounded,
                        color: QRColorPalette.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Security Analysis',
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: QRColorPalette.primary,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
          .animate()
          .slideY(begin: 0.3, duration: 600.ms, curve: Curves.easeOutBack)
          .fadeIn(duration: 500.ms),
    );
  }

  IconData _getContentTypeIcon() {
    switch (widget.qrData.type) {
      case QRContentType.url:
        return Icons.language;
      case QRContentType.wifi:
        return Icons.wifi;
      case QRContentType.email:
        return Icons.email;
      case QRContentType.phone:
        return Icons.phone;
      case QRContentType.sms:
        return Icons.message;
      case QRContentType.vcard:
        return Icons.contact_page;
      case QRContentType.geo:
        return Icons.location_on;
      case QRContentType.text:
        return Icons.text_fields;
      case QRContentType.unknown:
        return Icons.help_outline;
    }
  }
}
