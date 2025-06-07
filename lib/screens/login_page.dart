import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:darkops/screens/forgetpass_page.dart';
import 'package:darkops/screens/signup_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/auth/auth_bloc.dart';
import '../services/api_seevice.dart';
import 'package:darkops/dashboard/homepage.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _rememberMe = false;

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.success) {
          // Navigate to home page
          // Navigator.pushReplacement(...);
        } else if (state.status == AuthStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage ?? 'An error occurred')),
          );
        }
      },
      child: Scaffold(
        appBar: _buildAppBar(context),
        backgroundColor: const Color.fromARGB(
          255,
          6,
          8,
          27,
        ), // Updated background color
        body: Form(
          key: _formKey,
          child: ListView(
            children: [
              const SizedBox(height: 24),

              // Email Field
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: _buildInputField(
                  'Email Address',
                  'name@example.com',
                  _emailController,
                  isEmail: true,
                ),
              ),

              // Password Field
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: _buildInputField(
                  'Password',
                  '*******',
                  _passwordController,
                  isPassword: true,
                ),
              ),
              const SizedBox(height: 0.3),

              // Forgot Password
              Padding(
                padding: const EdgeInsets.only(right: 10.0),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ForgetPasswordPage(),
                        ),
                      );
                    },
                    child: Text(
                      'Forgot Password?',
                      style: GoogleFonts.poppins(
                        color: Colors.grey,
                        fontSize: 12,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              ),

              // Remember Me
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: _buildRememberMe(),
              ),

              const SizedBox(height: 18),

              // Login Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                child: _buildLoginButton(),
              ),

              const SizedBox(height: 12),

              // Sign Up Prompt
              _buildSignupPrompt(),

              const SizedBox(height: 20),
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
          'Login With Email',
          style: GoogleFonts.poppins(
            fontSize: 16,
            color: const Color.fromRGBO(219, 211, 211, 1),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      backgroundColor: const Color.fromARGB(
        255,
        6,
        8,
        27,
      ), // Updated AppBar color
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      centerTitle: true,
    );
  }

  // Input Field
  Widget _buildInputField(
    String label,
    String hint,
    TextEditingController controller, {
    bool isPassword = false,
    bool isEmail = false,
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
          style: const TextStyle(color: Colors.white),
          obscureText: isPassword,
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
            return null;
          },
          decoration: _inputDecoration(hint),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  // Remember Me Checkbox
  Widget _buildRememberMe() {
    return Row(
      children: [
        Checkbox(
          value: _rememberMe,
          onChanged: (value) {
            setState(() {
              _rememberMe = value!;
            });
          },
        ),
        Text(
          'Remember me',
          style: GoogleFonts.poppins(
            color: const Color.fromARGB(255, 211, 207, 207),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  // Login Button
  Widget _buildLoginButton() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        return ElevatedButton(
          onPressed:
              state.status == AuthStatus.loading
                  ? null
                  : () {
                    if (_formKey.currentState!.validate()) {
                      context.read<AuthBloc>().add(
                        LoginSubmitted(
                          email: _emailController.text,
                          password: _passwordController.text,
                        ),
                      );
                    }
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) =>  Homepage()),
                    );
                  },
          style: ElevatedButton.styleFrom(
            backgroundColor: Color.fromARGB(255, 139, 92, 246),
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
          child:
              state.status == AuthStatus.loading
                  ? const CircularProgressIndicator()
                  : Text(
                    'Login',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 16.0,
                    ),
                  ),
        );
      },
    );
  }

  // Signup Prompt
  Widget _buildSignupPrompt() {
    return Center(
      child: TextButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SignupPage()),
          );
        },
        child: Text(
          "Don't have an account? Sign Up",
          style: GoogleFonts.poppins(color: Colors.grey, fontSize: 12),
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
