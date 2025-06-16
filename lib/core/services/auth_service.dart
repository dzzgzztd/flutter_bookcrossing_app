import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<UserModel?> register(String name, String email, String password) async {
    final result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    final user = result.user;

    if (user != null) {
      await user.updateDisplayName(name);
      return UserModel(
        id: user.uid,
        name: name,
        email: user.email!,
        avatarUrl: user.photoURL,
      );
    }
    return null;
  }

  Future<UserModel?> login(String email, String password) async {
    final result = await _auth.signInWithEmailAndPassword(email: email, password: password);
    final user = result.user;

    if (user != null) {
      return UserModel(
        id: user.uid,
        name: user.displayName ?? '',
        email: user.email!,
        avatarUrl: user.photoURL,
      );
    }
    return null;
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  Stream<UserModel?> get userChanges {
    return _auth.userChanges().map((user) {
      if (user == null) return null;
      return UserModel(
        id: user.uid,
        name: user.displayName ?? '',
        email: user.email!,
        avatarUrl: user.photoURL,
      );
    });
  }
}
