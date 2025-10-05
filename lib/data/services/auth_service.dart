import 'package:calorie_wise/common/utils/error_handler.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<User?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      throw Exception(ErrorHandler.getFirebaseAuthErrorMessage(e));
    } catch (e) {
      throw Exception('An unexpected error occurred. Please try again.');
    }
  }

  Future<User?> signUp({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      throw Exception(ErrorHandler.getFirebaseAuthErrorMessage(e));
    } catch (e) {
      throw Exception('An unexpected error occurred. Please try again.');
    }
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}
