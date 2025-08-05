

import 'package:flutter/material.dart';
import 'login_screen.dart'; 

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryBlue = Color(0xFF1A3C8B);
    const Color logoBlue = Color(0xFF8FA8E2);
    const Color backgroundColor = Color(0xFFF0F4FF);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        fit: StackFit.expand,
        children: [
        
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Image.asset(
              'assets/bottom-pattern.png',
              fit: BoxFit.cover,
              // color: const Color.fromARGB(255, 225, 235, 255).withOpacity(0.9),
              // colorBlendMode: BlendMode.srcATop,
            ),
          ),
          // Main content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),
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
                    'MINISTRY OF REVENUES POS',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: primaryBlue,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Subtitle
                  const Text(
                    'Lorem ipsum dolor sit amet, consectetur adipiscing',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  const SizedBox(height: 60),
                  // Login Options
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildLoginOption(
                        context: context,
                        
                        imagePath: 'assets/adminLogo.png',
                        title: 'ADMIN',
                        subtitle: 'login to manage system settings and users',
                      ),
                      _buildLoginOption(
                        context: context,
                        
                        imagePath: 'assets/salesLogo.png',
                        title: 'SALES',
                        subtitle: 'login to access your cashier account',
                      ),
                    ],
                  ),
                  const Spacer(flex: 2),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper widget that now uses an image
  Widget _buildLoginOption({
    required BuildContext context,
    required String imagePath,
    required String title,
    required String subtitle,
  }) {
    return GestureDetector(
      onTap: () {
        // When tapped, navigate to the main login screen
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      },
      child: Column(
        children: [
          Image.asset(
            imagePath,
            width: 40,
            height: 40,
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A3C8B),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          SizedBox(
            width: 120,
            child: Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}