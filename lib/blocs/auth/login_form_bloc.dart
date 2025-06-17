import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import '../../models/auth/email.dart';
import '../../models/auth/password.dart';
import '../../models/auth/auth_exceptions.dart';

// Events
abstract class LoginFormEvent extends Equatable {
  const LoginFormEvent();

  @override
  List<Object> get props => [];
}

class LoginEmailChanged extends LoginFormEvent {
  final String email;

  const LoginEmailChanged(this.email);

  @override
  List<Object> get props => [email];
}

class LoginPasswordChanged extends LoginFormEvent {
  final String password;

  const LoginPasswordChanged(this.password);

  @override
  List<Object> get props => [password];
}

class LoginRememberMeChanged extends LoginFormEvent {
  final bool rememberMe;

  const LoginRememberMeChanged(this.rememberMe);

  @override
  List<Object> get props => [rememberMe];
}

class LoginFormSubmitted extends LoginFormEvent {}

class LoginFormErrorCleared extends LoginFormEvent {}

class LoginFormErrorOccurred extends LoginFormEvent {
  final AuthException error;

  const LoginFormErrorOccurred(this.error);

  @override
  List<Object> get props => [error];
}

// State
class LoginFormState extends Equatable {
  final Email email;
  final Password password;
  final bool rememberMe;
  final FormzSubmissionStatus status;
  final bool isValid;
  final AuthException? error;
  final bool hasEmailError;
  final bool hasPasswordError;

  const LoginFormState({
    this.email = const Email.pure(),
    this.password = const Password.pure(),
    this.rememberMe = false,
    this.status = FormzSubmissionStatus.initial,
    this.isValid = false,
    this.error,
    this.hasEmailError = false,
    this.hasPasswordError = false,
  });

  LoginFormState copyWith({
    Email? email,
    Password? password,
    bool? rememberMe,
    FormzSubmissionStatus? status,
    bool? isValid,
    AuthException? error,
    bool? hasEmailError,
    bool? hasPasswordError,
    bool clearError = false,
  }) {
    return LoginFormState(
      email: email ?? this.email,
      password: password ?? this.password,
      rememberMe: rememberMe ?? this.rememberMe,
      status: status ?? this.status,
      isValid: isValid ?? this.isValid,
      error: clearError ? null : (error ?? this.error),
      hasEmailError: hasEmailError ?? this.hasEmailError,
      hasPasswordError: hasPasswordError ?? this.hasPasswordError,
    );
  }

  @override
  List<Object?> get props => [
    email,
    password,
    rememberMe,
    status,
    isValid,
    error,
    hasEmailError,
    hasPasswordError,
  ];
}

// BLoC
class LoginFormBloc extends Bloc<LoginFormEvent, LoginFormState> {
  LoginFormBloc() : super(const LoginFormState()) {
    on<LoginEmailChanged>(_onEmailChanged);
    on<LoginPasswordChanged>(_onPasswordChanged);
    on<LoginRememberMeChanged>(_onRememberMeChanged);
    on<LoginFormSubmitted>(_onFormSubmitted);
    on<LoginFormErrorCleared>(_onErrorCleared);
    on<LoginFormErrorOccurred>(_onErrorOccurred);
  }

  void _onEmailChanged(LoginEmailChanged event, Emitter<LoginFormState> emit) {
    final email = Email.dirty(event.email);
    emit(
      state.copyWith(
        email: email,
        isValid: Formz.validate([email, state.password]),
        clearError: true, // Clear errors when user starts typing
        hasEmailError: false,
      ),
    );
  }

  void _onPasswordChanged(
    LoginPasswordChanged event,
    Emitter<LoginFormState> emit,
  ) {
    final password = Password.dirty(event.password);
    emit(
      state.copyWith(
        password: password,
        isValid: Formz.validate([state.email, password]),
        clearError: true, // Clear errors when user starts typing
        hasPasswordError: false,
      ),
    );
  }

  void _onRememberMeChanged(
    LoginRememberMeChanged event,
    Emitter<LoginFormState> emit,
  ) {
    emit(state.copyWith(rememberMe: event.rememberMe));
  }

  void _onFormSubmitted(
    LoginFormSubmitted event,
    Emitter<LoginFormState> emit,
  ) {
    if (state.isValid) {
      emit(
        state.copyWith(
          status: FormzSubmissionStatus.inProgress,
          clearError: true,
        ),
      );
    }
  }

  void _onErrorCleared(
    LoginFormErrorCleared event,
    Emitter<LoginFormState> emit,
  ) {
    emit(
      state.copyWith(
        clearError: true,
        hasEmailError: false,
        hasPasswordError: false,
      ),
    );
  }

  void _onErrorOccurred(
    LoginFormErrorOccurred event,
    Emitter<LoginFormState> emit,
  ) {
    // Determine which fields have errors based on the exception type
    bool emailError = false;
    bool passwordError = false;

    if (event.error is InvalidCredentialsException ||
        event.error is UserNotFoundException) {
      // These errors could be related to either email or password
      emailError = true;
      passwordError = true;
    }

    emit(
      state.copyWith(
        status: FormzSubmissionStatus.failure,
        error: event.error,
        hasEmailError: emailError,
        hasPasswordError: passwordError,
      ),
    );
  }
}
