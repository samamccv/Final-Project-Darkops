import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:darkops/screens/login_options.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/auth/auth_bloc.dart';
import '../screens/verfication_page.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _termAccepted = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  double _passwordStrength = 0;
  String _passwordStrengthText = '';

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_checkPasswordStrength);
  }

  @override
  void dispose() {
    _passwordController.removeListener(_checkPasswordStrength);
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _checkPasswordStrength() {
    final password = _passwordController.text;

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
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.success) {
          // Navigate to verification page
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder:
                  (context) => VerificationCodePage(
                    email: state.email ?? _emailController.text,
                  ),
            ),
          );
        } else if (state.status == AuthStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? 'An error occurred'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: _buildAppBar(context),
        backgroundColor: const Color.fromARGB(255, 16, 17, 26),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                _buildInputField('Your Name', 'John Doe', _nameController),
                _buildInputField(
                  'Email Address',
                  'name@example.com',
                  _emailController,
                  isEmail: true,
                ),
                _buildInputField(
                  'Password',
                  '*******',
                  _passwordController,
                  isPassword: true,
                ),
                _buildPasswordStrengthBar(),
                _buildInputField(
                  'Confirm Password',
                  '*******',
                  _confirmPasswordController,
                  isPassword: true,
                  isConfirm: true,
                ),
                _buildTermsAndConditions(),
                const SizedBox(height: 18),
                _buildContinueButton(),
              ],
            ),
          ),
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
      backgroundColor: const Color.fromARGB(255, 16, 17, 26),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
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

  Widget _buildInputField(
    String label,
    String hint,
    TextEditingController controller, {
    bool isPassword = false,
    bool isEmail = false,
    bool isConfirm = false,
  }) {
    bool isObscure = isConfirm ? _obscureConfirmPassword : _obscurePassword;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: const Color.fromARGB(236, 201, 196, 196),
          ),
        ),
        const SizedBox(height: 5),
        TextFormField(
          controller: controller,
          obscureText: isPassword ? isObscure : false,
          style: const TextStyle(color: Colors.white),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter ${label.toLowerCase()}';
            }
            if (isEmail && !value.contains('@')) {
              return 'Please enter a valid email';
            }
            if (isPassword && value.length < 8) {
              return 'Password must be at least 8 characters';
            }
            if (isConfirm && value != _passwordController.text) {
              return 'Passwords do not match';
            }
            return null;
          },
          decoration: _inputDecoration(hint).copyWith(
            suffixIcon:
                isPassword
                    ? IconButton(
                      icon: Icon(
                        isObscure ? Icons.visibility_off : Icons.visibility,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          if (isConfirm) {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
                          } else {
                            _obscurePassword = !_obscurePassword;
                          }
                        });
                      },
                    )
                    : null,
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildPasswordStrengthBar() {
    if (_passwordStrength == 0) return const SizedBox.shrink();

    Color getBarColor() {
      if (_passwordStrength <= 0.25) return Colors.red;
      if (_passwordStrength <= 0.5) return Colors.orange;
      if (_passwordStrength <= 0.75) return Colors.yellow;
      return Colors.green;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LinearProgressIndicator(
          value: _passwordStrength,
          backgroundColor: Colors.grey.shade800,
          color: getBarColor(),
          minHeight: 6,
        ),
        const SizedBox(height: 4),
        Text(
          _passwordStrengthText,
          style: GoogleFonts.poppins(fontSize: 12, color: Colors.white70),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildTermsAndConditions() {
    return Row(
      children: [
        Checkbox(
          value: _termAccepted,
          onChanged: (value) {
            setState(() {
              _termAccepted = value!;
            });
          },
        ),
        Flexible(
          child: Text(
            'I accept the terms and conditions',
            style: GoogleFonts.poppins(
              color: const Color.fromARGB(255, 211, 207, 207),
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContinueButton() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        return Center(
          child: ElevatedButton(
            onPressed:
                state.status == AuthStatus.loading
                    ? null
                    : () {
                      if (_formKey.currentState!.validate() && _termAccepted) {
                        context.read<AuthBloc>().add(
                          SignupSubmitted(
                            name: _nameController.text,
                            email: _emailController.text,
                            password: _passwordController.text,
                          ),
                        );
                      } else if (!_termAccepted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Please accept the terms and conditions',
                            ),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6A5B8E),
              padding: const EdgeInsets.symmetric(
                vertical: 12.0,
                horizontal: 100.0,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            child:
                state.status == AuthStatus.loading
                    ? const CircularProgressIndicator()
                    : Text(
                      'Continue',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 16.0,
                      ),
                    ),
          ),
        );
      },
    );
  }

  InputDecoration _inputDecoration(String hintText) {
    return InputDecoration(
      filled: true,
      fillColor: const Color(0xFF1F1F1F),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(
          color: Color.fromARGB(255, 112, 112, 112),
          width: 1.0,
        ),
      ),
      hintText: hintText,
      hintStyle: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
    );
  }
}
