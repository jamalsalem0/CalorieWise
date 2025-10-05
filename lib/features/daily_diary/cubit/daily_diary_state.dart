part of 'daily_diary_cubit.dart';

abstract class DailyDiaryState {}

class DailyDiaryInitial extends DailyDiaryState {}

class DailyDiaryLoading extends DailyDiaryState {}

class DailyDiaryLoaded extends DailyDiaryState {
  final DateTime date;
  final List<Map<String, dynamic>> meals;
  DailyDiaryLoaded({required this.date, required this.meals});
}

class DailyDiaryError extends DailyDiaryState {
  final String message;
  DailyDiaryError(this.message);
}
