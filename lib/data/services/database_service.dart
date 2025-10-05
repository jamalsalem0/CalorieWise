import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  Future<void> updateMeal(
    String userId,
    String mealId,
    Map<String, dynamic> updatedData,
  ) async {
    await _db
        .collection('users')
        .doc(userId)
        .collection('meals')
        .doc(mealId)
        .update(updatedData);
  }

  Future<void> updateUserProfileField(
    String userId,
    Map<String, Object> dataToUpdate,
  ) async {
    await _db.collection('users').doc(userId).update(dataToUpdate);
  }

  Future<void> createUser(User user, String name) async {
    await _db.collection('users').doc(user.uid).set({
      'name': name,
      'email': user.email,
      'createdAt': FieldValue.serverTimestamp(),
      'weight': '0 kg',
      'height': '0 cm',
      'calorieGoal': '2000 kcal',
    });
  }

  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    final docSnap = await _db.collection('users').doc(userId).get();
    return docSnap.data();
  }

  Future<void> saveMeal(String userId, Map<String, dynamic> mealData) async {
    await _db.collection('users').doc(userId).collection('meals').add(mealData);
  }

  Future<List<Map<String, dynamic>>> getMealsForDate(
    String userId,
    DateTime date,
  ) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final querySnapshot = await _db
        .collection('users')
        .doc(userId)
        .collection('meals')
        .where('timestamp', isGreaterThanOrEqualTo: startOfDay)
        .where('timestamp', isLessThan: endOfDay)
        .orderBy('timestamp', descending: true)
        .get();

    return querySnapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return data;
    }).toList();
  }

  Future<void> deleteMeal(String userId, String mealId) async {
    await _db
        .collection('users')
        .doc(userId)
        .collection('meals')
        .doc(mealId)
        .delete();
  }
}
