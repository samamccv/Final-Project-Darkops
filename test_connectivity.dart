import 'package:dio/dio.dart';
import 'lib/config/app_config.dart';

/// Test script to verify backend connectivity from Android emulator
void main() async {
  print('🔍 Testing DarkOps Backend Connectivity...\n');
  
  final dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.baseUrl,
      connectTimeout: AppConfig.connectTimeout,
      receiveTimeout: AppConfig.receiveTimeout,
      headers: AppConfig.defaultHeaders,
    ),
  );
  
  // Test 1: Basic connectivity
  print('📡 Test 1: Basic Backend Connectivity');
  try {
    final response = await dio.get('/');
    print('✅ Backend is reachable');
    print('   Status: ${response.statusCode}');
    print('   Response: ${response.data}');
  } catch (e) {
    print('❌ Backend connectivity failed: $e');
  }
  
  print('\n📡 Test 2: Auth Endpoint Availability');
  try {
    // Test with invalid credentials to check if endpoint exists
    final response = await dio.post('/auth/signin', data: {
      'email': 'test@example.com',
      'password': 'testpassword123' // Valid length password
    });
    print('✅ Auth endpoint is available');
    print('   Status: ${response.statusCode}');
  } catch (e) {
    if (e is DioException) {
      if (e.response?.statusCode == 401 || e.response?.statusCode == 422) {
        print('✅ Auth endpoint is available (expected auth failure)');
        print('   Status: ${e.response?.statusCode}');
        print('   Response: ${e.response?.data}');
      } else {
        print('❌ Auth endpoint error: ${e.response?.statusCode} - ${e.message}');
      }
    } else {
      print('❌ Auth endpoint error: $e');
    }
  }
  
  print('\n📡 Test 3: GraphQL Endpoint');
  try {
    final response = await dio.post('/graphql', data: {
      'query': 'query { __typename }'
    });
    print('✅ GraphQL endpoint is available');
    print('   Status: ${response.statusCode}');
  } catch (e) {
    if (e is DioException) {
      print('❌ GraphQL endpoint error: ${e.response?.statusCode} - ${e.message}');
      if (e.response?.data != null) {
        print('   Response: ${e.response?.data}');
      }
    } else {
      print('❌ GraphQL endpoint error: $e');
    }
  }
  
  print('\n🏁 Connectivity Test Complete');
  print('📋 Configuration Summary:');
  print('   Base URL: ${AppConfig.baseUrl}');
  print('   Platform: Android Emulator');
  print('   Timeout: ${AppConfig.connectTimeout.inSeconds}s');
}
