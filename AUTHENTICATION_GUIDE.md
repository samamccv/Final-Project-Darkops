# DarkOps Flutter Authentication System

## Overview

This document describes the comprehensive authentication system implemented for the DarkOps Flutter mobile application. The system uses the BLoC pattern for state management, Dio for HTTP requests, and follows a repository pattern for clean architecture.

## Architecture

### Core Components

1. **AuthBloc** - Central state management for authentication
2. **AuthRepository** - Handles all authentication business logic
3. **ApiService** - HTTP client using Dio for API communication
4. **Models** - Data models for requests, responses, and user data
5. **Form BLoCs** - Separate BLoCs for form validation and management

### Key Features

- ✅ User Registration (Sign Up)
- ✅ User Login (Sign In) with Remember Me
- ✅ Email Verification with OTP
- ✅ Forgot Password Flow
- ✅ Reset Password with OTP
- ✅ Google OAuth Authentication
- ✅ Automatic token management and persistence
- ✅ Comprehensive error handling
- ✅ Form validation with real-time feedback
- ✅ Loading states and user feedback

## File Structure

```
lib/
├── blocs/auth/
│   ├── auth_bloc.dart          # Main authentication BLoC
│   ├── auth_event.dart         # Authentication events
│   ├── auth_state.dart         # Authentication states
│   ├── login_form_bloc.dart    # Login form validation BLoC
│   └── signup_form_bloc.dart   # Signup form validation BLoC
├── models/auth/
│   ├── user.dart              # User model
│   ├── auth_models.dart       # Request/response models
│   ├── email.dart             # Email validation model
│   └── password.dart          # Password validation model
├── repositories/
│   └── auth_repository.dart   # Authentication repository
├── services/
│   ├── api_service.dart       # HTTP client service
│   └── google_auth_service.dart # Google OAuth service
├── screens/
│   ├── enhanced_login_page.dart      # Modern login page
│   ├── enhanced_signup_page.dart     # Modern signup page
│   ├── email_verification_page.dart  # Email verification
│   ├── forgot_password_page.dart     # Forgot password
│   ├── reset_password_page.dart      # Reset password
│   ├── login_options.dart            # Initial login options
│   └── auth_demo_page.dart           # Demo/testing page
└── utils/
    └── auth_navigation.dart    # Navigation helpers
```

## Usage Examples

### 1. Login Flow

```dart
// Trigger login
context.read<AuthBloc>().add(
  AuthLoginRequested(
    email: 'user@example.com',
    password: 'password123',
    rememberMe: true,
  ),
);

// Listen to state changes
BlocListener<AuthBloc, AuthState>(
  listener: (context, state) {
    if (state.status == AuthStatus.authenticated) {
      // Navigate to home page
    } else if (state.status == AuthStatus.failure) {
      // Show error message
    }
  },
  child: YourWidget(),
)
```

### 2. Registration Flow

```dart
// Trigger registration
context.read<AuthBloc>().add(
  AuthRegisterRequested(
    email: 'user@example.com',
    password: 'password123',
    name: 'John Doe',
  ),
);

// After registration, user will need to verify email
if (state.status == AuthStatus.emailVerificationRequired) {
  // Navigate to email verification page
}
```

### 3. Google OAuth

```dart
// Trigger Google sign-in
context.read<AuthBloc>().add(AuthGoogleSignInRequested());
```

### 4. Password Reset Flow

```dart
// Step 1: Request password reset
context.read<AuthBloc>().add(
  AuthForgotPasswordRequested(email: 'user@example.com'),
);

// Step 2: Reset password with OTP
context.read<AuthBloc>().add(
  AuthResetPasswordRequested(
    email: 'user@example.com',
    otp: '123456',
    newPassword: 'newpassword123',
  ),
);
```

## Authentication States

- `AuthStatus.initial` - Initial state
- `AuthStatus.loading` - Processing request
- `AuthStatus.authenticated` - User is logged in
- `AuthStatus.unauthenticated` - User is not logged in
- `AuthStatus.emailVerificationRequired` - Email needs verification
- `AuthStatus.passwordResetRequired` - Password reset in progress
- `AuthStatus.failure` - Error occurred

## Backend API Integration

The system integrates with the following backend endpoints:

- `POST /auth/signup` - User registration
- `POST /auth/signin` - User login
- `POST /auth/verify-email` - Email verification
- `POST /auth/forgot-password` - Request password reset
- `POST /auth/reset-password` - Reset password
- `POST /auth/resend-verification` - Resend verification email
- `GET /auth/google` - Google OAuth initiation
- `GET /auth/google/callback` - Google OAuth callback
- `GET /auth/me` - Get current user
- `POST /auth/logout` - User logout

## Security Features

1. **Token Management**: Automatic token storage and refresh
2. **Secure Storage**: Uses flutter_secure_storage for token persistence
3. **Request Interceptors**: Automatic token attachment to requests
4. **Error Handling**: Comprehensive error handling and user feedback
5. **Form Validation**: Real-time form validation with proper error messages

## Testing

Use the `AuthDemoPage` to test all authentication features:

```dart
Navigator.push(
  context,
  MaterialPageRoute(builder: (_) => const AuthDemoPage()),
);
```

## Dependencies

```yaml
dependencies:
  flutter_bloc: ^9.1.0
  dio: ^5.8.0+1
  google_sign_in: ^6.2.1
  flutter_secure_storage: ^9.2.2
  formz: ^0.8.0
  equatable: ^2.0.7
```

## Best Practices

1. Always use the AuthBloc for authentication state management
2. Handle all authentication states in your UI
3. Use the repository pattern for business logic
4. Implement proper error handling and user feedback
5. Test authentication flows thoroughly
6. Keep sensitive data secure using flutter_secure_storage

## Troubleshooting

### Common Issues

1. **Google Sign-In not working**: Ensure proper Google OAuth configuration
2. **Token persistence issues**: Check flutter_secure_storage permissions
3. **Network errors**: Verify backend API endpoints and connectivity
4. **Form validation errors**: Check form validation logic in form BLoCs

### Debug Tips

1. Use the AuthDemoPage to test individual features
2. Check the AuthBloc state for debugging authentication issues
3. Monitor network requests in the Dio interceptors
4. Use Flutter Inspector to debug UI state issues
