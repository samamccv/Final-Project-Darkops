import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:darkops/blocs/auth/auth_bloc.dart';
import 'package:darkops/blocs/auth/login_form_bloc.dart';
import 'package:darkops/models/auth/auth_exceptions.dart';
import 'package:darkops/repositories/auth_repository.dart';
import 'package:darkops/models/auth/auth_models.dart';
import 'package:formz/formz.dart';

// Generate mocks
@GenerateMocks([AuthRepository])
import 'login_exception_handling_test.mocks.dart';

void main() {
  group('Login Exception Handling Tests', () {
    late MockAuthRepository mockAuthRepository;
    late AuthBloc authBloc;
    late LoginFormBloc loginFormBloc;

    setUp(() {
      mockAuthRepository = MockAuthRepository();
      authBloc = AuthBloc(authRepository: mockAuthRepository);
      loginFormBloc = LoginFormBloc();
    });

    tearDown(() {
      authBloc.close();
      loginFormBloc.close();
    });

    group('AuthExceptionMapper', () {
      test('maps invalid credentials error correctly', () {
        final exception = Exception('Invalid credentials provided');
        final mappedException = AuthExceptionMapper.mapException(exception);
        
        expect(mappedException, isA<InvalidCredentialsException>());
        expect(mappedException.userFriendlyMessage, 
               'Incorrect email or password. Please check your credentials and try again.');
      });

      test('maps user not found error correctly', () {
        final exception = Exception('User not found');
        final mappedException = AuthExceptionMapper.mapException(exception);
        
        expect(mappedException, isA<UserNotFoundException>());
        expect(mappedException.userFriendlyMessage, 
               'No account found with this email address. Please check your email or sign up.');
      });

      test('maps network error correctly', () {
        final exception = Exception('Connection timeout');
        final mappedException = AuthExceptionMapper.mapException(exception);
        
        expect(mappedException, isA<TimeoutException>());
        expect(mappedException.userFriendlyMessage, 
               'The request took too long to complete. Please check your connection and try again.');
      });

      test('maps unknown error correctly', () {
        final exception = Exception('Some random error');
        final mappedException = AuthExceptionMapper.mapException(exception);
        
        expect(mappedException, isA<UnknownAuthException>());
        expect(mappedException.userFriendlyMessage, 
               'Something went wrong. Please try again or contact support if the problem persists.');
      });
    });

    group('LoginFormBloc', () {
      test('initial state is correct', () {
        expect(loginFormBloc.state.status, FormzSubmissionStatus.initial);
        expect(loginFormBloc.state.isValid, false);
        expect(loginFormBloc.state.error, null);
        expect(loginFormBloc.state.hasEmailError, false);
        expect(loginFormBloc.state.hasPasswordError, false);
      });

      blocTest<LoginFormBloc, LoginFormState>(
        'clears errors when email changes',
        build: () => loginFormBloc,
        act: (bloc) {
          // First set an error
          bloc.add(const LoginFormErrorOccurred(InvalidCredentialsException()));
          // Then change email
          bloc.add(const LoginEmailChanged('test@example.com'));
        },
        expect: () => [
          // Error state
          isA<LoginFormState>()
              .having((s) => s.error, 'error', isA<InvalidCredentialsException>())
              .having((s) => s.hasEmailError, 'hasEmailError', true)
              .having((s) => s.hasPasswordError, 'hasPasswordError', true),
          // Cleared state
          isA<LoginFormState>()
              .having((s) => s.error, 'error', null)
              .having((s) => s.hasEmailError, 'hasEmailError', false),
        ],
      );

      blocTest<LoginFormBloc, LoginFormState>(
        'clears errors when password changes',
        build: () => loginFormBloc,
        act: (bloc) {
          // First set an error
          bloc.add(const LoginFormErrorOccurred(InvalidCredentialsException()));
          // Then change password
          bloc.add(const LoginPasswordChanged('newpassword'));
        },
        expect: () => [
          // Error state
          isA<LoginFormState>()
              .having((s) => s.error, 'error', isA<InvalidCredentialsException>())
              .having((s) => s.hasEmailError, 'hasEmailError', true)
              .having((s) => s.hasPasswordError, 'hasPasswordError', true),
          // Cleared state
          isA<LoginFormState>()
              .having((s) => s.error, 'error', null)
              .having((s) => s.hasPasswordError, 'hasPasswordError', false),
        ],
      );

      blocTest<LoginFormBloc, LoginFormState>(
        'handles error occurred event correctly',
        build: () => loginFormBloc,
        act: (bloc) => bloc.add(const LoginFormErrorOccurred(InvalidCredentialsException())),
        expect: () => [
          isA<LoginFormState>()
              .having((s) => s.status, 'status', FormzSubmissionStatus.failure)
              .having((s) => s.error, 'error', isA<InvalidCredentialsException>())
              .having((s) => s.hasEmailError, 'hasEmailError', true)
              .having((s) => s.hasPasswordError, 'hasPasswordError', true),
        ],
      );

      blocTest<LoginFormBloc, LoginFormState>(
        'handles error cleared event correctly',
        build: () => loginFormBloc,
        act: (bloc) {
          // First set an error
          bloc.add(const LoginFormErrorOccurred(InvalidCredentialsException()));
          // Then clear it
          bloc.add(LoginFormErrorCleared());
        },
        expect: () => [
          // Error state
          isA<LoginFormState>()
              .having((s) => s.error, 'error', isA<InvalidCredentialsException>()),
          // Cleared state
          isA<LoginFormState>()
              .having((s) => s.error, 'error', null)
              .having((s) => s.hasEmailError, 'hasEmailError', false)
              .having((s) => s.hasPasswordError, 'hasPasswordError', false),
        ],
      );
    });

    group('AuthBloc', () {
      blocTest<AuthBloc, AuthState>(
        'emits user-friendly error when login fails with invalid credentials',
        build: () => authBloc,
        act: (bloc) {
          when(mockAuthRepository.login(
            email: anyNamed('email'),
            password: anyNamed('password'),
            rememberMe: anyNamed('rememberMe'),
          )).thenThrow(const InvalidCredentialsException());
          
          bloc.add(const AuthLoginRequested(
            email: 'test@example.com',
            password: 'wrongpassword',
            rememberMe: false,
          ));
        },
        expect: () => [
          isA<AuthState>()
              .having((s) => s.status, 'status', AuthStatus.loading),
          isA<AuthState>()
              .having((s) => s.status, 'status', AuthStatus.failure)
              .having((s) => s.error, 'error', isA<InvalidCredentialsException>())
              .having((s) => s.userFriendlyErrorMessage, 'userFriendlyErrorMessage', 
                     'Incorrect email or password. Please check your credentials and try again.'),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'emits user-friendly error when login fails with network error',
        build: () => authBloc,
        act: (bloc) {
          when(mockAuthRepository.login(
            email: anyNamed('email'),
            password: anyNamed('password'),
            rememberMe: anyNamed('rememberMe'),
          )).thenThrow(const NetworkException());
          
          bloc.add(const AuthLoginRequested(
            email: 'test@example.com',
            password: 'password123',
            rememberMe: false,
          ));
        },
        expect: () => [
          isA<AuthState>()
              .having((s) => s.status, 'status', AuthStatus.loading),
          isA<AuthState>()
              .having((s) => s.status, 'status', AuthStatus.failure)
              .having((s) => s.error, 'error', isA<NetworkException>())
              .having((s) => s.userFriendlyErrorMessage, 'userFriendlyErrorMessage', 
                     'Unable to connect to the server. Please check your internet connection and try again.'),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'clears errors when AuthErrorCleared is added',
        build: () => authBloc,
        act: (bloc) {
          // First set an error
          when(mockAuthRepository.login(
            email: anyNamed('email'),
            password: anyNamed('password'),
            rememberMe: anyNamed('rememberMe'),
          )).thenThrow(const InvalidCredentialsException());
          
          bloc.add(const AuthLoginRequested(
            email: 'test@example.com',
            password: 'wrongpassword',
            rememberMe: false,
          ));
          
          // Then clear the error
          bloc.add(AuthErrorCleared());
        },
        expect: () => [
          isA<AuthState>()
              .having((s) => s.status, 'status', AuthStatus.loading),
          isA<AuthState>()
              .having((s) => s.status, 'status', AuthStatus.failure)
              .having((s) => s.error, 'error', isA<InvalidCredentialsException>()),
          isA<AuthState>()
              .having((s) => s.error, 'error', null)
              .having((s) => s.errorMessage, 'errorMessage', null),
        ],
      );
    });
  });
}
