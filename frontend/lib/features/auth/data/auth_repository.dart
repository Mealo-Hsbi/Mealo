import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:dio/dio.dart';
import '/services/api_client.dart';
import '../domain/user_model.dart';

class AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;
  final ApiClient _api = ApiClient();

  AuthRepository({
    FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn();

  /// Für Tests, z. B. AuthRepository.forAuth(mockAuth)
  factory AuthRepository.forAuth(FirebaseAuth auth) =>
      AuthRepository(firebaseAuth: auth);

  Stream<UserModel?> get user {
    return _firebaseAuth
        .authStateChanges()
        .map((u) => u == null ? null : UserModel.fromFirebase(u));
  }

  Future<void> signUp({
    required String email,
    required String password,
  }) {
    return _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) {
    return _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    await _googleSignIn.signOut();
  }

  /// Nach E-Mail/Passwort-Registrierung: lege den User in der eigenen DB an
  Future<void> createUserInDb({required String name, String? avatarUrl}) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'no-current-user',
        message: 'Kein angemeldeter User gefunden.',
      );
    }
    final idToken = await user.getIdToken();
    await _api.post<Map<String, dynamic>>(
      '/users/register',
      data: {
        'name': name,
        if (avatarUrl != null) 'avatar_url': avatarUrl,
      },
      options: Options(headers: {
        'Authorization': 'Bearer $idToken',
      }),
    );
  }

  /// Google Sign-In + Upsert in eigener DB, speichert nur den Vornamen
  Future<void> signInWithGoogleAndSyncDb() async {
    // 1) Google OAuth Flow
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return; // Abbruch durch User

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // 2) Firebase Auth
    final userCred = await _firebaseAuth.signInWithCredential(credential);
    final user     = userCred.user;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'google_sign_in_failed',
        message: 'Google Sign-In fehlgeschlagen.',
      );
    }

    // 3) Vornamen extrahieren
    final fullName  = user.displayName?.trim() ?? '';
    final firstName = fullName.isNotEmpty ? fullName.split(' ').first : '';

    // 4) ID-Token holen
    final idToken = await user.getIdToken();

    // 5) Upsert in der eigenen DB (Register-/Upsert-Route)
    await _api.post<Map<String, dynamic>>(
      '/users/register',
      data: {
        'name'      : firstName,
        'avatar_url': user.photoURL,
      },
      options: Options(headers: {
        'Authorization': 'Bearer $idToken',
      }),
    );
  }
}
