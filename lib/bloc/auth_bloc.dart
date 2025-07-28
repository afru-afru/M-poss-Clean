// lib/bloc/auth_bloc.dart

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
      // 2. Define the API endpoint
      final url = Uri.parse('http://196.190.251.122:8084/api/auth/sign-in');

      // 3. Make the POST request to the API
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'username': event.username,
          'password': event.password,
        }),
      );

      // 4. Check the response from the server
      if (response.statusCode == 200) {
        // If login is successful (status code 200 OK)
        final Map<String, dynamic> responseData = json.decode(response.body);
        
        // IMPORTANT: Ask your backend developer for the exact structure.
        // I am assuming the user data is directly in the response body.
        // If it's inside a key like "user", you would use responseData['user'].
        emit(AuthSuccess(user: responseData));
      } else {
        // If login fails, use the error message from the API if available
        final errorData = json.decode(response.body);
        final errorMessage = errorData['message'] ?? 'Invalid username or password';
        emit(AuthFailure(error: errorMessage));
      }
    } catch (e) {
      // Handle network errors or other exceptions
      debugPrint("AuthBloc Error: $e");
      emit(const AuthFailure(error: 'A network error occurred. Please try again.'));
    }
  }
}