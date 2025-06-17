part of 'auth_bloc.dart';

enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  emailVerificationRequired,
  passwordResetRequired,
  failure,
}

class AuthState extends Equatable {
  final AuthStatus status;
  final User? user;
  final String? token;
  final AuthException? error;
  final String? errorMessage;
  final String? successMessage;
  final bool isEmailVerified;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.token,
    this.error,
    this.errorMessage,
    this.successMessage,
    this.isEmailVerified = false,
  });

  AuthState copyWith({
    AuthStatus? status,
    User? user,
    String? token,
    AuthException? error,
    String? errorMessage,
    String? successMessage,
    bool? isEmailVerified,
    bool clearError = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      token: token ?? this.token,
      error: clearError ? null : (error ?? this.error),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage: successMessage,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
    );
  }

  bool get isAuthenticated =>
      status == AuthStatus.authenticated && user != null;
  bool get isLoading => status == AuthStatus.loading;
  bool get hasError =>
      status == AuthStatus.failure && (error != null || errorMessage != null);

  // Get user-friendly error message
  String? get userFriendlyErrorMessage {
    if (error != null) {
      return error!.userFriendlyMessage;
    }
    return errorMessage;
  }

  @override
  List<Object?> get props => [
    status,
    user,
    token,
    error,
    errorMessage,
    successMessage,
    isEmailVerified,
  ];
}
