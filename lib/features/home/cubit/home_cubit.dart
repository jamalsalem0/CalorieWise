import 'package:flutter_bloc/flutter_bloc.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(HomeInitial());

  Future<void> loadHomeData() async {
    emit(HomeLoading());
    try {
      await Future.delayed(const Duration(seconds: 1));

      final mockData = {
        'calorieGoal': 2200.0,
        'caloriesEaten': 1540.0,
        'recentMeals': [
          {'name': 'Chicken Salad', 'calories': '350 kcal', 'time': '1:00 PM'},
          {
            'name': 'Oatmeal with Berries',
            'calories': '250 kcal',
            'time': '8:00 AM',
          },
        ],
      };

      emit(
        HomeLoaded(
          calorieGoal: mockData['calorieGoal'] as double,
          caloriesEaten: mockData['caloriesEaten'] as double,
          recentMeals: mockData['recentMeals'] as List<Map<String, String>>,
        ),
      );
    } catch (e) {
      emit(
        HomeError('Could not load your data. Please check your connection.'),
      );
    }
  }
}
