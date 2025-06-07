import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:darkops/screens/login_page.dart';
import 'package:darkops/screens/signup_page.dart';

class LoginOptions extends StatelessWidget {
  const LoginOptions({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color.fromARGB(255, 6, 8, 27),
      body: LoginContent(),
    );
  }
}

class LoginContent extends StatelessWidget {
  const LoginContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        // Good for small screens or keyboard popups
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 90),
            Image.asset(
              'images/darkopslogo.png',
              width: 150,
              height: 40,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 0.5),
            Text(
              'Your safety is our priority',
              style: GoogleFonts.poppins(
                textStyle: const TextStyle(
                  color: Color.fromARGB(255, 174, 174, 174),
                  fontSize: 13,
                  fontWeight: FontWeight.w100,
                ),
              ),
            ),
            const SizedBox(height: 250),
            _buildButton(
              context,
              onPressed: () {}, // TODO: implement Google sign-in
              icon: Icons.g_mobiledata,
              text: 'Continue with Google',
              backgroundColor: Color.fromARGB(255, 139, 92, 246),
              textColor: Colors.white,
              iconColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 65,
                vertical: 6,
              ), // Custom padding
            ),
            const SizedBox(height: 2),
            _buildButton(
              context,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SignupPage()),
                );
              },
              icon: Icons.login,
              text: 'Sign Up for free',
              backgroundColor: Colors.white,
              textColor: const Color.fromARGB(255, 17, 23, 41),
              iconColor: const Color.fromARGB(255, 8, 7, 7),
              padding: const EdgeInsets.symmetric(
                horizontal: 90,
                vertical: 8,
              ), // Custom padding
            ),
            const SizedBox(height: 2),
            _buildButton(
              context,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              },
              text: 'Login',
              backgroundColor: Colors.white,
              textColor: const Color.fromARGB(255, 17, 23, 41),
              icon: null,
              padding: const EdgeInsets.symmetric(
                horizontal: 140,
                vertical: 8,
              ), // Custom padding
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(
    BuildContext context, {
    required VoidCallback onPressed,
    required String text,
    required Color backgroundColor,
    required Color textColor,
    IconData? icon,
    Color? iconColor,
    EdgeInsetsGeometry? padding,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        padding:
            padding ?? const EdgeInsets.symmetric(horizontal: 80, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(icon, color: iconColor ?? textColor),
            const SizedBox(width: 10),
          ],
          Text(
            text,
            style: GoogleFonts.poppins(
              textStyle: TextStyle(
                color: textColor,
                fontSize: 15,
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
