import 'package:firebase_auth/firebase_auth.dart';
import 'package:calorie_wise/data/services/database_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'daily_diary_state.dart';

class DailyDiaryCubit extends Cubit<DailyDiaryState> {
  DailyDiaryCubit() : super(DailyDiaryInitial());

  final DatabaseService _databaseService = DatabaseService();
  final String? _userId = FirebaseAuth.instance.currentUser?.uid;
  Future<void> deleteMeal(String mealId, DateTime currentDate) async {
    if (_userId == null) return;
    try {
      await _databaseService.deleteMeal(_userId!, mealId);
      await loadDiaryForDate(currentDate);
    } catch (e) {
      print("Error deleting meal: $e");
    }
  }

  Future<void> updateMeal({
    required String mealId,
    required DateTime currentDate,
    required Map<String, dynamic> updatedData,
  }) async {
    if (_userId == null) return;
    try {
      await _databaseService.updateMeal(_userId!, mealId, updatedData);
      await loadDiaryForDate(currentDate);
    } catch (e) {
      print("Error updating meal: $e");
    }
  }

  Future<void> loadDiaryForDate(DateTime date) async {
    if (_userId == null) {
      emit(DailyDiaryError("User not logged in."));
      return;
    }
    emit(DailyDiaryLoading());
    try {
      final mealsForDay = await _databaseService.getMealsForDate(
        _userId!,
        date,
      );
      emit(DailyDiaryLoaded(date: date, meals: mealsForDay));
    } catch (e) {
      emit(DailyDiaryError('Could not load diary for this day.'));
    }
  }
}
