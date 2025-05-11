import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/api_seevice.dart';

part 'auth_state.dart';
part 'auth_event.dart';

class LoginSubmitted extends AuthEvent {
  final String email;
  final String password;

  const LoginSubmitted({required this.email, required this.password});

  @override
  List<Object> get props => [email, password];
}

class SignupSubmitted extends AuthEvent {
  final String email;
  final String password;
  final String name;

  const SignupSubmitted({
    required this.email,
    required this.password,
    required this.name,
  });

  @override
  List<Object> get props => [email, password, name];
}

class VerifyCodeSubmitted extends AuthEvent {
  final String email;
  final String code;

  const VerifyCodeSubmitted({required this.email, required this.code});

  @override
  List<Object> get props => [email, code];
}

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final ApiService _apiService;

  AuthBloc({required ApiService apiService})
    : _apiService = apiService,
      super(AuthInitial()) {
    on<LoginSubmitted>(_onLoginSubmitted);
    on<SignupSubmitted>(_onSignupSubmitted);
    on<VerifyCodeSubmitted>(_onVerifyCodeSubmitted);
  }

  Future<void> _onLoginSubmitted(
    LoginSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      final response = await _apiService.login(event.email, event.password);
      emit(
        state.copyWith(
          status: AuthStatus.success,
          email: event.email,
          token: response.data['token'],
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

  Future<void> _onSignupSubmitted(
    SignupSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      final response = await _apiService.register(
        event.email,
        event.password,
        event.name,
      );
      emit(
        state.copyWith(
          status: AuthStatus.success,
          email: event.email,
          token: response.data['token'],
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

  Future<void> _onVerifyCodeSubmitted(
    VerifyCodeSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      final response = await _apiService.verifyCode(event.email, event.code);
      emit(state.copyWith(status: AuthStatus.success, email: event.email));
    } catch (error) {
      emit(
        state.copyWith(
          status: AuthStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }
}
