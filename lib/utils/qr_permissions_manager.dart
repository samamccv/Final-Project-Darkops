// lib/utils/qr_permissions_manager.dart
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'qr_feedback_manager.dart';

/// Manages permissions for QR scanning functionality
class QRPermissionsManager {
  /// Check if camera permission is granted
  static Future<bool> hasCameraPermission() async {
    final status = await Permission.camera.status;
    return status.isGranted;
  }

  /// Request camera permission
  static Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  /// Check and request camera permission with user feedback
  static Future<bool> ensureCameraPermission(BuildContext context) async {
    // Check current permission status
    final currentStatus = await Permission.camera.status;
    
    if (currentStatus.isGranted) {
      return true;
    }

    if (currentStatus.isDenied) {
      // Request permission
      final newStatus = await Permission.camera.request();
      
      if (newStatus.isGranted) {
        return true;
      } else if (newStatus.isPermanentlyDenied) {
        _showPermissionPermanentlyDeniedDialog(context);
        return false;
      } else {
        QRFeedbackManager.showPermissionDeniedFeedback(context);
        return false;
      }
    }

    if (currentStatus.isPermanentlyDenied) {
      _showPermissionPermanentlyDeniedDialog(context);
      return false;
    }

    return false;
  }

  /// Show dialog for permanently denied permissions
  static void _showPermissionPermanentlyDeniedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.camera_alt_outlined, color: Colors.orange),
              SizedBox(width: 8),
              Text('Camera Permission Required'),
            ],
          ),
          content: const Text(
            'Camera access is required to scan QR codes. Please enable camera permission in your device settings.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                openAppSettings();
              },
              child: const Text('Open Settings'),
            ),
          ],
        );
      },
    );
  }

  /// Check if storage permission is needed (for image upload)
  static Future<bool> hasStoragePermission() async {
    // On newer Android versions, we use photos permission
    final status = await Permission.photos.status;
    return status.isGranted;
  }

  /// Request storage/photos permission
  static Future<bool> requestStoragePermission() async {
    final status = await Permission.photos.request();
    return status.isGranted;
  }

  /// Ensure storage permission for image upload
  static Future<bool> ensureStoragePermission(BuildContext context) async {
    final currentStatus = await Permission.photos.status;
    
    if (currentStatus.isGranted) {
      return true;
    }

    if (currentStatus.isDenied) {
      final newStatus = await Permission.photos.request();
      
      if (newStatus.isGranted) {
        return true;
      } else if (newStatus.isPermanentlyDenied) {
        _showStoragePermissionDeniedDialog(context);
        return false;
      } else {
        _showStoragePermissionDeniedSnackBar(context);
        return false;
      }
    }

    if (currentStatus.isPermanentlyDenied) {
      _showStoragePermissionDeniedDialog(context);
      return false;
    }

    return false;
  }

  /// Show dialog for storage permission
  static void _showStoragePermissionDeniedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.photo_library_outlined, color: Colors.orange),
              SizedBox(width: 8),
              Text('Photos Permission Required'),
            ],
          ),
          content: const Text(
            'Photos access is required to upload images for QR code scanning. Please enable photos permission in your device settings.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                openAppSettings();
              },
              child: const Text('Open Settings'),
            ),
          ],
        );
      },
    );
  }

  /// Show snackbar for storage permission
  static void _showStoragePermissionDeniedSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.photo_library_outlined, color: Colors.white),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Photos permission required to upload images',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        action: SnackBarAction(
          label: 'Settings',
          textColor: Colors.white,
          onPressed: () => openAppSettings(),
        ),
      ),
    );
  }

  /// Check all required permissions for QR scanning
  static Future<Map<String, bool>> checkAllPermissions() async {
    final cameraPermission = await hasCameraPermission();
    final storagePermission = await hasStoragePermission();

    return {
      'camera': cameraPermission,
      'storage': storagePermission,
    };
  }

  /// Request all required permissions
  static Future<Map<String, bool>> requestAllPermissions() async {
    final cameraPermission = await requestCameraPermission();
    final storagePermission = await requestStoragePermission();

    return {
      'camera': cameraPermission,
      'storage': storagePermission,
    };
  }

  /// Show permission explanation dialog
  static void showPermissionExplanationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.security, color: Colors.blue),
              SizedBox(width: 8),
              Text('Permissions Required'),
            ],
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'This app requires the following permissions to function properly:',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Icon(Icons.camera_alt, size: 20, color: Colors.blue),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Camera: To scan QR codes using your device camera',
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.photo_library, size: 20, color: Colors.blue),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Photos: To upload images containing QR codes',
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Text(
                'Your privacy is important to us. These permissions are only used for QR code scanning functionality.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await requestAllPermissions();
              },
              child: const Text('Grant Permissions'),
            ),
          ],
        );
      },
    );
  }
}
