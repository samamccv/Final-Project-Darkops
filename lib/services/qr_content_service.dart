// lib/services/qr_content_service.dart
import 'package:equatable/equatable.dart';

/// Enum for different QR content types
enum QRContentType { url, wifi, email, phone, sms, vcard, geo, text, unknown }

/// Parsed QR content data
class QRContentData extends Equatable {
  final QRContentType type;
  final String rawContent;
  final Map<String, dynamic> parsedData;

  const QRContentData({
    required this.type,
    required this.rawContent,
    required this.parsedData,
  });

  @override
  List<Object?> get props => [type, rawContent, parsedData];
}

/// Service for detecting and parsing QR code content types
class QRContentService {
  /// Detects the content type of a QR code string
  static QRContentType detectContentType(String content) {
    if (content.isEmpty) return QRContentType.unknown;

    final lowerContent = content.toLowerCase();

    // URL detection
    if (lowerContent.startsWith('http://') ||
        lowerContent.startsWith('https://') ||
        lowerContent.startsWith('ftp://') ||
        lowerContent.startsWith('www.')) {
      return QRContentType.url;
    }

    // WiFi detection
    if (lowerContent.startsWith('wifi:')) {
      return QRContentType.wifi;
    }

    // Email detection
    if (lowerContent.startsWith('mailto:') ||
        lowerContent.startsWith('matmsg:')) {
      return QRContentType.email;
    }

    // Phone detection
    if (lowerContent.startsWith('tel:')) {
      return QRContentType.phone;
    }

    // SMS detection
    if (lowerContent.startsWith('sms:') || lowerContent.startsWith('smsto:')) {
      return QRContentType.sms;
    }

    // vCard detection
    if (lowerContent.startsWith('begin:vcard') ||
        lowerContent.startsWith('vcard:')) {
      return QRContentType.vcard;
    }

    // Geo coordinates detection
    if (lowerContent.startsWith('geo:') ||
        lowerContent.startsWith('google.com/maps') ||
        lowerContent.startsWith('maps.google.com') ||
        _isCoordinatePattern(content)) {
      return QRContentType.geo;
    }

    // Default to text
    return QRContentType.text;
  }

  /// Checks if content matches coordinate pattern (lat,lng)
  static bool _isCoordinatePattern(String content) {
    final coordPattern = RegExp(r'^-?\d+\.?\d*,-?\d+\.?\d*$');
    return coordPattern.hasMatch(content.trim());
  }

  /// Parses QR content based on its type
  static QRContentData parseContent(String content) {
    final type = detectContentType(content);
    Map<String, dynamic> parsedData = {};

    switch (type) {
      case QRContentType.url:
        parsedData = _parseUrl(content);
        break;
      case QRContentType.wifi:
        parsedData = _parseWifi(content);
        break;
      case QRContentType.email:
        parsedData = _parseEmail(content);
        break;
      case QRContentType.phone:
        parsedData = _parsePhone(content);
        break;
      case QRContentType.sms:
        parsedData = _parseSms(content);
        break;
      case QRContentType.vcard:
        parsedData = _parseVCard(content);
        break;
      case QRContentType.geo:
        parsedData = _parseGeo(content);
        break;
      case QRContentType.text:
        parsedData = _parseText(content);
        break;
      case QRContentType.unknown:
        parsedData = {'content': content};
        break;
    }

    return QRContentData(
      type: type,
      rawContent: content,
      parsedData: parsedData,
    );
  }

  /// Parse URL content
  static Map<String, dynamic> _parseUrl(String content) {
    String url = content;

    // Add protocol if missing
    if (!url.toLowerCase().startsWith('http://') &&
        !url.toLowerCase().startsWith('https://') &&
        !url.toLowerCase().startsWith('ftp://')) {
      url = 'https://$url';
    }

    try {
      final uri = Uri.parse(url);
      return {
        'url': url,
        'originalUrl': content,
        'domain': uri.host,
        'scheme': uri.scheme,
        'path': uri.path,
        'query': uri.query,
        'fragment': uri.fragment,
      };
    } catch (e) {
      return {
        'url': content,
        'originalUrl': content,
        'error': 'Invalid URL format',
      };
    }
  }

  /// Parse WiFi content (WIFI:T:WPA;S:MyNetwork;P:MyPassword;H:false;;)
  static Map<String, dynamic> _parseWifi(String content) {
    final wifiData = <String, dynamic>{};

    // Remove WIFI: prefix
    String wifiString = content.substring(5);

    // Split by semicolon and parse key-value pairs
    final parts = wifiString.split(';');

    for (final part in parts) {
      if (part.isEmpty) continue;

      final colonIndex = part.indexOf(':');
      if (colonIndex == -1) continue;

      final key = part.substring(0, colonIndex);
      final value = part.substring(colonIndex + 1);

      switch (key.toUpperCase()) {
        case 'T':
          wifiData['security'] = value; // WPA, WEP, nopass
          break;
        case 'S':
          wifiData['ssid'] = value;
          break;
        case 'P':
          wifiData['password'] = value;
          break;
        case 'H':
          wifiData['hidden'] = value.toLowerCase() == 'true';
          break;
      }
    }

    return wifiData;
  }

  /// Parse email content (mailto: or MATMSG:)
  static Map<String, dynamic> _parseEmail(String content) {
    if (content.toLowerCase().startsWith('matmsg:')) {
      return _parseMatmsgEmail(content);
    } else {
      return _parseMailtoEmail(content);
    }
  }

  /// Parse MATMSG email format
  static Map<String, dynamic> _parseMatmsgEmail(String content) {
    final emailData = <String, dynamic>{};

    // Remove MATMSG: prefix
    String matmsgString = content.substring(7);

    // Split by semicolon and parse key-value pairs
    final parts = matmsgString.split(';');

    for (final part in parts) {
      if (part.isEmpty) continue;

      final colonIndex = part.indexOf(':');
      if (colonIndex == -1) continue;

      final key = part.substring(0, colonIndex);
      final value = part.substring(colonIndex + 1);

      switch (key.toUpperCase()) {
        case 'TO':
          emailData['email'] = value;
          break;
        case 'SUB':
          emailData['subject'] = value;
          break;
        case 'BODY':
          emailData['body'] = value;
          break;
      }
    }

    return emailData;
  }

  /// Parse mailto email format
  static Map<String, dynamic> _parseMailtoEmail(String content) {
    final emailData = <String, dynamic>{};

    // Remove mailto: prefix
    String mailtoString = content.substring(7);

    // Check if there are query parameters
    final questionIndex = mailtoString.indexOf('?');
    if (questionIndex != -1) {
      emailData['email'] = mailtoString.substring(0, questionIndex);

      // Parse query parameters
      final queryString = mailtoString.substring(questionIndex + 1);
      final queryParams = Uri.splitQueryString(queryString);

      if (queryParams.containsKey('subject')) {
        emailData['subject'] = queryParams['subject'];
      }
      if (queryParams.containsKey('body')) {
        emailData['body'] = queryParams['body'];
      }
      if (queryParams.containsKey('cc')) {
        emailData['cc'] = queryParams['cc'];
      }
      if (queryParams.containsKey('bcc')) {
        emailData['bcc'] = queryParams['bcc'];
      }
    } else {
      emailData['email'] = mailtoString;
    }

    return emailData;
  }

  /// Parse phone content
  static Map<String, dynamic> _parsePhone(String content) {
    final phone = content.substring(4); // Remove 'tel:' prefix
    return {'phone': phone, 'displayPhone': _formatPhoneNumber(phone)};
  }

  /// Format phone number for display
  static String _formatPhoneNumber(String phone) {
    // Remove non-digit characters except + at the beginning
    String cleaned = phone.replaceAll(RegExp(r'[^\d+]'), '');

    // Basic formatting - can be enhanced based on requirements
    if (cleaned.length == 10) {
      return '(${cleaned.substring(0, 3)}) ${cleaned.substring(3, 6)}-${cleaned.substring(6)}';
    } else if (cleaned.length == 11 && cleaned.startsWith('1')) {
      return '+1 (${cleaned.substring(1, 4)}) ${cleaned.substring(4, 7)}-${cleaned.substring(7)}';
    }

    return phone; // Return original if no formatting applied
  }

  /// Parse SMS content (sms: or smsto:)
  static Map<String, dynamic> _parseSms(String content) {
    final smsData = <String, dynamic>{};

    if (content.toLowerCase().startsWith('smsto:')) {
      // SMSTO:number:message format
      String smsString = content.substring(6);
      final parts = smsString.split(':');

      if (parts.isNotEmpty) {
        smsData['number'] = parts[0];
        if (parts.length > 1) {
          smsData['body'] = parts.sublist(1).join(':');
        }
      }
    } else {
      // sms:number?body=message format
      String smsString = content.substring(4);
      final questionIndex = smsString.indexOf('?');

      if (questionIndex != -1) {
        smsData['number'] = smsString.substring(0, questionIndex);

        // Parse query parameters
        final queryString = smsString.substring(questionIndex + 1);
        final queryParams = Uri.splitQueryString(queryString);

        if (queryParams.containsKey('body')) {
          smsData['body'] = queryParams['body'];
        }
      } else {
        smsData['number'] = smsString;
      }
    }

    // Format phone number for display
    if (smsData.containsKey('number')) {
      smsData['displayNumber'] = _formatPhoneNumber(smsData['number']);
    }

    return smsData;
  }

  /// Parse vCard content
  static Map<String, dynamic> _parseVCard(String content) {
    final vcardData = <String, dynamic>{};
    final lines = content.split('\n');

    for (final line in lines) {
      final trimmedLine = line.trim();
      if (trimmedLine.isEmpty) continue;

      final colonIndex = trimmedLine.indexOf(':');
      if (colonIndex == -1) continue;

      final property = trimmedLine.substring(0, colonIndex).toUpperCase();
      final value = trimmedLine.substring(colonIndex + 1);

      switch (property) {
        case 'FN':
          vcardData['fullName'] = value;
          break;
        case 'N':
          final nameParts = value.split(';');
          vcardData['lastName'] = nameParts.isNotEmpty ? nameParts[0] : '';
          vcardData['firstName'] = nameParts.length > 1 ? nameParts[1] : '';
          vcardData['middleName'] = nameParts.length > 2 ? nameParts[2] : '';
          break;
        case 'ORG':
          vcardData['organization'] = value;
          break;
        case 'TITLE':
          vcardData['title'] = value;
          break;
        case 'TEL':
        case 'TEL;WORK':
        case 'TEL;HOME':
        case 'TEL;CELL':
          if (!vcardData.containsKey('phones')) {
            vcardData['phones'] = <Map<String, String>>[];
          }
          (vcardData['phones'] as List).add({
            'number': value,
            'type': _getPhoneType(property),
          });
          break;
        case 'EMAIL':
        case 'EMAIL;WORK':
        case 'EMAIL;HOME':
          if (!vcardData.containsKey('emails')) {
            vcardData['emails'] = <Map<String, String>>[];
          }
          (vcardData['emails'] as List).add({
            'email': value,
            'type': _getEmailType(property),
          });
          break;
        case 'URL':
          vcardData['website'] = value;
          break;
        case 'ADR':
        case 'ADR;WORK':
        case 'ADR;HOME':
          final addressParts = value.split(';');
          if (!vcardData.containsKey('addresses')) {
            vcardData['addresses'] = <Map<String, String>>[];
          }
          (vcardData['addresses'] as List).add({
            'street': addressParts.length > 2 ? addressParts[2] : '',
            'city': addressParts.length > 3 ? addressParts[3] : '',
            'state': addressParts.length > 4 ? addressParts[4] : '',
            'zip': addressParts.length > 5 ? addressParts[5] : '',
            'country': addressParts.length > 6 ? addressParts[6] : '',
            'type': _getAddressType(property),
          });
          break;
        case 'NOTE':
          vcardData['note'] = value;
          break;
      }
    }

    return vcardData;
  }

  /// Get phone type from vCard property
  static String _getPhoneType(String property) {
    if (property.contains('WORK')) return 'Work';
    if (property.contains('HOME')) return 'Home';
    if (property.contains('CELL')) return 'Mobile';
    return 'Other';
  }

  /// Get email type from vCard property
  static String _getEmailType(String property) {
    if (property.contains('WORK')) return 'Work';
    if (property.contains('HOME')) return 'Home';
    return 'Other';
  }

  /// Get address type from vCard property
  static String _getAddressType(String property) {
    if (property.contains('WORK')) return 'Work';
    if (property.contains('HOME')) return 'Home';
    return 'Other';
  }

  /// Parse geo coordinates
  static Map<String, dynamic> _parseGeo(String content) {
    final geoData = <String, dynamic>{};

    if (content.toLowerCase().startsWith('geo:')) {
      // geo:lat,lng or geo:lat,lng,alt format
      String geoString = content.substring(4);
      final parts = geoString.split(',');

      if (parts.length >= 2) {
        try {
          geoData['latitude'] = double.parse(parts[0]);
          geoData['longitude'] = double.parse(parts[1]);

          if (parts.length > 2) {
            geoData['altitude'] = double.parse(parts[2]);
          }
        } catch (e) {
          geoData['error'] = 'Invalid coordinate format';
        }
      }
    } else if (content.contains('google.com/maps') ||
        content.contains('maps.google.com')) {
      // Extract coordinates from Google Maps URL
      geoData.addAll(_parseGoogleMapsUrl(content));
    } else if (_isCoordinatePattern(content)) {
      // Simple lat,lng format
      final parts = content.split(',');
      try {
        geoData['latitude'] = double.parse(parts[0].trim());
        geoData['longitude'] = double.parse(parts[1].trim());
      } catch (e) {
        geoData['error'] = 'Invalid coordinate format';
      }
    }

    // Add formatted display string
    if (geoData.containsKey('latitude') && geoData.containsKey('longitude')) {
      geoData['displayCoordinates'] =
          '${geoData['latitude'].toStringAsFixed(6)}, ${geoData['longitude'].toStringAsFixed(6)}';
      geoData['mapsUrl'] =
          'https://maps.google.com/maps?q=${geoData['latitude']},${geoData['longitude']}';
    }

    return geoData;
  }

  /// Parse Google Maps URL to extract coordinates
  static Map<String, dynamic> _parseGoogleMapsUrl(String url) {
    final geoData = <String, dynamic>{};

    // Try to extract coordinates from various Google Maps URL formats
    final patterns = [
      RegExp(r'@(-?\d+\.?\d*),(-?\d+\.?\d*)'),
      RegExp(r'q=(-?\d+\.?\d*),(-?\d+\.?\d*)'),
      RegExp(r'll=(-?\d+\.?\d*),(-?\d+\.?\d*)'),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(url);
      if (match != null) {
        try {
          geoData['latitude'] = double.parse(match.group(1)!);
          geoData['longitude'] = double.parse(match.group(2)!);
          geoData['originalUrl'] = url;
          break;
        } catch (e) {
          // Continue to next pattern
        }
      }
    }

    return geoData;
  }

  /// Parse plain text content
  static Map<String, dynamic> _parseText(String content) {
    return {
      'content': content,
      'length': content.length,
      'wordCount': content.split(RegExp(r'\s+')).length,
    };
  }

  /// Get display name for content type
  static String getContentTypeDisplayName(QRContentType type) {
    switch (type) {
      case QRContentType.url:
        return 'Website URL';
      case QRContentType.wifi:
        return 'Wi-Fi Network';
      case QRContentType.email:
        return 'Email Address';
      case QRContentType.phone:
        return 'Phone Number';
      case QRContentType.sms:
        return 'SMS Message';
      case QRContentType.vcard:
        return 'Contact Card';
      case QRContentType.geo:
        return 'Location';
      case QRContentType.text:
        return 'Text Content';
      case QRContentType.unknown:
        return 'Unknown Content';
    }
  }

  /// Get icon name for content type
  static String getContentTypeIcon(QRContentType type) {
    switch (type) {
      case QRContentType.url:
        return 'language';
      case QRContentType.wifi:
        return 'wifi';
      case QRContentType.email:
        return 'email';
      case QRContentType.phone:
        return 'phone';
      case QRContentType.sms:
        return 'message';
      case QRContentType.vcard:
        return 'contact_page';
      case QRContentType.geo:
        return 'location_on';
      case QRContentType.text:
        return 'text_fields';
      case QRContentType.unknown:
        return 'help_outline';
    }
  }
}
