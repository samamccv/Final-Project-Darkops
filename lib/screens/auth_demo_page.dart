import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/auth/auth_bloc.dart';
import 'enhanced_login_page.dart';
import 'enhanced_signup_page.dart';
import 'forgot_password_page.dart';

class AuthDemoPage extends StatelessWidget {
  const AuthDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101828),
      appBar: AppBar(
        title: const Text(
          'Authentication Demo',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF101828),
        elevation: 0,
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state.status == AuthStatus.authenticated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Successfully authenticated!'),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state.status == AuthStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? 'Authentication failed'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              
              // Current Auth Status
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  return Card(
                    color: const Color(0xFF1D2939),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Current Auth Status:',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Status: ${state.status.name}',
                            style: const TextStyle(color: Colors.white70),
                          ),
                          if (state.user != null) ...[
                            Text(
                              'User: ${state.user!.name ?? 'Unknown'}',
                              style: const TextStyle(color: Colors.white70),
                            ),
                            Text(
                              'Email: ${state.user!.email}',
                              style: const TextStyle(color: Colors.white70),
                            ),
                            Text(
                              'Email Verified: ${state.user!.emailVerified}',
                              style: const TextStyle(color: Colors.white70),
                            ),
                          ],
                          if (state.errorMessage != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              'Error: ${state.errorMessage}',
                              style: const TextStyle(color: Colors.red),
                            ),
                          ],
                          if (state.successMessage != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              'Success: ${state.successMessage}',
                              style: const TextStyle(color: Colors.green),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 32),
              
              // Authentication Actions
              const Text(
                'Authentication Actions:',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              // Enhanced Login Button
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const EnhancedLoginPage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 139, 92, 246),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Enhanced Login Page',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Enhanced Signup Button
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const EnhancedSignupPage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 59, 130, 246),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Enhanced Signup Page',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Forgot Password Button
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ForgotPasswordPage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 245, 158, 11),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Forgot Password Flow',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Google Sign In Button
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  return ElevatedButton(
                    onPressed: !state.isLoading
                        ? () {
                            context.read<AuthBloc>().add(AuthGoogleSignInRequested());
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 15, 185, 129),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: state.isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Test Google Sign In',
                            style: TextStyle(color: Colors.white),
                          ),
                  );
                },
              ),
              
              const SizedBox(height: 32),
              
              // Logout Button (if authenticated)
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  if (state.isAuthenticated) {
                    return ElevatedButton(
                      onPressed: () {
                        context.read<AuthBloc>().add(AuthLogoutRequested());
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        'Logout',
                        style: TextStyle(color: Colors.white),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
              
              const SizedBox(height: 16),
              
              // Clear Error Button
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  if (state.hasError || state.successMessage != null) {
                    return TextButton(
                      onPressed: () {
                        context.read<AuthBloc>().add(AuthErrorCleared());
                      },
                      child: const Text(
                        'Clear Messages',
                        style: TextStyle(color: Colors.white70),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
