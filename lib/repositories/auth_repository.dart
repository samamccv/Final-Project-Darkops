import 'package:google_sign_in/google_sign_in.dart';
import '../models/auth/auth_models.dart';
import '../models/auth/user.dart';
import '../models/auth/auth_exceptions.dart';
import '../services/api_seevice.dart';

class AuthRepository {
  final ApiService _apiService;
  final GoogleSignIn _googleSignIn;

  AuthRepository({required ApiService apiService, GoogleSignIn? googleSignIn})
    : _apiService = apiService,
      _googleSignIn =
          googleSignIn ??
          GoogleSignIn(
            scopes: [
              'email',
              'profile',
              'https://www.googleapis.com/auth/gmail.readonly',
            ],
          );

  // Authentication methods
  Future<AuthResponse> login({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    try {
      final request = LoginRequest(
        email: email,
        password: password,
        rememberMe: rememberMe,
      );
      return await _apiService.login(request);
    } catch (e) {
      throw _mapException(e);
    }
  }

  Future<AuthResponse> register({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final request = SignupRequest(
        email: email,
        password: password,
        name: name,
      );
      return await _apiService.register(request);
    } catch (e) {
      throw _mapException(e);
    }
  }

  Future<MessageResponse> forgotPassword({required String email}) async {
    try {
      final request = ForgotPasswordRequest(email: email);
      return await _apiService.forgotPassword(request);
    } catch (e) {
      throw _mapException(e);
    }
  }

  Future<MessageResponse> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    try {
      final request = ResetPasswordRequest(
        email: email,
        otp: otp,
        newPassword: newPassword,
      );
      return await _apiService.resetPassword(request);
    } catch (e) {
      throw _mapException(e);
    }
  }

  Future<MessageResponse> verifyEmail({
    required String email,
    required String otp,
  }) async {
    try {
      final request = VerifyEmailRequest(email: email, otp: otp);
      return await _apiService.verifyEmail(request);
    } catch (e) {
      throw _mapException(e);
    }
  }

  Future<MessageResponse> resendVerification({required String email}) async {
    try {
      final request = ResendVerificationRequest(email: email);
      return await _apiService.resendVerification(request);
    } catch (e) {
      throw _mapException(e);
    }
  }

  Future<AuthResponse> getCurrentUser() async {
    try {
      return await _apiService.getCurrentUser();
    } catch (e) {
      throw _mapException(e);
    }
  }

  Future<MessageResponse> logout() async {
    try {
      // Sign out from Google if signed in
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.signOut();
      }
      return await _apiService.logout();
    } catch (e) {
      throw _mapException(e);
    }
  }

  // Google OAuth methods
  Future<AuthResponse> signInWithGoogle() async {
    try {
      // Trigger Google Sign-In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        throw Exception('Google sign-in was cancelled');
      }

      // Get authentication details
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      if (googleAuth.accessToken == null) {
        throw Exception('Failed to get Google access token');
      }

      // Send the authorization code to backend
      // Note: In a real implementation, you might need to handle this differently
      // depending on your backend's Google OAuth implementation
      final authResponse = await _apiService.handleGoogleCallback(
        googleAuth.accessToken!,
      );

      return authResponse;
    } catch (e) {
      // Sign out on error to clean up state
      await _googleSignIn.signOut();
      throw _mapException(e);
    }
  }

  Future<bool> isGoogleSignedIn() async {
    return await _googleSignIn.isSignedIn();
  }

  Future<void> signOutFromGoogle() async {
    await _googleSignIn.signOut();
  }

  // Token management
  Future<String?> getStoredToken() async {
    return await _apiService.getToken();
  }

  Future<void> clearStoredToken() async {
    await _apiService.clearToken();
  }

  Future<bool> isLoggedIn() async {
    final token = await getStoredToken();
    return token != null;
  }

  // Auto-login check
  Future<User?> checkAuthStatus() async {
    try {
      final token = await getStoredToken();
      if (token == null) return null;

      final response = await getCurrentUser();
      return response.user;
    } catch (e) {
      // Clear invalid token
      await clearStoredToken();
      return null;
    }
  }

  // Error mapping
  AuthException _mapException(dynamic error) {
    return AuthExceptionMapper.mapException(error);
  }
}
