

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'bloc/auth_bloc.dart';
import 'main_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordObscured = true;
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    _loadRememberedUser();
  }

  Future<void> _loadRememberedUser() async {
    final prefs = await SharedPreferences.getInstance();
    final String? rememberedUsername = prefs.getString('remembered_username');
    if (rememberedUsername != null) {
      setState(() {
        _usernameController.text = rememberedUsername;
        _rememberMe = true;
      });
    }
  }

  Future<void> _handleRememberMe() async {
    final prefs = await SharedPreferences.getInstance();
    if (_rememberMe) {
      await prefs.setString('remembered_username', _usernameController.text);
    } else {
      await prefs.remove('remembered_username');
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthBloc(),
      child: Scaffold(
         resizeToAvoidBottomInset: false,
        backgroundColor: Colors.white,
        body: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
          // Inside BlocListener in login_screen.dart
if (state is AuthSuccess) {
  _handleRememberMe().then((_) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        
        builder: (_) => BlocProvider.value(
          value: context.read<AuthBloc>(),
          child: const MainScreen(),
        ),
      ),
      (route) => false,
    );
  });
} else if (state is AuthFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.error), backgroundColor: Colors.red),
              );
            }
          },  
          child: _buildBody(),
        ),
      ),
    );
  }

  Widget _buildBody() {
    const Color primaryBlue = Color(0xFF1A3C8B);
    const Color logoBlue = Color(0xFF8FA8E2);

    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Image.asset('assets/bottom-pattern.png', fit: BoxFit.cover, ),
        ),
        SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 60),
                  Container(width: 90, height: 90, decoration: const BoxDecoration(color: logoBlue, shape: BoxShape.circle)),
                  const SizedBox(height: 20),
                  const Text('LOGIN', textAlign: TextAlign.center, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.black87)),
                  const SizedBox(height: 8),
                  const Text('Lorem ipsum dolor sit amet, consectetur\nadipiscing elit, sed do eiusmod', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 14)),
                  const SizedBox(height: 40),
                  const Text('User Name', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _usernameController,
                    decoration: _buildInputDecoration('Enter your user name'),
                  ),
                  const SizedBox(height: 20),
                  const Text('Password', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _isPasswordObscured,
                    decoration: _buildInputDecoration('************').copyWith(
                      suffixIcon: IconButton(
                        icon: Icon(_isPasswordObscured ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                        onPressed: () => setState(() => _isPasswordObscured = !_isPasswordObscured),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          SizedBox(width: 24, height: 24, child: Checkbox(value: _rememberMe, onChanged: (value) => setState(() => _rememberMe = value ?? false))),
                          const SizedBox(width: 8),
                          const Text('Remember Me'),
                        ],
                      ),
                      const Text('Forget Password ?', style: TextStyle(color: primaryBlue, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 32),
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      return ElevatedButton(
                        onPressed: state is AuthLoading
                            ? null
                            : () {
                                context.read<AuthBloc>().add(
                                      LoginButtonPressed(
                                        username: _usernameController.text,
                                        password: _passwordController.text,
                                      ),
                                    );
                              },
                        style: ElevatedButton.styleFrom(backgroundColor: primaryBlue, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                        child: state is AuthLoading
                            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                            : const Text('LOGIN', style: TextStyle(fontSize: 16, color: Colors.white)),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        )
      ],
    );
  }

  InputDecoration _buildInputDecoration(String hintText) {
    return InputDecoration(
      hintText: hintText,
      contentPadding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0), borderSide: BorderSide(color: Colors.grey.shade300)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0), borderSide: BorderSide(color: Colors.grey.shade300)),
    );
  }
}