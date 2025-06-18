// lib/utils/qr_action_handler.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/qr_content_service.dart';

/// Handles actions for different QR content types
class QRActionHandler {
  /// Copy text to clipboard
  static Future<void> copyToClipboard(String text, BuildContext context) async {
    try {
      await Clipboard.setData(ClipboardData(text: text));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Copied to clipboard'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to copy to clipboard'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Open URL in browser
  static Future<void> openUrl(String url, BuildContext context) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch $url';
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to open URL: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Make phone call
  static Future<void> makePhoneCall(String phoneNumber, BuildContext context) async {
    try {
      final uri = Uri.parse('tel:$phoneNumber');
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        throw 'Could not make phone call';
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to make phone call: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Send SMS
  static Future<void> sendSMS(String phoneNumber, {String? body, required BuildContext context}) async {
    try {
      String smsUrl = 'sms:$phoneNumber';
      if (body != null && body.isNotEmpty) {
        smsUrl += '?body=${Uri.encodeComponent(body)}';
      }
      
      final uri = Uri.parse(smsUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        throw 'Could not send SMS';
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send SMS: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Send email
  static Future<void> sendEmail({
    required String email,
    String? subject,
    String? body,
    String? cc,
    String? bcc,
    required BuildContext context,
  }) async {
    try {
      String emailUrl = 'mailto:$email';
      final queryParams = <String>[];
      
      if (subject != null && subject.isNotEmpty) {
        queryParams.add('subject=${Uri.encodeComponent(subject)}');
      }
      if (body != null && body.isNotEmpty) {
        queryParams.add('body=${Uri.encodeComponent(body)}');
      }
      if (cc != null && cc.isNotEmpty) {
        queryParams.add('cc=${Uri.encodeComponent(cc)}');
      }
      if (bcc != null && bcc.isNotEmpty) {
        queryParams.add('bcc=${Uri.encodeComponent(bcc)}');
      }
      
      if (queryParams.isNotEmpty) {
        emailUrl += '?${queryParams.join('&')}';
      }
      
      final uri = Uri.parse(emailUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        throw 'Could not send email';
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send email: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Open maps with coordinates
  static Future<void> openMaps(double latitude, double longitude, BuildContext context) async {
    try {
      final mapsUrl = 'https://maps.google.com/maps?q=$latitude,$longitude';
      final uri = Uri.parse(mapsUrl);
      
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not open maps';
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to open maps: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Connect to WiFi (Android only - shows system WiFi settings)
  static Future<void> connectToWifi(Map<String, dynamic> wifiData, BuildContext context) async {
    try {
      // On mobile platforms, we can only open WiFi settings
      // The user will need to manually connect using the provided credentials
      const uri = 'android.settings.WIFI_SETTINGS';
      
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('WiFi Connection'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('WiFi credentials detected:'),
                  const SizedBox(height: 8),
                  Text('Network: ${wifiData['ssid'] ?? 'Unknown'}'),
                  if (wifiData['password'] != null)
                    Text('Password: ${wifiData['password']}'),
                  if (wifiData['security'] != null)
                    Text('Security: ${wifiData['security']}'),
                  const SizedBox(height: 16),
                  const Text('Please connect manually using your device\'s WiFi settings.'),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Close'),
                ),
                TextButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    // Try to open WiFi settings
                    try {
                      await launchUrl(Uri.parse('app-settings:'));
                    } catch (e) {
                      // Fallback - just show a message
                    }
                  },
                  child: const Text('Open Settings'),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('WiFi connection not supported: $e'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  /// Save contact (vCard)
  static Future<void> saveContact(Map<String, dynamic> contactData, BuildContext context) async {
    try {
      // For now, show contact details and allow copying
      // In a full implementation, you would integrate with device contacts
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Contact Information'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (contactData['fullName'] != null)
                      Text('Name: ${contactData['fullName']}'),
                    if (contactData['organization'] != null)
                      Text('Organization: ${contactData['organization']}'),
                    if (contactData['title'] != null)
                      Text('Title: ${contactData['title']}'),
                    if (contactData['phones'] != null) ...[
                      const SizedBox(height: 8),
                      const Text('Phone Numbers:', style: TextStyle(fontWeight: FontWeight.bold)),
                      for (final phone in contactData['phones'])
                        Text('${phone['type']}: ${phone['number']}'),
                    ],
                    if (contactData['emails'] != null) ...[
                      const SizedBox(height: 8),
                      const Text('Email Addresses:', style: TextStyle(fontWeight: FontWeight.bold)),
                      for (final email in contactData['emails'])
                        Text('${email['type']}: ${email['email']}'),
                    ],
                    if (contactData['website'] != null)
                      Text('Website: ${contactData['website']}'),
                    if (contactData['note'] != null)
                      Text('Note: ${contactData['note']}'),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Close'),
                ),
                TextButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    // Copy contact info as text
                    final contactText = _formatContactAsText(contactData);
                    await copyToClipboard(contactText, context);
                  },
                  child: const Text('Copy Info'),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to process contact: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Format contact data as text
  static String _formatContactAsText(Map<String, dynamic> contactData) {
    final buffer = StringBuffer();
    
    if (contactData['fullName'] != null) {
      buffer.writeln('Name: ${contactData['fullName']}');
    }
    if (contactData['organization'] != null) {
      buffer.writeln('Organization: ${contactData['organization']}');
    }
    if (contactData['title'] != null) {
      buffer.writeln('Title: ${contactData['title']}');
    }
    
    if (contactData['phones'] != null) {
      buffer.writeln('\nPhone Numbers:');
      for (final phone in contactData['phones']) {
        buffer.writeln('${phone['type']}: ${phone['number']}');
      }
    }
    
    if (contactData['emails'] != null) {
      buffer.writeln('\nEmail Addresses:');
      for (final email in contactData['emails']) {
        buffer.writeln('${email['type']}: ${email['email']}');
      }
    }
    
    if (contactData['website'] != null) {
      buffer.writeln('\nWebsite: ${contactData['website']}');
    }
    
    if (contactData['note'] != null) {
      buffer.writeln('\nNote: ${contactData['note']}');
    }
    
    return buffer.toString();
  }
}
