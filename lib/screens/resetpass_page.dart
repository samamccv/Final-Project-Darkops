import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/auth/auth_bloc.dart';
import 'enhanced_login_page.dart';

class ResetPasswordPage extends StatefulWidget {
  final String email;

  const ResetPasswordPage({super.key, required this.email});

  @override
  State createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.unauthenticated && state.successMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.successMessage!),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const EnhancedLoginPage()),
            (route) => false,
          );
        } else if (state.status == AuthStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? 'Password reset failed'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: _buildAppBar(context),
        backgroundColor: Color(0xFF101828), // Updated background color
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                const SizedBox(height: 40),
                _buildInstructions(),
                const SizedBox(height: 20),
                _buildOtpField(),
                _buildPasswordField(
                  label: 'New Password',
                  hint: '********',
                  controller: _newPasswordController,
                  obscureText: _obscureNewPassword,
                  toggleVisibility: () {
                    setState(() {
                      _obscureNewPassword = !_obscureNewPassword;
                    });
                  },
                ),
                _buildPasswordField(
                  label: 'Confirm Password',
                  hint: '********',
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  toggleVisibility: () {
                    setState(() {
                      _obscureConfirmPassword = !_obscureConfirmPassword;
                    });
                  },
                  isConfirm: true,
                ),
                const SizedBox(height: 18),
                _buildResetButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // AppBar
  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: Center(
        child: Text(
          'Reset Password',
          style: GoogleFonts.poppins(
            fontSize: 16,
            color: const Color.fromRGBO(219, 211, 211, 1),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      backgroundColor: Color(0xFF101828), // Updated AppBar color
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      centerTitle: true,
    );
  }

  // Instruction Text
  Widget _buildInstructions() {
    return Text(
      'Enter the reset code sent to ${widget.email} and your new password.',
      style: GoogleFonts.poppins(
        fontSize: 13,
        color: const Color.fromARGB(255, 211, 207, 207),
      ),
      textAlign: TextAlign.center,
    );
  }

  // OTP Field
  Widget _buildOtpField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Reset Code',
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: const Color.fromARGB(236, 201, 196, 196),
          ),
        ),
        const SizedBox(height: 5),
        TextFormField(
          controller: _otpController,
          style: const TextStyle(color: Colors.white),
          keyboardType: TextInputType.number,
          maxLength: 6,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter the reset code';
            }
            if (value.length != 6) {
              return 'Code must be 6 digits';
            }
            return null;
          },
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFF1F1F1F),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: const BorderSide(
                color: Color.fromARGB(255, 112, 112, 112),
                width: 1.0,
              ),
            ),
            hintText: '6-digit code',
            hintStyle: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
            counterText: '',
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  // Password Field
  Widget _buildPasswordField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required bool obscureText,
    required VoidCallback toggleVisibility,
    bool isConfirm = false,
  }) {
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
          obscureText: obscureText,
          style: const TextStyle(color: Colors.white),
          validator: (value) {
            if (value == null || value.isEmpty) return 'Please enter $label';
            if (value.length < 8) {
              return 'Password must be at least 8 characters';
            }
            if (isConfirm && value != _newPasswordController.text) {
              return 'Passwords do not match';
            }
            return null;
          },
          decoration: _inputDecoration(hint, toggleVisibility, obscureText),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  // Reset Button
  Widget _buildResetButton() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        return Center(
          child: ElevatedButton(
            onPressed: !state.isLoading
                ? () {
                    if (_formKey.currentState!.validate()) {
                      context.read<AuthBloc>().add(
                        AuthResetPasswordRequested(
                          email: widget.email,
                          otp: _otpController.text,
                          newPassword: _newPasswordController.text,
                        ),
                      );
                    }
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Color.fromARGB(255, 139, 92, 246),
              padding: const EdgeInsets.symmetric(
                vertical: 12.0,
                horizontal: 100.0,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            child: state.isLoading
                ? const CircularProgressIndicator()
                : Text(
                    'Reset Password',
                    style: GoogleFonts.poppins(color: Colors.white, fontSize: 16.0),
                  ),
          ),
        );
      },
    );
  }

  // Input Decoration with visibility toggle
  InputDecoration _inputDecoration(
    String hintText,
    VoidCallback toggleVisibility,
    bool isObscured,
  ) {
    return InputDecoration(
      filled: true,
      fillColor: const Color(0xFF1F1F1F),
      suffixIcon: IconButton(
        icon: Icon(
          isObscured ? Icons.visibility_off : Icons.visibility,
          color: Colors.grey,
        ),
        onPressed: toggleVisibility,
      ),
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
