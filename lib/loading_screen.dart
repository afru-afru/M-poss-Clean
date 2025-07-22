import 'dart:async'; // 1. Import the async library for Timer
import 'package:flutter/material.dart';
import 'login_screen.dart'; // 2. Import the login screen

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    // 3. ADD THIS BLOCK to navigate after 4 seconds
    Timer(const Duration(seconds: 4), () {
      // This check ensures the screen is still visible before navigating
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Define the primary blue color from the image
    const Color primaryBlue = Color(0xFF1A3C8B);

    return Scaffold(
      backgroundColor: primaryBlue,
      body: Stack(
        children: [
          // 1. Bottom Cityscape Image
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
              child: Image.asset(
                'assets/bottom-pattern.png',
                // fit: BoxFit.cover,
                // color: const Color.fromARGB(255, 225, 235, 255).withOpacity(0.9),
                // colorBlendMode: BlendMode.srcATop,
              ),
            ),
          ),
          
          // 2. Main Content (Loader and Text)
          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Spinning Loader
                    RotationTransition(
                      turns: _controller,
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: const BoxDecoration(
                          color: Color(0xFF2E59B6),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    const SizedBox(height: 48),

                    // Title
                    const Text(
                      'MINISTRY OF REVENUES POS',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Body Text
                    Text(
                      'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.' * 2, // Repeated for length
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.85),
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 100), // Pushes content up from cityscape
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}