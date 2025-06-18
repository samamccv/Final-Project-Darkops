// lib/widgets/sms_permission_handler.dart
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/sms_service.dart';

/// Widget that handles SMS permission requests with user-friendly UI
class SMSPermissionHandler extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPermissionGranted;
  final VoidCallback? onPermissionDenied;
  final bool showPermissionDialog;

  const SMSPermissionHandler({
    super.key,
    required this.child,
    this.onPermissionGranted,
    this.onPermissionDenied,
    this.showPermissionDialog = true,
  });

  @override
  State<SMSPermissionHandler> createState() => _SMSPermissionHandlerState();
}

class _SMSPermissionHandlerState extends State<SMSPermissionHandler> {
  final SMSService _smsService = SMSService();
  bool _isCheckingPermission = false;

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  /// Check and request SMS permission if needed
  Future<bool> checkAndRequestPermission() async {
    if (_isCheckingPermission) return false;

    setState(() {
      _isCheckingPermission = true;
    });

    try {
      final permissionResult = await _smsService.getPermissionStatus();

      if (permissionResult.isGranted) {
        widget.onPermissionGranted?.call();
        return true;
      }

      if (widget.showPermissionDialog) {
        final shouldRequest = await _showPermissionDialog(permissionResult);
        if (!shouldRequest) {
          widget.onPermissionDenied?.call();
          return false;
        }
      }

      final status = await _smsService.requestPermission();
      final granted = status.isGranted;

      if (granted) {
        widget.onPermissionGranted?.call();
        if (mounted) {
          _showSuccessSnackBar();
        }
      } else {
        widget.onPermissionDenied?.call();
        if (mounted) {
          _showPermissionDeniedDialog(status);
        }
      }

      return granted;
    } finally {
      if (mounted) {
        setState(() {
          _isCheckingPermission = false;
        });
      }
    }
  }

  /// Show permission request dialog
  Future<bool> _showPermissionDialog(
    SMSPermissionResult permissionResult,
  ) async {
    if (!mounted) return false;

    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.sms_outlined,
                      color: Theme.of(context).primaryColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'SMS Access Required',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'To analyze SMS messages from your device, we need permission to read your SMS messages.',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.blue.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.security_outlined,
                              color: Colors.blue.shade700,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Privacy & Security',
                              style: TextStyle(
                                color: Colors.blue.shade700,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          '• Messages are only read when you select them\n'
                          '• No messages are stored on our servers\n'
                          '• Analysis happens securely and privately',
                          style: TextStyle(fontSize: 13, height: 1.4),
                        ),
                      ],
                    ),
                  ),
                  if (permissionResult.isPermanentlyDenied) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.orange.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.settings_outlined,
                                color: Colors.orange.shade700,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Settings Required',
                                style: TextStyle(
                                  color: Colors.orange.shade700,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Permission was previously denied. Please enable SMS access in your device settings.',
                            style: TextStyle(fontSize: 13, height: 1.4),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    permissionResult.isPermanentlyDenied
                        ? 'Open Settings'
                        : 'Grant Permission',
                  ),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  /// Show permission denied dialog
  Future<void> _showPermissionDeniedDialog(PermissionStatus status) async {
    if (!mounted) return;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        final isPermanentlyDenied = status.isPermanentlyDenied;

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.block_outlined,
                  color: Colors.red,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Permission Denied',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isPermanentlyDenied
                    ? 'SMS access has been permanently denied. To use this feature, please enable SMS permission in your device settings.'
                    : 'SMS access was denied. You can still analyze SMS messages by copying and pasting them manually.',
                style: const TextStyle(fontSize: 16),
              ),
              if (isPermanentlyDenied) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.blue.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.blue.shade700,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'How to Enable',
                            style: TextStyle(
                              color: Colors.blue.shade700,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '1. Go to device Settings\n'
                        '2. Find Apps or Application Manager\n'
                        '3. Select this app\n'
                        '4. Go to Permissions\n'
                        '5. Enable SMS permission',
                        style: TextStyle(fontSize: 13, height: 1.4),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          actions: [
            if (isPermanentlyDenied)
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  openAppSettings();
                },
                child: const Text('Open Settings'),
              ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  /// Show success snackbar
  void _showSuccessSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            const Text('SMS access granted successfully'),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}

/// Static helper methods for SMS permission handling
class SMSPermissionHelper {
  /// Quick permission check
  static Future<bool> hasPermission() async {
    return await SMSService().hasPermission();
  }

  /// Request permission with minimal UI
  static Future<bool> requestPermission() async {
    final status = await SMSService().requestPermission();
    return status.isGranted;
  }

  /// Show permission rationale dialog
  static Future<bool> showPermissionRationale(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('SMS Permission Required'),
                content: const Text(
                  'This app needs SMS permission to read and analyze your messages for security threats.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Grant Permission'),
                  ),
                ],
              ),
        ) ??
        false;
  }
}
