import 'dart:io';

/// Application configuration for different environments
class AppConfig {
  static const String _prodBaseUrl = 'https://api.darkops.com';
  static const String _devBaseUrl =
      'http://10.0.2.2:9999'; // Android emulator host access
  static const String _webDevBaseUrl =
      'http://localhost:9999'; // Web development

  // Environment variables for flexible configuration
  static const String _envDeviceIp = String.fromEnvironment(
    'DEVICE_IP',
    defaultValue: '192.168.1.16',
  );
  static const String _envPort = String.fromEnvironment(
    'BACKEND_PORT',
    defaultValue: '9999',
  );
  static const bool _forceDeviceMode = bool.fromEnvironment(
    'FORCE_DEVICE_MODE',
    defaultValue: false,
  );
  static const bool _forceEmulatorMode = bool.fromEnvironment(
    'FORCE_EMULATOR_MODE',
    defaultValue: false,
  );

  /// Get the appropriate base URL based on the platform and environment
  static String get baseUrl {
    // In production, use the production URL
    if (const bool.fromEnvironment('dart.vm.product')) {
      return _prodBaseUrl;
    }

    // Check for environment variable overrides
    if (_forceDeviceMode) {
      return 'http://$_envDeviceIp:$_envPort';
    }
    if (_forceEmulatorMode) {
      return 'http://10.0.2.2:$_envPort';
    }

    // In development, use platform-specific URLs
    if (Platform.isAndroid) {
      // For physical devices, use the actual network IP
      return 'http://$_envDeviceIp:$_envPort';
      // Uncomment the line below and comment the line above for emulator testing
      // return _devBaseUrl; // Use this for emulators
    } else if (Platform.isIOS) {
      // For iOS physical devices, use the network IP
      // For iOS simulator, localhost works fine
      return _isIOSSimulator()
          ? _webDevBaseUrl
          : 'http://$_envDeviceIp:$_envPort';
    } else {
      // Web and other platforms use localhost
      return _webDevBaseUrl;
    }
  }

  /// Check if running on iOS simulator
  static bool _isIOSSimulator() {
    // This is a simple heuristic - iOS simulator typically has localhost access
    // You can also use platform channels for more accurate detection
    return Platform.isIOS &&
        Platform.environment.containsKey('SIMULATOR_DEVICE_NAME');
  }

  /// API endpoints
  static const String authSignIn = '/auth/signin';
  static const String authSignUp = '/auth/signup';
  static const String authMe = '/auth/me';
  static const String authLogout = '/auth/logout';
  static const String authGoogle = '/auth/google';
  static const String authGoogleCallback = '/auth/google/callback';
  static const String authForgotPassword = '/auth/forgot-password';
  static const String authResetPassword = '/auth/reset-password';
  static const String authVerifyEmail = '/auth/verify-email';
  static const String authResendVerification = '/auth/resend-verification';

  /// GraphQL endpoint
  static const String graphql = '/graphql';

  /// AI service endpoints
  static const String aiEmailAnalysis = '/ai/email/detect-phishing';
  static const String aiSmsAnalysis = '/ai/sms/detect-phishing';
  static const String aiUrlAnalysis = '/ai/url/scan-url';
  static const String aiQrAnalysis = '/ai/qr/analyze';
  static const String aiApkAnalysis = '/ai/apk/malware-detection';

  /// Timeout configurations
  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 10);
  static const Duration scanTimeout = Duration(seconds: 30);

  /// Debug settings
  static const bool enableLogging = true;
  static const bool useMockData = false;

  /// Security settings
  static const String tokenKey = 'auth_token';

  /// Network configuration
  static Map<String, String> get defaultHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  /// Get full URL for an endpoint
  static String getUrl(String endpoint) {
    return '$baseUrl$endpoint';
  }

  /// Check if running in debug mode
  static bool get isDebug => !const bool.fromEnvironment('dart.vm.product');

  /// Check if running on Android emulator
  static bool get isAndroidEmulator {
    return Platform.isAndroid && baseUrl.contains('10.0.2.2');
  }

  /// Check if running on physical device
  static bool get isPhysicalDevice {
    if (Platform.isAndroid) {
      return !isAndroidEmulator;
    } else if (Platform.isIOS) {
      return !_isIOSSimulator();
    }
    return false;
  }

  /// Get current device IP (for debugging)
  static String get currentDeviceIp => _envDeviceIp;

  /// Get current backend port (for debugging)
  static String get currentBackendPort => _envPort;

  /// Print configuration info for debugging
  static void printConfig() {
    if (isDebug) {
      print('🔧 DarkOps App Configuration:');
      print('   Platform: ${Platform.operatingSystem}');
      print('   Base URL: $baseUrl');
      print('   Device IP: $currentDeviceIp');
      print('   Backend Port: $currentBackendPort');
      print('   Is Android Emulator: $isAndroidEmulator');
      print('   Is Physical Device: $isPhysicalDevice');
      print('   Debug Mode: $isDebug');
      print('   Connect Timeout: ${connectTimeout.inSeconds}s');
      print('   Receive Timeout: ${receiveTimeout.inSeconds}s');
      print('   Force Device Mode: $_forceDeviceMode');
      print('   Force Emulator Mode: $_forceEmulatorMode');
    }
  }
}
