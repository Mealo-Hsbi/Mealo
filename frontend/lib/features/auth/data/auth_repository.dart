import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:dio/dio.dart';
import '/services/api_client.dart';
import '../domain/user_model.dart';

class AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;
  final ApiClient _api;

  /// Hauptkonstruktor mit Dependency Injection (empfohlen für Tests)
  AuthRepository({
    FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
    ApiClient? apiClient,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn(),
        _api = apiClient ?? ApiClient();

  /// Alternativ-Konstruktor für Tests mit nur FirebaseAuth
  factory AuthRepository.forAuth(FirebaseAuth auth) =>
      AuthRepository(firebaseAuth: auth);

  /// Stream für Benutzerstatusänderungen
  Stream<UserModel?> get user {
    return _firebaseAuth
        .authStateChanges()
        .asyncMap((u) async {
          if (u == null) return null;
          try {
            final response = await _api.get('/users/me');
            return UserModel.fromJson(response.data);
          } catch (e) {
            // Fallback: Nur Firebase-Daten
            return UserModel.fromFirebase(u);
          }
        });
  }

  /// Registrierung mit E-Mail und Passwort
  Future<void> signUp({
    required String email,
    required String password,
  }) {
    return _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  /// Anmeldung mit E-Mail und Passwort
  Future<void> signIn({
    required String email,
    required String password,
  }) {
    return _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  /// Abmelden (Firebase + Google)
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    await _googleSignIn.signOut();
  }

  /// Nutzer nach Registrierung in der eigenen DB speichern
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

  /// Google Sign-In + Nutzer-Sync in DB (Upsert)
  Future<void> signInWithGoogleAndSyncDb() async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return; // Abbruch durch Nutzer

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCred = await _firebaseAuth.signInWithCredential(credential);
    final user = userCred.user;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'google_sign_in_failed',
        message: 'Google Sign-In fehlgeschlagen.',
      );
    }

    final fullName = user.displayName?.trim() ?? '';
    final firstName = fullName.isNotEmpty ? fullName.split(' ').first : '';

    final idToken = await user.getIdToken();
    await _api.post<Map<String, dynamic>>(
      '/users/register',
      data: {
        'name': firstName,
        'avatar_url': user.photoURL,
      },
      options: Options(headers: {
        'Authorization': 'Bearer $idToken',
      }),
    );
  }
}
