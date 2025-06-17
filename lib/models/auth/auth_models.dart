import 'package:equatable/equatable.dart';
import 'user.dart';

// Request Models
class SignupRequest extends Equatable {
  final String email;
  final String password;
  final String name;

  const SignupRequest({
    required this.email,
    required this.password,
    required this.name,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'name': name,
    };
  }

  @override
  List<Object> get props => [email, password, name];
}

class LoginRequest extends Equatable {
  final String email;
  final String password;
  final bool rememberMe;

  const LoginRequest({
    required this.email,
    required this.password,
    this.rememberMe = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'rememberMe': rememberMe,
    };
  }

  @override
  List<Object> get props => [email, password, rememberMe];
}

class ForgotPasswordRequest extends Equatable {
  final String email;

  const ForgotPasswordRequest({required this.email});

  Map<String, dynamic> toJson() {
    return {'email': email};
  }

  @override
  List<Object> get props => [email];
}

class ResetPasswordRequest extends Equatable {
  final String email;
  final String otp;
  final String newPassword;

  const ResetPasswordRequest({
    required this.email,
    required this.otp,
    required this.newPassword,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'otp': otp,
      'newPassword': newPassword,
    };
  }

  @override
  List<Object> get props => [email, otp, newPassword];
}

class VerifyEmailRequest extends Equatable {
  final String email;
  final String otp;

  const VerifyEmailRequest({
    required this.email,
    required this.otp,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'otp': otp,
    };
  }

  @override
  List<Object> get props => [email, otp];
}

class ResendVerificationRequest extends Equatable {
  final String email;

  const ResendVerificationRequest({required this.email});

  Map<String, dynamic> toJson() {
    return {'email': email};
  }

  @override
  List<Object> get props => [email];
}

// Response Models
class AuthResponse extends Equatable {
  final String message;
  final String? token;
  final User? user;

  const AuthResponse({
    required this.message,
    this.token,
    this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      message: json['message'] as String,
      token: json['token'] as String?,
      user: json['user'] != null ? User.fromJson(json['user']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'token': token,
      'user': user?.toJson(),
    };
  }

  @override
  List<Object?> get props => [message, token, user];
}

class MessageResponse extends Equatable {
  final String message;

  const MessageResponse({required this.message});

  factory MessageResponse.fromJson(Map<String, dynamic> json) {
    return MessageResponse(
      message: json['message'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
    };
  }

  @override
  List<Object> get props => [message];
}

// Error Models
class AuthError extends Equatable {
  final String message;
  final int? statusCode;
  final String? type;

  const AuthError({
    required this.message,
    this.statusCode,
    this.type,
  });

  factory AuthError.fromJson(Map<String, dynamic> json) {
    return AuthError(
      message: json['message'] as String,
      statusCode: json['statusCode'] as int?,
      type: json['type'] as String?,
    );
  }

  @override
  List<Object?> get props => [message, statusCode, type];
}
