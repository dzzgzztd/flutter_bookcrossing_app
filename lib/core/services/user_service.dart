import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class UserService {
  final _firestore = FirebaseFirestore.instance;

  Future<void> saveUserProfile(UserModel profile) async {
    await _firestore.collection('users').doc(profile.id).set(profile.toJson());
  }

  Future<UserModel?> getUserProfile(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists) return null;

    final data = doc.data()!;
    return UserModel(
      id: doc.id, 
      name: data['name'] ?? 'Без имени',
      email: data['email'] ?? 'Нет email',
      avatarUrl: data['avatarUrl'],
    );
  }
}
