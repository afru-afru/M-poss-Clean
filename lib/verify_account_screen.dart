import 'dart:async';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'main_screen.dart';

class VerifyAccountScreen extends StatefulWidget {
  const VerifyAccountScreen({super.key});

  @override
  State<VerifyAccountScreen> createState() => _VerifyAccountScreenState();
}

class _VerifyAccountScreenState extends State<VerifyAccountScreen> {
  late Timer _timer;
  int _secondsRemaining = 59;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer.cancel(); // Cancel the timer to avoid memory leaks
    super.dispose();
  }

  void _startTimer() {
    _canResend = false;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        setState(() {
          _canResend = true;
        });
        _timer.cancel();
      }
    });
  }

  void _resendCode() {
    // In a real app, you would add logic here to resend the code
    setState(() {
      _secondsRemaining = 59;
      _startTimer();
    });
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryBlue = Color(0xFF1A3C8B);
    const Color logoBlue = Color(0xFF8FA8E2);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Bottom pattern image
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Image.asset(
              'assets/bottom-pattern.png',
              fit: BoxFit.cover,
              // color: const Color.fromARGB(255, 225, 235, 255).withOpacity(0.9),
              colorBlendMode: BlendMode.srcATop,
            ),
          ),

          // Main Content
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 60),
                    // Logo Placeholder
                    Container(
                      width: 90,
                      height: 90,
                      decoration: const BoxDecoration(
                        color: logoBlue,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Title
                    const Text(
                      'VERIFY ACCOUNT',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Subtitle
                    const Text(
                      'Lorem ipsum dolor sit amet, consectetur\nadipiscing elit, sed do eiusmod',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Verification Field
                    const Text('Verification Sent in Text', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    TextFormField(
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      decoration: _buildInputDecoration('085612'),
                    ),
                    const SizedBox(height: 16),
                    
                    // Timer and Resend link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        RichText(
                          textAlign: TextAlign.right,
                          text: TextSpan(
                            style: const TextStyle(color: Colors.black87, fontSize: 14),
                            children: [
                              if (!_canResend)
                                TextSpan(text: '0:${_secondsRemaining.toString().padLeft(2, '0')} SEC\n'),
                              const TextSpan(text: "I haven't received a code ! "),
                              TextSpan(
                                text: 'Resend',
                                style: TextStyle(
                                  color: _canResend ? primaryBlue : primaryBlue,
                                  // fontWeight: FontWeight.bold,
                                ),
                                recognizer: _canResend
                                    ? (TapGestureRecognizer()..onTap = _resendCode)
                                    : null,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Verify Button
                    ElevatedButton(
        onPressed: () {
    // This removes all previous screens (like Login) and shows MainScreen
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const MainScreen()),
      (Route<dynamic> route) => false,
    );
  },

                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryBlue,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'VERIFY ACCOUNT',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  // Helper method for input decoration
  InputDecoration _buildInputDecoration(String hintText) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: Colors.grey, letterSpacing: 2),
      contentPadding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
    );
  }
}