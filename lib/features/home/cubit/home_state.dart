part of 'home_cubit.dart';

abstract class HomeState {}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final double calorieGoal;
  final double caloriesEaten;
  final List<Map<String, String>> recentMeals;

  HomeLoaded({
    required this.calorieGoal,
    required this.caloriesEaten,
    required this.recentMeals,
  });
}

class HomeError extends HomeState {
  final String message;
  HomeError(this.message);
}
