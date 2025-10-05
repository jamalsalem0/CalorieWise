part of 'profile_cubit.dart';

abstract class ProfileState {}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final String name;
  final String email;
  final String weight;
  final String height;
  final String calorieGoal;

  ProfileLoaded({
    required this.name,
    required this.email,
    required this.weight,
    required this.height,
    required this.calorieGoal,
  });
}

class ProfileError extends ProfileState {
  final String message;
  ProfileError(this.message);
}
