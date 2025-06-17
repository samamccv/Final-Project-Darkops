import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:darkops/screens/login_options.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/auth/auth_bloc.dart';
import '../screens/email_verification_page.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  final _nameFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();

  bool _termAccepted = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  double _passwordStrength = 0;
  String _passwordStrengthText = '';

  late AnimationController _shakeController;
  late AnimationController _loadingController;
  late AnimationController _passwordStrengthController;
  late Animation<double> _shakeAnimation;
  late Animation<double> _loadingAnimation;
  late Animation<double> _passwordStrengthAnimation;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_checkPasswordStrength);
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

    _passwordStrengthController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _passwordStrengthAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _passwordStrengthController,
        curve: Curves.easeOut,
      ),
    );
  }

  @override
  void dispose() {
    _passwordController.removeListener(_checkPasswordStrength);
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    _shakeController.dispose();
    _loadingController.dispose();
    _passwordStrengthController.dispose();
    super.dispose();
  }

  void _checkPasswordStrength() {
    final password = _passwordController.text;
    final oldStrength = _passwordStrength;

    setState(() {
      if (password.isEmpty) {
        _passwordStrength = 0;
        _passwordStrengthText = '';
      } else if (password.length < 6) {
        _passwordStrength = 0.25;
        _passwordStrengthText = 'Too Weak';
      } else if (password.length < 8) {
        _passwordStrength = 0.5;
        _passwordStrengthText = 'Weak';
      } else if (!RegExp(r'[A-Z]').hasMatch(password) ||
          !RegExp(r'[0-9]').hasMatch(password)) {
        _passwordStrength = 0.75;
        _passwordStrengthText = 'Good';
      } else {
        _passwordStrength = 1.0;
        _passwordStrengthText = 'Strong';
      }
    });

    // Animate password strength changes
    if (_passwordStrength != oldStrength) {
      _passwordStrengthController.forward().then((_) {
        _passwordStrengthController.reverse();
      });
    }
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

        if (state.status == AuthStatus.emailVerificationRequired) {
          // Navigate to verification page
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder:
                  (context) => EmailVerificationPage(
                    email: state.user?.email ?? _emailController.text,
                  ),
            ),
          );
        } else if (state.status == AuthStatus.failure) {
          _shakeController.forward().then((_) {
            _shakeController.reverse();
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? 'An error occurred'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF101828),
        appBar: _buildAppBar(context),
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
                        const SizedBox(height: 20),

                        // Welcome Text
                        Text(
                          'Create Account',
                          style: GoogleFonts.poppins(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Sign up to get started',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 40),

                        // Name Field
                        _buildModernInputField(
                          label: 'Full Name',
                          hint: 'Enter your full name',
                          controller: _nameController,
                          focusNode: _nameFocusNode,
                          prefixIcon: Icons.person_outline,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your name';
                            }
                            if (value.length < 2) {
                              return 'Name must be at least 2 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),

                        // Email Field
                        _buildModernInputField(
                          label: 'Email Address',
                          hint: 'Enter your email',
                          controller: _emailController,
                          focusNode: _emailFocusNode,
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon: Icons.email_outlined,
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
                        const SizedBox(height: 8),

                        // Password Strength Bar
                        _buildModernPasswordStrengthBar(),
                        const SizedBox(height: 20),

                        // Confirm Password Field
                        _buildModernInputField(
                          label: 'Confirm Password',
                          hint: 'Confirm your password',
                          controller: _confirmPasswordController,
                          focusNode: _confirmPasswordFocusNode,
                          obscureText: _obscureConfirmPassword,
                          prefixIcon: Icons.lock_outline,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureConfirmPassword =
                                    !_obscureConfirmPassword;
                              });
                            },
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please confirm your password';
                            }
                            if (value != _passwordController.text) {
                              return 'Passwords do not match';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),

                        // Terms and Conditions
                        _buildModernTermsAndConditions(),
                        const SizedBox(height: 32),

                        // Continue Button
                        _buildModernContinueButton(),
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

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: Center(
        child: Text(
          'Sign Up With Email',
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
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const LoginOptions()),
          );
        },
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
                        color: const Color.fromARGB(
                          255,
                          139,
                          92,
                          246,
                        ).withValues(alpha: 0.3),
                        blurRadius: 8,
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
                borderSide: BorderSide(color: Colors.grey[600]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color.fromARGB(255, 139, 92, 246),
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
      ],
    );
  }

  // Modern Password Strength Bar
  Widget _buildModernPasswordStrengthBar() {
    if (_passwordStrength == 0) return const SizedBox.shrink();

    Color getBarColor() {
      if (_passwordStrength <= 0.25) return Colors.red;
      if (_passwordStrength <= 0.5) return Colors.orange;
      if (_passwordStrength <= 0.75) return Colors.yellow;
      return Colors.green;
    }

    return AnimatedBuilder(
      animation: _passwordStrengthAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: 1.0 + (_passwordStrengthAnimation.value * 0.05),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1D2939),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: getBarColor().withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Password Strength',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.white70,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      _passwordStrengthText,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: getBarColor(),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: _passwordStrength,
                    backgroundColor: Colors.grey.shade800,
                    color: getBarColor(),
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Modern Terms and Conditions
  Widget _buildModernTermsAndConditions() {
    return Row(
      children: [
        Transform.scale(
          scale: 1.2,
          child: Checkbox(
            value: _termAccepted,
            onChanged: (value) {
              setState(() {
                _termAccepted = value!;
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
        Expanded(
          child: RichText(
            text: TextSpan(
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.white),
              children: [
                const TextSpan(text: 'I accept the '),
                TextSpan(
                  text: 'Terms and Conditions',
                  style: GoogleFonts.poppins(
                    color: const Color.fromARGB(255, 139, 92, 246),
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                  ),
                ),
                const TextSpan(text: ' and '),
                TextSpan(
                  text: 'Privacy Policy',
                  style: GoogleFonts.poppins(
                    color: const Color.fromARGB(255, 139, 92, 246),
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Modern Continue Button
  Widget _buildModernContinueButton() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        return AnimatedBuilder(
          animation: _loadingAnimation,
          builder: (context, child) {
            return ElevatedButton(
              onPressed:
                  !state.isLoading && _termAccepted
                      ? () {
                        if (_formKey.currentState!.validate()) {
                          context.read<AuthBloc>().add(
                            AuthRegisterRequested(
                              name: _nameController.text,
                              email: _emailController.text,
                              password: _passwordController.text,
                            ),
                          );
                        }
                      }
                      : () {
                        if (!_termAccepted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text(
                                'Please accept the terms and conditions',
                              ),
                              backgroundColor: Colors.red,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          );
                        }
                      },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    _termAccepted
                        ? const Color.fromARGB(255, 139, 92, 246)
                        : Colors.grey[600],
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
                            'Creating Account...',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      )
                      : Text(
                        'Create Account',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
            );
          },
        );
      },
    );
  }
}
