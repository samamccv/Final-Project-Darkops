import 'package:flutter/material.dart';
import '../screens/enhanced_login_page.dart';
import '../screens/enhanced_signup_page.dart';
import '../screens/email_verification_page.dart';
import '../screens/forgot_password_page.dart';
import '../screens/reset_password_page.dart';
import '../dashboard/homepage.dart';

class AuthNavigation {
  // Navigate to login page
  static void toLogin(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const EnhancedLoginPage()),
    );
  }

  // Navigate to signup page
  static void toSignup(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const EnhancedSignupPage()),
    );
  }

  // Navigate to email verification page
  static void toEmailVerification(BuildContext context, String email) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => EmailVerificationPage(email: email),
      ),
    );
  }

  // Navigate to forgot password page
  static void toForgotPassword(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ForgotPasswordPage()),
    );
  }

  // Navigate to reset password page
  static void toResetPassword(BuildContext context, String email) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ResetPasswordPage(email: email),
      ),
    );
  }

  // Navigate to home page (authenticated)
  static void toHome(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const HomePage()),
      (route) => false,
    );
  }

  // Navigate back to login and clear stack
  static void toLoginAndClearStack(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const EnhancedLoginPage()),
      (route) => false,
    );
  }

  // Show success message
  static void showSuccessMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // Show error message
  static void showErrorMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  // Show warning message
  static void showWarningMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.orange,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
