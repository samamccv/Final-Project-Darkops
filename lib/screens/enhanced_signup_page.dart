import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/auth/signup_form_bloc.dart';
import 'email_verification_page.dart';
import 'enhanced_login_page.dart';

class EnhancedSignupPage extends StatelessWidget {
  const EnhancedSignupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SignupFormBloc(),
      child: const _SignupForm(),
    );
  }
}

class _SignupForm extends StatelessWidget {
  const _SignupForm();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state.status == AuthStatus.emailVerificationRequired) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (_) => EmailVerificationPage(
                      email: state.user?.email ?? '',
                    ),
                  ),
                );
              } else if (state.status == AuthStatus.failure) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.errorMessage ?? 'Registration failed'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          ),
          BlocListener<SignupFormBloc, SignupFormState>(
            listener: (context, state) {
              if (state.status.isInProgress) {
                // Trigger auth bloc registration
                context.read<AuthBloc>().add(
                  AuthRegisterRequested(
                    email: state.email.value,
                    password: state.password.value,
                    name: state.name.value,
                  ),
                );
              }
            },
          ),
        ],
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 24),
                
                // Title
                const Text(
                  'Create Account',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Sign up to get started',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),

                // Name Field
                BlocBuilder<SignupFormBloc, SignupFormState>(
                  buildWhen: (previous, current) => previous.name != current.name,
                  builder: (context, state) {
                    return TextFormField(
                      onChanged: (name) => context.read<SignupFormBloc>().add(
                        SignupNameChanged(name),
                      ),
                      decoration: InputDecoration(
                        labelText: 'Full Name',
                        errorText: state.name.displayError?.name,
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.person),
                      ),
                      textCapitalization: TextCapitalization.words,
                    );
                  },
                ),
                const SizedBox(height: 16),

                // Email Field
                BlocBuilder<SignupFormBloc, SignupFormState>(
                  buildWhen: (previous, current) => previous.email != current.email,
                  builder: (context, state) {
                    return TextFormField(
                      onChanged: (email) => context.read<SignupFormBloc>().add(
                        SignupEmailChanged(email),
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
                BlocBuilder<SignupFormBloc, SignupFormState>(
                  buildWhen: (previous, current) => previous.password != current.password,
                  builder: (context, state) {
                    return TextFormField(
                      onChanged: (password) => context.read<SignupFormBloc>().add(
                        SignupPasswordChanged(password),
                      ),
                      decoration: InputDecoration(
                        labelText: 'Password',
                        errorText: state.password.displayError?.name,
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.lock),
                        helperText: 'Must be at least 8 characters',
                      ),
                      obscureText: true,
                    );
                  },
                ),
                const SizedBox(height: 16),

                // Confirm Password Field
                BlocBuilder<SignupFormBloc, SignupFormState>(
                  buildWhen: (previous, current) => previous.confirmPassword != current.confirmPassword,
                  builder: (context, state) {
                    return TextFormField(
                      onChanged: (confirmPassword) => context.read<SignupFormBloc>().add(
                        SignupConfirmPasswordChanged(confirmPassword),
                      ),
                      decoration: InputDecoration(
                        labelText: 'Confirm Password',
                        errorText: state.confirmPassword.displayError?.name,
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.lock_outline),
                      ),
                      obscureText: true,
                    );
                  },
                ),
                const SizedBox(height: 32),

                // Sign Up Button
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, authState) {
                    return BlocBuilder<SignupFormBloc, SignupFormState>(
                      builder: (context, formState) {
                        return ElevatedButton(
                          onPressed: formState.isValid && !authState.isLoading
                              ? () => context.read<SignupFormBloc>().add(SignupFormSubmitted())
                              : null,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: authState.isLoading
                              ? const CircularProgressIndicator()
                              : const Text('Create Account'),
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

                // Google Sign Up Button
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

                // Sign In Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Already have an account? '),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (_) => const EnhancedLoginPage(),
                          ),
                        );
                      },
                      child: const Text('Sign In'),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
