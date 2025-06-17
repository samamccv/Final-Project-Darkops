import 'dart:io';

/// Application configuration for different environments
class AppConfig {
  static const String _prodBaseUrl = 'https://api.darkops.com';
  static const String _devBaseUrl = 'http://10.0.2.2:9999'; // Android emulator host access
  static const String _webDevBaseUrl = 'http://localhost:9999'; // Web development
  
  /// Get the appropriate base URL based on the platform and environment
  static String get baseUrl {
    // In production, use the production URL
    if (const bool.fromEnvironment('dart.vm.product')) {
      return _prodBaseUrl;
    }
    
    // In development, use platform-specific URLs
    if (Platform.isAndroid) {
      // Android emulator uses 10.0.2.2 to access host machine
      return _devBaseUrl;
    } else if (Platform.isIOS) {
      // iOS simulator can use localhost
      return _webDevBaseUrl;
    } else {
      // Web and other platforms use localhost
      return _webDevBaseUrl;
    }
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
  
  /// Print configuration info for debugging
  static void printConfig() {
    if (isDebug) {
      print('🔧 DarkOps App Configuration:');
      print('   Platform: ${Platform.operatingSystem}');
      print('   Base URL: $baseUrl');
      print('   Is Android Emulator: $isAndroidEmulator');
      print('   Debug Mode: $isDebug');
      print('   Connect Timeout: ${connectTimeout.inSeconds}s');
      print('   Receive Timeout: ${receiveTimeout.inSeconds}s');
    }
  }
}
