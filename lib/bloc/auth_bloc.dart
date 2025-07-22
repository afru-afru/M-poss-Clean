// lib/bloc/auth_bloc.dart

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

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
      await Future.delayed(const Duration(seconds: 1));
      
      // Load the new users.json file
      final String response = await rootBundle.loadString('assets/json/users.json');
      final List<dynamic> users = await json.decode(response);

      var foundUser = users.firstWhere(
        (user) => user['username'] == event.username.trim() && user['password'] == event.password,
        orElse: () => null,
      );

      if (foundUser != null) {
        // On success, emit the state with the found user's data
        emit(AuthSuccess(user: foundUser));
      } else {
        emit(const AuthFailure(error: 'Invalid username or password'));
      }
    } catch (e) {
      emit(AuthFailure(error: 'An error occurred: $e'));
    }
  }
}