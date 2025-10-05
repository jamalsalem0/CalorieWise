import 'package:firebase_auth/firebase_auth.dart';

class ErrorHandler {
  static String getFirebaseAuthErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'هذا البريد الإلكتروني غير مسجل.';
      case 'wrong-password':
        return 'كلمة المرور غير صحيحة.';
      case 'email-already-in-use':
        return 'هذا البريد الإلكتروني مسجل بالفعل.';
      case 'invalid-email':
        return 'البريد الإلكتروني غير صالح.';
      case 'weak-password':
        return 'كلمة المرور ضعيفة جدًا.';
      case 'network-request-failed':
        return 'حدث خطأ في الشبكة، يرجى المحاولة مرة أخرى.';
      default:
        return 'حدث خطأ غير متوقع، يرجى المحاولة لاحقًا.';
    }
  }
}
