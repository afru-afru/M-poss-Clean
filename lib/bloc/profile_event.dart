

part of 'profile_bloc.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object> get props => [];
}

// Event to tell the BLoC to load the user's profile data
class LoadProfile extends ProfileEvent {}