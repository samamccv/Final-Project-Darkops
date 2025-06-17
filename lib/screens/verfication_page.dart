import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import '../blocs/auth/auth_bloc.dart';

import '../dashboard/homepage.dart';

class VerificationCodePage extends StatefulWidget {
  final String email;

  const VerificationCodePage({super.key, required this.email});

  @override
  State<VerificationCodePage> createState() => _VerificationCodePageState();
}

class _VerificationCodePageState extends State<VerificationCodePage> {
  final _formKey = GlobalKey<FormState>();
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  final List<TextEditingController> _controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _onDigitEntered(int index, String value) {
    if (value.length > 1) {
      // User pasted the full code
      for (int i = 0; i < 6; i++) {
        if (i < value.length) {
          _controllers[i].text = value[i];
        }
      }
      _focusNodes[5].unfocus(); // Remove focus from last box
      return;
    }

    if (value.isNotEmpty && index < 5) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  String get _code => _controllers.map((c) => c.text).join();

  bool get _isCodeComplete =>
      _controllers.every((controller) => controller.text.trim().isNotEmpty);

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.authenticated) {
          // Navigate to home page
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomePage()),
          );
        } else if (state.status == AuthStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? 'An error occurred'),
              backgroundColor: Colors.red,
            ),
          );
        } else if (state.successMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.successMessage!),
              backgroundColor: Colors.green,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: _buildAppBar(),
        backgroundColor: Color(0xFF101828),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 40),
                _buildInstructions(),
                const SizedBox(height: 30),
                _buildCodeBoxes(),
                const SizedBox(height: 30),
                _buildContinueButton(),
                const SizedBox(height: 20),
                _buildResendText(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Center(
        child: Text(
          'Verification Code',
          style: GoogleFonts.poppins(
            fontSize: 16,
            color: const Color.fromRGBO(219, 211, 211, 1),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      backgroundColor: Color(0xFF101828),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      centerTitle: true,
    );
  }

  Widget _buildInstructions() {
    return Text(
      'Enter the 6-digit code sent to your email or phone number.',
      style: GoogleFonts.poppins(
        fontSize: 13,
        color: const Color.fromARGB(255, 211, 207, 207),
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildCodeBoxes() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(6, (index) {
        return SizedBox(
          width: 45,
          child: TextFormField(
            controller: _controllers[index],
            focusNode: _focusNodes[index],
            keyboardType: TextInputType.number, // Ensures the numeric keyboard
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 18),
            maxLength: 1,
            onChanged: (value) => _onDigitEntered(index, value),
            inputFormatters: [
              FilteringTextInputFormatter
                  .digitsOnly, // Ensures only digits are entered
            ],
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFF1F1F1F),
              counterText: '',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: const BorderSide(
                  color: Color.fromARGB(255, 112, 112, 112),
                  width: 1.0,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildContinueButton() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final bool isLoading = state.status == AuthStatus.loading;
        final bool isDisabled = isLoading || !_isCodeComplete;

        return ElevatedButton(
          onPressed:
              isDisabled
                  ? null
                  : () {
                context.read<AuthBloc>().add(
                  AuthVerifyEmailRequested(email: widget.email, otp: _code),
                );
                  },
          style: ElevatedButton.styleFrom(
            backgroundColor:
                isDisabled
                    ? const Color(0xFF6A5B8E).withOpacity(0.5)
                    : Color.fromARGB(255, 139, 92, 246),
            padding: const EdgeInsets.symmetric(
              vertical: 12.0,
              horizontal: 100.0,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
          child:
              isLoading
                  ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                  : Text(
                    'Verify',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 16.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
        );
      },
    );
  }

  Widget _buildResendText() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        return TextButton(
          onPressed: !state.isLoading
              ? () {
                  context.read<AuthBloc>().add(
                    AuthResendVerificationRequested(email: widget.email),
                  );
                }
              : null,
          child: Text(
            'Resend Code',
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: const Color.fromARGB(255, 211, 207, 207),
              decoration: TextDecoration.underline,
            ),
          ),
        );
      },
    );
  }
}
