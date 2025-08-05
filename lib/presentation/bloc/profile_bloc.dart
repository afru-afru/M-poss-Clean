// lib/bloc/profile_bloc.dart

import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc() : super(ProfileInitial()) {
    on<LoadProfile>(_onLoadProfile);
  }

  Future<void> _onLoadProfile(
    LoadProfile event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());
    try {
      final String response = await rootBundle.loadString('assets/json/user.json');
      final data = await json.decode(response);
      emit(ProfileLoaded(user: data));
    } catch (e) {
      emit(ProfileError(message: "Failed to load user data: $e"));
    }
  }
}