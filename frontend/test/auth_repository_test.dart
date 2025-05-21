// test/auth_repository_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:frontend/features/auth/data/auth_repository.dart';
import 'package:frontend/features/auth/domain/user_model.dart';

void main() {
  late MockFirebaseAuth mockAuth;
  late AuthRepository repo;

  setUp(() {
    mockAuth = MockFirebaseAuth();
    repo = AuthRepository.forAuth(mockAuth);
  });

  test('signUp erstellt User', () async {
    await repo.signUp(email: 'a@b.com', password: 'password');
    final user = mockAuth.currentUser;
    expect(user, isNotNull);
    expect(user!.email, 'a@b.com');
  });

  test('user stream feuert UserModel nach Login', () async {
    // Wartet auf das erste Nicht-Null-Event im Stream
    final futureModel = repo.user.firstWhere((u) => u != null);

    // Login auslösen
    await mockAuth.signInWithEmailAndPassword(
      email: 'a@b.com',
      password: 'password',
    );

    // Auf das UserModel warten
    final model = await futureModel;

    // Überprüfen, dass wir ein UserModel bekommen und die UID stimmt
    expect(model, isA<UserModel>());
    expect(model!.uid, equals(mockAuth.currentUser!.uid));
  });
}
