import 'package:google_sign_in/google_sign_in.dart';
import '../models/auth/user.dart';

class GoogleAuthService {
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'profile',
      'https://www.googleapis.com/auth/gmail.readonly',
    ],
  );

  // Sign in with Google
  static Future<GoogleSignInAccount?> signIn() async {
    try {
      final GoogleSignInAccount? account = await _googleSignIn.signIn();
      return account;
    } catch (error) {
      throw Exception('Google sign-in failed: $error');
    }
  }

  // Sign out from Google
  static Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (error) {
      throw Exception('Google sign-out failed: $error');
    }
  }

  // Check if user is signed in
  static Future<bool> isSignedIn() async {
    return await _googleSignIn.isSignedIn();
  }

  // Get current user
  static Future<GoogleSignInAccount?> getCurrentUser() async {
    return _googleSignIn.currentUser;
  }

  // Get authentication details
  static Future<GoogleSignInAuthentication?> getAuthentication() async {
    final GoogleSignInAccount? account = await getCurrentUser();
    if (account != null) {
      return await account.authentication;
    }
    return null;
  }

  // Convert Google user to our User model
  static User googleUserToUser(GoogleSignInAccount googleUser) {
    return User(
      id: googleUser.id,
      email: googleUser.email,
      name: googleUser.displayName,
      image: googleUser.photoUrl,
      emailVerified: true, // Google accounts are pre-verified
    );
  }

  // Silent sign-in (for auto-login)
  static Future<GoogleSignInAccount?> signInSilently() async {
    try {
      return await _googleSignIn.signInSilently();
    } catch (error) {
      return null;
    }
  }

  // Disconnect from Google (revoke access)
  static Future<void> disconnect() async {
    try {
      await _googleSignIn.disconnect();
    } catch (error) {
      throw Exception('Google disconnect failed: $error');
    }
  }
}
