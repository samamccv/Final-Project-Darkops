part of 'auth_bloc.dart';

enum AuthStatus { initial, loading, success, failure }

class AuthState extends Equatable {
  final String? email;
  final String? token;
  final AuthStatus status;
  final String? errorMessage;

  const AuthState({
    this.email,
    this.token,
    this.status = AuthStatus.initial,
    this.errorMessage,
  });

  AuthState copyWith({
    String? email,
    String? token,
    AuthStatus? status,
    String? errorMessage,
  }) {
    return AuthState(
      email: email ?? this.email,
      token: token ?? this.token,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [email, token, status, errorMessage];
}

final class AuthInitial extends AuthState {}
