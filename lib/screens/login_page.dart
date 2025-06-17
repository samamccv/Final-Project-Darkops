import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:darkops/screens/forgot_password_page.dart';
import 'package:darkops/screens/signup_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/auth/auth_bloc.dart';
import '../models/auth/auth_exceptions.dart';
import 'package:darkops/dashboard/homepage.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  bool _rememberMe = false;
  bool _obscurePassword = true;

  // Error state tracking
  bool _hasEmailError = false;
  bool _hasPasswordError = false;
  String? _emailErrorText;
  String? _passwordErrorText;

  late AnimationController _shakeController;
  late AnimationController _loadingController;
  late Animation<double> _shakeAnimation;
  late Animation<double> _loadingAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );

    _loadingController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _loadingAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _loadingController, curve: Curves.easeInOut),
    );
  }

  void _clearErrors() {
    setState(() {
      _hasEmailError = false;
      _hasPasswordError = false;
      _emailErrorText = null;
      _passwordErrorText = null;
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _shakeController.dispose();
    _loadingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.loading) {
          _loadingController.repeat();
        } else {
          _loadingController.stop();
          _loadingController.reset();
        }

        if (state.status == AuthStatus.authenticated) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomePage()),
          );
        } else if (state.status == AuthStatus.emailVerificationRequired) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.successMessage ?? 'Please verify your email'),
              backgroundColor: Colors.orange,
            ),
          );
        } else if (state.status == AuthStatus.failure) {
          _shakeController.forward().then((_) {
            _shakeController.reverse();
          });

          // Update error states based on the type of error
          setState(() {
            if (state.error is InvalidCredentialsException ||
                state.error is UserNotFoundException) {
              _hasEmailError = true;
              _hasPasswordError = true;
              _emailErrorText = 'Please check your credentials';
              _passwordErrorText = 'Please check your credentials';
            } else if (state.error is NetworkException) {
              _hasEmailError = false;
              _hasPasswordError = false;
              _emailErrorText = null;
              _passwordErrorText = null;
            } else {
              _hasEmailError = false;
              _hasPasswordError = false;
              _emailErrorText = null;
              _passwordErrorText = null;
            }
          });

          // Get user-friendly error message
          final errorMessage =
              state.userFriendlyErrorMessage ?? 'An error occurred';

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: Colors.red[600],
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              margin: const EdgeInsets.all(16),
              duration: const Duration(seconds: 4),
            ),
          );
        }
      },
      child: Scaffold(
        appBar: _buildAppBar(context),
        backgroundColor: const Color(0xFF101828),
        body: AnimatedBuilder(
          animation: _shakeAnimation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(_shakeAnimation.value, 0),
              child: SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 40),

                        // Welcome Text
                        Text(
                          'Welcome Back',
                          style: GoogleFonts.poppins(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Sign in to your account',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 48),

                        // Email Field
                        _buildModernInputField(
                          label: 'Email Address',
                          hint: 'Enter your email',
                          controller: _emailController,
                          focusNode: _emailFocusNode,
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon: Icons.email_outlined,
                          hasError: _hasEmailError,
                          errorText: _emailErrorText,
                          onChanged: _clearErrors,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            }
                            if (!value.contains('@')) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),

                        // Password Field
                        _buildModernInputField(
                          label: 'Password',
                          hint: 'Enter your password',
                          controller: _passwordController,
                          focusNode: _passwordFocusNode,
                          obscureText: _obscurePassword,
                          prefixIcon: Icons.lock_outline,
                          hasError: _hasPasswordError,
                          errorText: _passwordErrorText,
                          onChanged: _clearErrors,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            if (value.length < 8) {
                              return 'Password must be at least 8 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Remember Me & Forgot Password Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildModernRememberMe(),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => const ForgotPasswordPage(),
                                  ),
                                );
                              },
                              child: Text(
                                'Forgot Password?',
                                style: GoogleFonts.poppins(
                                  color: const Color.fromARGB(
                                    255,
                                    139,
                                    92,
                                    246,
                                  ),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),

                        // Login Button
                        _buildModernLoginButton(),
                        const SizedBox(height: 24),

                        // Sign Up Prompt
                        _buildModernSignupPrompt(),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // AppBar
  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: Center(
        child: Text(
          'Login With Email',
          style: GoogleFonts.poppins(
            fontSize: 16,
            color: const Color.fromRGBO(219, 211, 211, 1),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      backgroundColor: const Color(0xFF101828),
      elevation: 0,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_new,
          color: Colors.white,
          size: 20,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      centerTitle: true,
    );
  }

  // Modern Input Field
  Widget _buildModernInputField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required FocusNode focusNode,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    IconData? prefixIcon,
    Widget? suffixIcon,
    String? Function(String?)? validator,
    bool hasError = false,
    String? errorText,
    VoidCallback? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow:
                focusNode.hasFocus
                    ? [
                      BoxShadow(
                        color:
                            hasError
                                ? Colors.red.withValues(alpha: 0.3)
                                : const Color.fromARGB(
                                  255,
                                  139,
                                  92,
                                  246,
                                ).withValues(alpha: 0.3),
                        blurRadius: 8,
                        spreadRadius: 0,
                      ),
                    ]
                    : hasError
                    ? [
                      BoxShadow(
                        color: Colors.red.withValues(alpha: 0.2),
                        blurRadius: 4,
                        spreadRadius: 0,
                      ),
                    ]
                    : null,
          ),
          child: TextFormField(
            controller: controller,
            focusNode: focusNode,
            keyboardType: keyboardType,
            obscureText: obscureText,
            style: GoogleFonts.poppins(color: Colors.white, fontSize: 16),
            validator: validator,
            onChanged: (value) {
              // Clear errors when user starts typing
              if (onChanged != null) {
                onChanged();
              }
              // Clear auth errors
              context.read<AuthBloc>().add(AuthErrorCleared());
            },
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.poppins(
                color: Colors.grey[400],
                fontSize: 16,
              ),
              prefixIcon:
                  prefixIcon != null
                      ? Icon(prefixIcon, color: Colors.grey[400])
                      : null,
              suffixIcon: suffixIcon,
              filled: true,
              fillColor: const Color(0xFF1D2939),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[600]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: hasError ? Colors.red[400]! : Colors.grey[600]!,
                  width: hasError ? 1.5 : 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color:
                      hasError
                          ? Colors.red
                          : const Color.fromARGB(255, 139, 92, 246),
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.red, width: 2),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.red, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
            onTap: () {
              setState(() {}); // Trigger rebuild for focus animation
            },
          ),
        ),
        // Error text display
        if (hasError && errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 4),
            child: Row(
              children: [
                Icon(Icons.error_outline, size: 16, color: Colors.red[400]),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    errorText,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.red[400],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  // Modern Remember Me Checkbox
  Widget _buildModernRememberMe() {
    return Row(
      children: [
        Transform.scale(
          scale: 1.2,
          child: Checkbox(
            value: _rememberMe,
            onChanged: (value) {
              setState(() {
                _rememberMe = value!;
              });
            },
            activeColor: const Color.fromARGB(255, 139, 92, 246),
            checkColor: Colors.white,
            side: BorderSide(color: Colors.grey[400]!),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          'Remember me',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  // Modern Login Button
  Widget _buildModernLoginButton() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final isLoading = state.isLoading;
        final canSubmit =
            !isLoading &&
            _emailController.text.isNotEmpty &&
            _passwordController.text.isNotEmpty;

        return AnimatedBuilder(
          animation: _loadingAnimation,
          builder: (context, child) {
            return Semantics(
              button: true,
              enabled: canSubmit,
              label:
                  isLoading
                      ? 'Signing in, please wait'
                      : 'Sign in to your account',
              child: ElevatedButton(
                onPressed:
                    canSubmit
                        ? () {
                          if (_formKey.currentState!.validate()) {
                            // Clear any existing errors
                            _clearErrors();

                            context.read<AuthBloc>().add(
                              AuthLoginRequested(
                                email: _emailController.text.trim(),
                                password: _passwordController.text,
                                rememberMe: _rememberMe,
                              ),
                            );
                          }
                        }
                        : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 139, 92, 246),
                  disabledBackgroundColor: Colors.grey[600],
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: state.isLoading ? 0 : 2,
                ),
                child:
                    state.isLoading
                        ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                                value: _loadingAnimation.value,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Signing In...',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        )
                        : Text(
                          'Sign In',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
              ),
            );
          },
        );
      },
    );
  }

  // Modern Signup Prompt
  Widget _buildModernSignupPrompt() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Don't have an account? ",
          style: GoogleFonts.poppins(color: Colors.grey, fontSize: 14),
        ),
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SignupPage()),
            );
          },
          child: Text(
            'Sign Up',
            style: GoogleFonts.poppins(
              color: const Color.fromARGB(255, 139, 92, 246),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
