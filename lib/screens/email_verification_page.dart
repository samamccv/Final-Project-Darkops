import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/auth/auth_bloc.dart';
import '../dashboard/homepage.dart';

class EmailVerificationPage extends StatefulWidget {
  final String email;

  const EmailVerificationPage({super.key, required this.email});

  @override
  State<EmailVerificationPage> createState() => _EmailVerificationPageState();
}

class _EmailVerificationPageState extends State<EmailVerificationPage>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final List<TextEditingController> _otpControllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());

  late AnimationController _shakeController;
  late AnimationController _successController;
  late AnimationController _loadingController;
  late Animation<double> _shakeAnimation;
  late Animation<double> _successAnimation;
  late Animation<double> _loadingAnimation;

  String get otpCode =>
      _otpControllers.map((controller) => controller.text).join();
  bool get isOtpComplete => otpCode.length == 6;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    // Shake animation for errors
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );

    // Success animation
    _successController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _successAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _successController, curve: Curves.elasticOut),
    );

    // Loading animation
    _loadingController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _loadingAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _loadingController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    _shakeController.dispose();
    _successController.dispose();
    _loadingController.dispose();
    super.dispose();
  }

  // Helper methods for OTP functionality
  void _onOtpChanged(String value, int index) {
    if (value.isNotEmpty && index < 5) {
      // Move to next field
      _focusNodes[index + 1].requestFocus();
    }

    // Trigger success animation when OTP is complete
    if (isOtpComplete) {
      _successController.forward().then((_) {
        _successController.reverse();
      });
    }

    setState(() {});
  }

  void _onOtpBackspace(int index) {
    if (_otpControllers[index].text.isEmpty && index > 0) {
      // Move to previous field
      _focusNodes[index - 1].requestFocus();
    }
  }

  void _pasteOtpCode(String pastedText) {
    if (pastedText.length == 6 && RegExp(r'^\d{6}$').hasMatch(pastedText)) {
      for (int i = 0; i < 6; i++) {
        _otpControllers[i].text = pastedText[i];
      }
      _focusNodes[5].requestFocus();
      setState(() {});
    }
  }

  void _clearOtp() {
    for (var controller in _otpControllers) {
      controller.clear();
    }
    _focusNodes[0].requestFocus();
    setState(() {});
  }

  void _submitOtp() {
    if (isOtpComplete) {
      context.read<AuthBloc>().add(
        AuthVerifyEmailRequested(email: widget.email, otp: otpCode),
      );
    } else {
      _shakeController.forward().then((_) {
        _shakeController.reverse();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101828),
      appBar: AppBar(
        title: const Text(
          'Verify Email',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF101828),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state.status == AuthStatus.loading) {
            _loadingController.repeat();
          } else {
            _loadingController.stop();
            _loadingController.reset();
          }

          if (state.status == AuthStatus.authenticated) {
            _successController.forward();
            Future.delayed(const Duration(milliseconds: 800), () {
              if (mounted) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const HomePage()),
                );
              }
            });
          } else if (state.status == AuthStatus.failure) {
            _shakeController.forward().then((_) {
              _shakeController.reverse();
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? 'Verification failed'),
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
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 48),

                // Icon with animation
                AnimatedBuilder(
                  animation: _successAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: 1.0 + (_successAnimation.value * 0.2),
                      child: Icon(
                        Icons.email_outlined,
                        size: 80,
                        color: Color.lerp(
                          const Color.fromARGB(255, 139, 92, 246),
                          Colors.green,
                          _successAnimation.value,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),

                // Title
                const Text(
                  'Verify Your Email',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),

                // Description
                Text(
                  'We\'ve sent a verification code to\n${widget.email}',
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),

                // Modern OTP Input with shake animation
                AnimatedBuilder(
                  animation: _shakeAnimation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(_shakeAnimation.value, 0),
                      child: _buildOtpInput(),
                    );
                  },
                ),
                const SizedBox(height: 32),

                // Verify Button
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    return ElevatedButton(
                      onPressed:
                          !state.isLoading && isOtpComplete ? _submitOtp : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            isOtpComplete
                                ? const Color.fromARGB(255, 139, 92, 246)
                                : Colors.grey,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child:
                          state.isLoading
                              ? const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Text(
                                    'Verifying...',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ],
                              )
                              : const Text(
                                'Verify Email',
                                style: TextStyle(color: Colors.white),
                              ),
                    );
                  },
                ),
                const SizedBox(height: 24),

                // Resend Code
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Didn't receive the code? ",
                      style: TextStyle(color: Colors.grey),
                    ),
                    BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) {
                        return TextButton(
                          onPressed:
                              !state.isLoading
                                  ? () {
                                    context.read<AuthBloc>().add(
                                      AuthResendVerificationRequested(
                                        email: widget.email,
                                      ),
                                    );
                                  }
                                  : null,
                          child: const Text(
                            'Resend',
                            style: TextStyle(
                              color: Color.fromARGB(255, 139, 92, 246),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Clear OTP Button
                if (otpCode.isNotEmpty)
                  TextButton(
                    onPressed: _clearOtp,
                    child: const Text(
                      'Clear Code',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),

                // Change Email
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    'Change Email Address',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Build modern OTP input interface
  Widget _buildOtpInput() {
    return Column(
      children: [
        // OTP Input Boxes
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(6, (index) {
            return _buildOtpBox(index);
          }),
        ),
        const SizedBox(height: 16),

        // Helper text
        Text(
          'Enter the 6-digit code sent to your email',
          style: TextStyle(color: Colors.grey[400], fontSize: 14),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // Build individual OTP input box
  Widget _buildOtpBox(int index) {
    final bool isFocused = _focusNodes[index].hasFocus;
    final bool hasValue = _otpControllers[index].text.isNotEmpty;

    return AnimatedBuilder(
      animation: _successAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: hasValue ? 1.0 + (_successAnimation.value * 0.1) : 1.0,
          child: Container(
            width: 50,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFF1D2939),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color:
                    hasValue
                        ? const Color.fromARGB(255, 139, 92, 246)
                        : isFocused
                        ? const Color.fromARGB(255, 139, 92, 246)
                        : Colors.grey[600]!,
                width: isFocused || hasValue ? 2 : 1,
              ),
              boxShadow:
                  isFocused
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
            child: TextField(
              controller: _otpControllers[index],
              focusNode: _focusNodes[index],
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              maxLength: 1,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                counterText: '',
              ),
              onChanged: (value) {
                if (value.length == 1) {
                  _onOtpChanged(value, index);
                } else if (value.isEmpty) {
                  _onOtpBackspace(index);
                } else if (value.length > 1) {
                  // Handle paste
                  _pasteOtpCode(value);
                }
              },
              onTap: () {
                // Clear the field when tapped for better UX
                if (_otpControllers[index].text.isNotEmpty) {
                  _otpControllers[index].clear();
                  setState(() {});
                }
              },
            ),
          ),
        );
      },
    );
  }
}
