import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:http/http.dart' as http;

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitial()) {
    on<LoginButtonPressed>(_onLoginButtonPressed);
  }

  Future<void> _onLoginButtonPressed(
    LoginButtonPressed event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      // --- Step 1: Log in to get the token ---
      final loginUrl = Uri.parse('http://196.190.251.122:8084/api/auth/sign-in');
      final loginResponse = await http.post(
        loginUrl,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'username': event.username, 'password': event.password}),
      );

      if (loginResponse.statusCode != 200) {
        final errorData = json.decode(loginResponse.body);
        throw Exception(errorData['message'] ?? 'Invalid username or password');
      }

      // Cast the login data to the correct type
      final loginData = json.decode(loginResponse.body) as Map<String, dynamic>;
      final accessToken = loginData['access_token'];

      if (accessToken == null) {
        throw Exception('Access token not found in login response.');
      }

      // --- Step 2: Use the token to get user details from the /me endpoint ---
      final meUrl = Uri.parse('http://196.190.251.122:8086/api/Auth/me');
      final meResponse = await http.get(
        meUrl,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (meResponse.statusCode != 200) {
        throw Exception('Failed to fetch user details after login.');
      }

      // Cast the /me data to the correct type
      final meData = json.decode(meResponse.body) as Map<String, dynamic>;

      // --- Step 3: Combine data and emit success ---
      final completeUserData = {
        ...meData,
        'access_token': loginData['access_token'],
        'refresh_token': loginData['refresh_token'],
      };

      emit(AuthSuccess(user: completeUserData));

    } catch (e) {
      debugPrint("AuthBloc Error: $e");
      emit(AuthFailure(error: e.toString().replaceAll('Exception: ', '')));
    }
  }
}
