import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/auth/login_form_bloc.dart';
import '../dashboard/homepage.dart';
import 'enhanced_signup_page.dart';
import 'forgot_password_page.dart';

class EnhancedLoginPage extends StatelessWidget {
  const EnhancedLoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LoginFormBloc(),
      child: const _LoginForm(),
    );
  }
}

class _LoginForm extends StatelessWidget {
  const _LoginForm();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign In'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state.status == AuthStatus.authenticated) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const HomePage()),
                );
              } else if (state.status == AuthStatus.emailVerificationRequired) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.successMessage ?? 'Please verify your email'),
                    backgroundColor: Colors.orange,
                  ),
                );
              } else if (state.status == AuthStatus.failure) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.errorMessage ?? 'Login failed'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          ),
          BlocListener<LoginFormBloc, LoginFormState>(
            listener: (context, state) {
              if (state.status.isInProgress) {
                // Trigger auth bloc login
                context.read<AuthBloc>().add(
                  AuthLoginRequested(
                    email: state.email.value,
                    password: state.password.value,
                    rememberMe: state.rememberMe,
                  ),
                );
              }
            },
          ),
        ],
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 48),
              
              // Logo or Title
              const Text(
                'Welcome Back',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Sign in to your account',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),

              // Email Field
              BlocBuilder<LoginFormBloc, LoginFormState>(
                buildWhen: (previous, current) => previous.email != current.email,
                builder: (context, state) {
                  return TextFormField(
                    onChanged: (email) => context.read<LoginFormBloc>().add(
                      LoginEmailChanged(email),
                    ),
                    decoration: InputDecoration(
                      labelText: 'Email',
                      errorText: state.email.displayError?.name,
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.email),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  );
                },
              ),
              const SizedBox(height: 16),

              // Password Field
              BlocBuilder<LoginFormBloc, LoginFormState>(
                buildWhen: (previous, current) => previous.password != current.password,
                builder: (context, state) {
                  return TextFormField(
                    onChanged: (password) => context.read<LoginFormBloc>().add(
                      LoginPasswordChanged(password),
                    ),
                    decoration: InputDecoration(
                      labelText: 'Password',
                      errorText: state.password.displayError?.name,
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.lock),
                    ),
                    obscureText: true,
                  );
                },
              ),
              const SizedBox(height: 16),

              // Remember Me Checkbox
              BlocBuilder<LoginFormBloc, LoginFormState>(
                buildWhen: (previous, current) => previous.rememberMe != current.rememberMe,
                builder: (context, state) {
                  return Row(
                    children: [
                      Checkbox(
                        value: state.rememberMe,
                        onChanged: (value) => context.read<LoginFormBloc>().add(
                          LoginRememberMeChanged(value ?? false),
                        ),
                      ),
                      const Text('Remember me'),
                      const Spacer(),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const ForgotPasswordPage(),
                            ),
                          );
                        },
                        child: const Text('Forgot Password?'),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),

              // Login Button
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, authState) {
                  return BlocBuilder<LoginFormBloc, LoginFormState>(
                    builder: (context, formState) {
                      return ElevatedButton(
                        onPressed: formState.isValid && !authState.isLoading
                            ? () => context.read<LoginFormBloc>().add(LoginFormSubmitted())
                            : null,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: authState.isLoading
                            ? const CircularProgressIndicator()
                            : const Text('Sign In'),
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 16),

              // Divider
              const Row(
                children: [
                  Expanded(child: Divider()),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text('OR'),
                  ),
                  Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 16),

              // Google Sign In Button
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  return OutlinedButton.icon(
                    onPressed: !state.isLoading
                        ? () => context.read<AuthBloc>().add(AuthGoogleSignInRequested())
                        : null,
                    icon: const Icon(Icons.login),
                    label: const Text('Continue with Google'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),

              // Sign Up Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account? "),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const EnhancedSignupPage(),
                        ),
                      );
                    },
                    child: const Text('Sign Up'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
