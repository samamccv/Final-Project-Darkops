import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/auth/user.dart';
import '../../models/auth/auth_exceptions.dart';
import '../../repositories/auth_repository.dart';

part 'auth_state.dart';
part 'auth_event.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc({required AuthRepository authRepository})
    : _authRepository = authRepository,
      super(const AuthState()) {
    // Register event handlers
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthLoginRequested>(_onAuthLoginRequested);
    on<AuthRegisterRequested>(_onAuthRegisterRequested);
    on<AuthGoogleSignInRequested>(_onAuthGoogleSignInRequested);
    on<AuthLogoutRequested>(_onAuthLogoutRequested);
    on<AuthForgotPasswordRequested>(_onAuthForgotPasswordRequested);
    on<AuthResetPasswordRequested>(_onAuthResetPasswordRequested);
    on<AuthVerifyEmailRequested>(_onAuthVerifyEmailRequested);
    on<AuthResendVerificationRequested>(_onAuthResendVerificationRequested);
    on<AuthErrorCleared>(_onAuthErrorCleared);
  }

  // Check authentication status on app start
  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));

    try {
      final user = await _authRepository.checkAuthStatus();
      if (user != null) {
        emit(
          state.copyWith(
            status: AuthStatus.authenticated,
            user: user,
            isEmailVerified: user.emailVerified,
          ),
        );
      } else {
        emit(state.copyWith(status: AuthStatus.unauthenticated));
      }
    } catch (error) {
      final authError =
          error is AuthException
              ? error
              : AuthExceptionMapper.mapException(error);
      emit(
        state.copyWith(status: AuthStatus.unauthenticated, error: authError),
      );
    }
  }

  // Handle login
  Future<void> _onAuthLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));

    try {
      final response = await _authRepository.login(
        email: event.email,
        password: event.password,
        rememberMe: event.rememberMe,
      );

      if (response.user != null) {
        if (response.user!.emailVerified) {
          emit(
            state.copyWith(
              status: AuthStatus.authenticated,
              user: response.user,
              token: response.token,
              isEmailVerified: true,
              successMessage: response.message,
            ),
          );
        } else {
          emit(
            state.copyWith(
              status: AuthStatus.emailVerificationRequired,
              user: response.user,
              token: response.token,
              isEmailVerified: false,
              successMessage: 'Please verify your email to continue.',
            ),
          );
        }
      }
    } catch (error) {
      final authError =
          error is AuthException
              ? error
              : AuthExceptionMapper.mapException(error);
      emit(state.copyWith(status: AuthStatus.failure, error: authError));
    }
  }

  // Handle registration
  Future<void> _onAuthRegisterRequested(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));

    try {
      final response = await _authRepository.register(
        email: event.email,
        password: event.password,
        name: event.name,
      );

      emit(
        state.copyWith(
          status: AuthStatus.emailVerificationRequired,
          user: response.user,
          isEmailVerified: false,
          successMessage: response.message,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: AuthStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  // Handle Google Sign-In
  Future<void> _onAuthGoogleSignInRequested(
    AuthGoogleSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));

    try {
      final response = await _authRepository.signInWithGoogle();

      if (response.user != null) {
        emit(
          state.copyWith(
            status: AuthStatus.authenticated,
            user: response.user,
            token: response.token,
            isEmailVerified: response.user!.emailVerified,
            successMessage: response.message,
          ),
        );
      }
    } catch (error) {
      emit(
        state.copyWith(
          status: AuthStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  // Handle logout
  Future<void> _onAuthLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));

    try {
      await _authRepository.logout();
      emit(
        state.copyWith(
          status: AuthStatus.unauthenticated,
          user: null,
          token: null,
          isEmailVerified: false,
          successMessage: 'Logged out successfully',
        ),
      );
    } catch (error) {
      // Even if logout fails on server, clear local state
      emit(
        state.copyWith(
          status: AuthStatus.unauthenticated,
          user: null,
          token: null,
          isEmailVerified: false,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  // Handle forgot password
  Future<void> _onAuthForgotPasswordRequested(
    AuthForgotPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));

    try {
      final response = await _authRepository.forgotPassword(email: event.email);
      emit(
        state.copyWith(
          status: AuthStatus.passwordResetRequired,
          successMessage: response.message,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: AuthStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  // Handle reset password
  Future<void> _onAuthResetPasswordRequested(
    AuthResetPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));

    try {
      final response = await _authRepository.resetPassword(
        email: event.email,
        otp: event.otp,
        newPassword: event.newPassword,
      );
      emit(
        state.copyWith(
          status: AuthStatus.unauthenticated,
          successMessage: response.message,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: AuthStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  // Handle email verification
  Future<void> _onAuthVerifyEmailRequested(
    AuthVerifyEmailRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));

    try {
      final response = await _authRepository.verifyEmail(
        email: event.email,
        otp: event.otp,
      );

      // Update user's email verification status
      final updatedUser = state.user?.copyWith(emailVerified: true);

      emit(
        state.copyWith(
          status: AuthStatus.authenticated,
          user: updatedUser,
          isEmailVerified: true,
          successMessage: response.message,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: AuthStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  // Handle resend verification
  Future<void> _onAuthResendVerificationRequested(
    AuthResendVerificationRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));

    try {
      final response = await _authRepository.resendVerification(
        email: event.email,
      );
      emit(
        state.copyWith(
          status: state.status, // Keep current status
          successMessage: response.message,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: AuthStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  // Clear error messages
  void _onAuthErrorCleared(AuthErrorCleared event, Emitter<AuthState> emit) {
    emit(state.copyWith(clearError: true, successMessage: null));
  }
}
