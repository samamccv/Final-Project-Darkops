import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:darkops/screens/verfication_page.dart';

class ForgetPasswordPage extends StatefulWidget {
  const ForgetPasswordPage({super.key});

  @override
  State createState() => _ForgetPasswordPageState();
}

class _ForgetPasswordPageState extends State<ForgetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      backgroundColor: const Color.fromARGB(255, 16, 17, 26),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const SizedBox(height: 40),
              _buildInstructions(),
              const SizedBox(height: 20),
              _buildInputField(
                'Email Address',
                'name@example.com',
                _emailController,
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
      backgroundColor: const Color.fromARGB(255, 16, 17, 26),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      centerTitle: true,
    );
  }

  // Instructions
  Widget _buildInstructions() {
    return Text(
      'Enter your email and we will send you instructions to reset your password.',
      style: GoogleFonts.poppins(
        fontSize: 13,
        color: const Color.fromARGB(255, 211, 207, 207),
      ),
      textAlign: TextAlign.center,
    );
  }

  // Email Field
  Widget _buildInputField(
    String label,
    String hint,
    TextEditingController controller,
  ) {
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
          style: const TextStyle(color: Colors.white),
          validator: (value) {
            if (value == null || value.isEmpty)
              return 'Please enter your email';
            if (!value.contains('@')) return 'Enter a valid email';
            return null;
          },
          decoration: _inputDecoration(hint),
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
                builder:
                    (context) =>
                        VerificationCodePage(email: _emailController.text),
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

  // Input Decoration
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
