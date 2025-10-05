part of 'results_cubit.dart';

abstract class ResultsState extends Equatable {
  const ResultsState();

  @override
  List<Object?> get props => [];
}

class ResultsInitial extends ResultsState {}

class ResultsLoading extends ResultsState {}

class ResultsSuccess extends ResultsState {
  final List<Map<String, dynamic>> recognizedItems;

  const ResultsSuccess(this.recognizedItems);

  @override
  List<Object?> get props => [recognizedItems];
}

class ResultsError extends ResultsState {
  final String message;

  const ResultsError(this.message);

  @override
  List<Object?> get props => [message];
}

class SavingMeal extends ResultsState {}

class MealSavedSuccess extends ResultsState {}

class MealSaveError extends ResultsState {
  final String message;

  const MealSaveError(this.message);

  @override
  List<Object?> get props => [message];
}
