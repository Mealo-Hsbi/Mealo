import 'package:firebase_auth/firebase_auth.dart';
import '../domain/user_model.dart';

class AuthRepository {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  /// Stream, der bei jedem Login/Logout das aktuelle UserModel oder null liefert
  Stream<UserModel?> get user {
    return _firebaseAuth.authStateChanges()
      .map((u) => u == null ? null : UserModel.fromFirebase(u));
  }

  Future<void> signUp({
    required String email,
    required String password,
  }) async {
    await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}
