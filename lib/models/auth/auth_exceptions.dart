// lib/models/auth/auth_exceptions.dart

/// Base class for authentication-related exceptions
abstract class AuthException implements Exception {
  final String message;
  final String userFriendlyMessage;
  
  const AuthException(this.message, this.userFriendlyMessage);
  
  @override
  String toString() => message;
}

/// Exception thrown when user credentials are invalid
class InvalidCredentialsException extends AuthException {
  const InvalidCredentialsException()
      : super(
          'Invalid credentials provided',
          'Incorrect email or password. Please check your credentials and try again.',
        );
}

/// Exception thrown when user account is not found
class UserNotFoundException extends AuthException {
  const UserNotFoundException()
      : super(
          'User not found',
          'No account found with this email address. Please check your email or sign up.',
        );
}

/// Exception thrown when user account is locked or suspended
class AccountLockedException extends AuthException {
  const AccountLockedException()
      : super(
          'Account locked',
          'Your account has been temporarily locked. Please contact support.',
        );
}

/// Exception thrown when email is not verified
class EmailNotVerifiedException extends AuthException {
  const EmailNotVerifiedException()
      : super(
          'Email not verified',
          'Please verify your email address before signing in.',
        );
}

/// Exception thrown when there are network connectivity issues
class NetworkException extends AuthException {
  const NetworkException()
      : super(
          'Network error',
          'Unable to connect to the server. Please check your internet connection and try again.',
        );
}

/// Exception thrown when the server is temporarily unavailable
class ServerException extends AuthException {
  const ServerException()
      : super(
          'Server error',
          'Our servers are temporarily unavailable. Please try again in a few moments.',
        );
}

/// Exception thrown when request times out
class TimeoutException extends AuthException {
  const TimeoutException()
      : super(
          'Request timeout',
          'The request took too long to complete. Please check your connection and try again.',
        );
}

/// Exception thrown for validation errors
class ValidationException extends AuthException {
  final Map<String, String> fieldErrors;
  
  const ValidationException(this.fieldErrors)
      : super(
          'Validation failed',
          'Please correct the errors and try again.',
        );
}

/// Exception thrown for unknown/unexpected errors
class UnknownAuthException extends AuthException {
  const UnknownAuthException([String? customMessage])
      : super(
          customMessage ?? 'Unknown error occurred',
          'Something went wrong. Please try again or contact support if the problem persists.',
        );
}

/// Utility class to map generic exceptions to specific auth exceptions
class AuthExceptionMapper {
  static AuthException mapException(dynamic error) {
    if (error is AuthException) {
      return error;
    }
    
    if (error is Exception) {
      final errorMessage = error.toString().toLowerCase();
      
      // Map common error patterns to specific exceptions
      if (errorMessage.contains('invalid credentials') ||
          errorMessage.contains('authentication failed') ||
          errorMessage.contains('wrong password') ||
          errorMessage.contains('incorrect password')) {
        return const InvalidCredentialsException();
      }
      
      if (errorMessage.contains('user not found') ||
          errorMessage.contains('account not found')) {
        return const UserNotFoundException();
      }
      
      if (errorMessage.contains('account locked') ||
          errorMessage.contains('account suspended') ||
          errorMessage.contains('account disabled')) {
        return const AccountLockedException();
      }
      
      if (errorMessage.contains('email not verified') ||
          errorMessage.contains('verify your email')) {
        return const EmailNotVerifiedException();
      }
      
      if (errorMessage.contains('connection') ||
          errorMessage.contains('network') ||
          errorMessage.contains('internet')) {
        return const NetworkException();
      }
      
      if (errorMessage.contains('timeout') ||
          errorMessage.contains('timed out')) {
        return const TimeoutException();
      }
      
      if (errorMessage.contains('server error') ||
          errorMessage.contains('internal server') ||
          errorMessage.contains('service unavailable')) {
        return const ServerException();
      }
      
      return UnknownAuthException(error.toString());
    }
    
    return UnknownAuthException(error.toString());
  }
}
