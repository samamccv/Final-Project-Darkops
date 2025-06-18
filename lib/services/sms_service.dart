// lib/services/sms_service.dart
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

/// Model representing an SMS message from the device
class DeviceSMSMessage {
  final String id;
  final String address;
  final String body;
  final DateTime date;
  final bool isRead;
  final String type; // 'inbox', 'sent', 'draft', 'outbox'

  const DeviceSMSMessage({
    required this.id,
    required this.address,
    required this.body,
    required this.date,
    required this.isRead,
    required this.type,
  });

  /// Create a DeviceSMSMessage from raw data (for mock implementation)
  factory DeviceSMSMessage.fromMap(Map<String, dynamic> data) {
    return DeviceSMSMessage(
      id: data['id']?.toString() ?? '0',
      address: data['address'] ?? 'Unknown',
      body: data['body'] ?? '',
      date:
          data['date'] is DateTime
              ? data['date']
              : DateTime.tryParse(data['date']?.toString() ?? '') ??
                  DateTime.now(),
      isRead: data['isRead'] == true || data['read'] == 1,
      type: data['type'] ?? 'inbox',
    );
  }

  /// Get a preview of the message body (first 100 characters)
  String get bodyPreview {
    if (body.length <= 100) return body;
    return '${body.substring(0, 100)}...';
  }

  /// Get formatted date string
  String get formattedDate {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      // Today - show time
      return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      // Yesterday
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      // This week - show day name
      const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return days[date.weekday - 1];
    } else {
      // Older - show date
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  /// Check if this message is likely to be suspicious based on basic heuristics
  bool get isPotentiallySuspicious {
    final suspiciousKeywords = [
      'click here',
      'urgent',
      'verify',
      'suspended',
      'account',
      'bank',
      'credit card',
      'winner',
      'congratulations',
      'prize',
      'free',
      'limited time',
      'act now',
      'confirm',
      'update',
    ];

    final lowerBody = body.toLowerCase();
    return suspiciousKeywords.any((keyword) => lowerBody.contains(keyword)) ||
        body.contains(RegExp(r'https?://[^\s]+')) || // Contains URLs
        body.contains(
          RegExp(r'\b\d{4}\s*\d{4}\s*\d{4}\s*\d{4}\b'),
        ); // Contains card-like numbers
  }
}

/// Service for handling SMS operations on the device
class SMSService {
  static final SMSService _instance = SMSService._internal();
  factory SMSService() => _instance;
  SMSService._internal();

  /// Check if SMS permission is granted
  Future<bool> hasPermission() async {
    final status = await Permission.sms.status;
    return status.isGranted;
  }

  /// Request SMS permission from the user
  Future<PermissionStatus> requestPermission() async {
    return await Permission.sms.request();
  }

  /// Get SMS permission status with detailed information
  Future<SMSPermissionResult> getPermissionStatus() async {
    final status = await Permission.sms.status;

    return SMSPermissionResult(
      status: status,
      isGranted: status.isGranted,
      isDenied: status.isDenied,
      isPermanentlyDenied: status.isPermanentlyDenied,
      isRestricted: status.isRestricted,
    );
  }

  /// Read SMS messages from the device (Mock implementation)
  /// In a real implementation, this would use a proper SMS package
  Future<List<DeviceSMSMessage>> readSMSMessages({
    int limit = 50,
    String type = 'inbox',
    bool sortByDate = true,
  }) async {
    try {
      // Check permission first
      if (!await hasPermission()) {
        throw SMSServiceException('SMS permission not granted');
      }

      // Mock SMS data for demonstration
      final mockMessages = _generateMockSMSMessages(limit, type);

      if (sortByDate) {
        mockMessages.sort((a, b) => b.date.compareTo(a.date));
      }

      return mockMessages;
    } catch (e) {
      throw SMSServiceException('Failed to read SMS messages: $e');
    }
  }

  /// Generate mock SMS messages for demonstration
  List<DeviceSMSMessage> _generateMockSMSMessages(int limit, String type) {
    final List<Map<String, dynamic>> mockData = [
      {
        'id': '1',
        'address': '+1234567890',
        'body':
            'Your account has been suspended. Click here to verify: http://suspicious-link.com',
        'date': DateTime.now().subtract(const Duration(hours: 2)),
        'isRead': false,
        'type': 'inbox',
      },
      {
        'id': '2',
        'address': 'BANK',
        'body':
            'URGENT: Your credit card ending in 1234 has been blocked. Call 555-SCAM immediately.',
        'date': DateTime.now().subtract(const Duration(hours: 5)),
        'isRead': true,
        'type': 'inbox',
      },
      {
        'id': '3',
        'address': '+9876543210',
        'body':
            'Congratulations! You have won \$1,000,000! Claim your prize now by clicking this link.',
        'date': DateTime.now().subtract(const Duration(days: 1)),
        'isRead': false,
        'type': 'inbox',
      },
      {
        'id': '4',
        'address': 'DELIVERY',
        'body':
            'Your package delivery failed. Update your address here: http://fake-delivery.com',
        'date': DateTime.now().subtract(const Duration(days: 2)),
        'isRead': true,
        'type': 'inbox',
      },
      {
        'id': '5',
        'address': '+1122334455',
        'body': 'Hi! How are you doing today? Hope you\'re having a great day!',
        'date': DateTime.now().subtract(const Duration(days: 3)),
        'isRead': true,
        'type': 'inbox',
      },
      {
        'id': '6',
        'address': '+5566778899',
        'body':
            'Meeting tomorrow at 3 PM. Don\'t forget to bring the documents.',
        'date': DateTime.now().subtract(const Duration(days: 4)),
        'isRead': true,
        'type': 'sent',
      },
      {
        'id': '7',
        'address': 'PROMO',
        'body':
            'Limited time offer! Get 50% off on all items. Use code SAVE50 at checkout.',
        'date': DateTime.now().subtract(const Duration(days: 5)),
        'isRead': false,
        'type': 'inbox',
      },
    ];

    // Filter by type if specified
    List<Map<String, dynamic>> filteredData = mockData;
    if (type != 'all') {
      filteredData = mockData.where((msg) => msg['type'] == type).toList();
    }

    // Convert to DeviceSMSMessage objects
    return filteredData
        .take(limit)
        .map((data) => DeviceSMSMessage.fromMap(data))
        .toList();
  }

  /// Read all SMS messages (inbox, sent, drafts)
  Future<List<DeviceSMSMessage>> readAllSMSMessages({int limit = 100}) async {
    try {
      if (!await hasPermission()) {
        throw SMSServiceException('SMS permission not granted');
      }

      final List<DeviceSMSMessage> allMessages = [];

      // Read from different message types
      for (final type in ['inbox', 'sent']) {
        try {
          final messages = await readSMSMessages(
            limit: limit ~/ 2, // Split limit between received and sent
            type: type,
            sortByDate: false,
          );
          allMessages.addAll(messages);
        } catch (e) {
          // Continue if one type fails
          // Using debugPrint instead of print for production code
          debugPrint('Failed to read $type messages: $e');
        }
      }

      // Sort all messages by date
      allMessages.sort((a, b) => b.date.compareTo(a.date));

      // Return only the requested limit
      return allMessages.take(limit).toList();
    } catch (e) {
      throw SMSServiceException('Failed to read all SMS messages: $e');
    }
  }

  /// Search SMS messages by content
  Future<List<DeviceSMSMessage>> searchSMSMessages(
    String query, {
    int limit = 50,
  }) async {
    try {
      final allMessages = await readAllSMSMessages(limit: limit * 2);

      final searchQuery = query.toLowerCase();
      return allMessages
          .where(
            (message) =>
                message.body.toLowerCase().contains(searchQuery) ||
                message.address.toLowerCase().contains(searchQuery),
          )
          .take(limit)
          .toList();
    } catch (e) {
      throw SMSServiceException('Failed to search SMS messages: $e');
    }
  }

  /// Get potentially suspicious SMS messages
  Future<List<DeviceSMSMessage>> getSuspiciousSMSMessages({
    int limit = 50,
  }) async {
    try {
      final allMessages = await readAllSMSMessages(limit: limit * 2);

      return allMessages
          .where((message) => message.isPotentiallySuspicious)
          .take(limit)
          .toList();
    } catch (e) {
      throw SMSServiceException('Failed to get suspicious SMS messages: $e');
    }
  }
}

/// Result of SMS permission check
class SMSPermissionResult {
  final PermissionStatus status;
  final bool isGranted;
  final bool isDenied;
  final bool isPermanentlyDenied;
  final bool isRestricted;

  const SMSPermissionResult({
    required this.status,
    required this.isGranted,
    required this.isDenied,
    required this.isPermanentlyDenied,
    required this.isRestricted,
  });

  /// Get user-friendly message for the permission status
  String get userMessage {
    if (isGranted) {
      return 'SMS access granted';
    } else if (isPermanentlyDenied) {
      return 'SMS access permanently denied. Please enable in device settings.';
    } else if (isDenied) {
      return 'SMS access denied. Please grant permission to read messages.';
    } else if (isRestricted) {
      return 'SMS access restricted by device policy.';
    } else {
      return 'SMS permission status unknown.';
    }
  }

  /// Whether we should show settings button
  bool get shouldShowSettings => isPermanentlyDenied;
}

/// Custom exception for SMS service errors
class SMSServiceException implements Exception {
  final String message;
  const SMSServiceException(this.message);

  @override
  String toString() => 'SMSServiceException: $message';
}
