import 'package:firebase_auth/firebase_auth.dart';
import 'package:calorie_wise/data/services/auth_service.dart';
import 'package:calorie_wise/data/services/database_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthService _authService;
  final DatabaseService _databaseService;

  AuthCubit({AuthService? authService, DatabaseService? databaseService})
    : _authService = authService ?? AuthService(),
      _databaseService = databaseService ?? DatabaseService(),
      super(AuthInitial());

  Future<void> signIn(String email, String password) async {
    emit(AuthLoading());
    try {
      await _authService.signIn(email: email, password: password);
      emit(AuthSuccess());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    emit(AuthLoading());
    try {
      final User? user = await _authService.signUp(
        email: email,
        password: password,
      );

      if (user != null) {
        await _databaseService.createUser(user, name);
        emit(AuthSuccess());
      } else {
        throw Exception('Could not create user account.');
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
}
