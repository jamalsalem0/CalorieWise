import 'package:firebase_auth/firebase_auth.dart';
import 'package:calorie_wise/data/services/database_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit() : super(ProfileInitial());

  final DatabaseService _databaseService = DatabaseService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Future<void> updateProfileField(String field, String value) async {
    if (_auth.currentUser == null) return;
    try {
      await _databaseService.updateUserProfileField(_auth.currentUser!.uid, {
        field: value,
      });
      await loadProfile();
    } catch (e) {
      print("Error updating profile field: $e");
    }
  }

  Future<void> loadProfile() async {
    emit(ProfileLoading());
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not logged in');
      }

      final profileData = await _databaseService.getUserProfile(user.uid);
      if (profileData == null) {
        throw Exception('User profile not found');
      }

      emit(
        ProfileLoaded(
          name: profileData['name'] ?? 'No Name',
          email: profileData['email'] ?? 'No Email',
          weight: profileData['weight'] ?? 'N/A',
          height: profileData['height'] ?? 'N/A',
          calorieGoal: profileData['calorieGoal'] ?? 'N/A',
        ),
      );
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }
}
