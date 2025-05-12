import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:darkops/screens/verfication_page.dart';

class ResetPasswordPage extends StatefulWidget {
  final String email;

  const ResetPasswordPage({super.key, required this.email});

  @override
  State createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      backgroundColor: const Color.fromARGB(255, 6, 8, 27), // Updated background color
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const SizedBox(height: 40),
              _buildInstructions(),
              const SizedBox(height: 20),
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
      backgroundColor: const Color.fromARGB( 255, 6, 8, 27,), // Updated AppBar color
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      centerTitle: true,
    );
  }

  // Instruction Text
  Widget _buildInstructions() {
    return Text(
      'Please enter your new password and confirm it below.',
      style: GoogleFonts.poppins(
        fontSize: 13,
        color: const Color.fromARGB(255, 211, 207, 207),
      ),
      textAlign: TextAlign.center,
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
            if (value.length < 8)
              return 'Password must be at least 8 characters';
            if (isConfirm && value != _newPasswordController.text)
              return 'Passwords do not match';
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
    return Center(
      child: ElevatedButton(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => VerificationCodePage(email: widget.email),
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
        child: Text(
          'Reset Password',
          style: GoogleFonts.poppins(color: Colors.white, fontSize: 16.0),
        ),
      ),
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
