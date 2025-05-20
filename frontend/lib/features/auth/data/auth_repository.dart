import 'package:firebase_auth/firebase_auth.dart';
import '../domain/user_model.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthRepository {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

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

  Future<void> signInWithGoogle() async {
    // Startet den Google-Flow
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      // User hat abgebrochen
      return;
    }
    // Holt die Authentifizierungsdaten
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    // Erzeugt Firebase-Credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // Anmeldung bei Firebase
    await _firebaseAuth.signInWithCredential(credential);
  }

  @override
  Future<void> signOut() async {
    // Firebase und Google ausloggen
    await _firebaseAuth.signOut();
    await _googleSignIn.signOut();
  }
}
