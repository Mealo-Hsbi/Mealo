// lib/features/auth/presentation/providers/auth_state_provider.dart

import 'package:frontend/features/auth/data/auth_repository.dart';
import 'package:frontend/features/auth/domain/user_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authRepositoryProvider = Provider((ref) => AuthRepository());

final authStateChangesProvider = StreamProvider<UserModel?>((ref) {
  return ref.watch(authRepositoryProvider).user;
});

// Selector Provider, um nur die User ID (uid) zu erhalten, wenn der User eingeloggt ist
final currentUserIdProvider = Provider<String?>((ref) {
  final authState = ref.watch(authStateChangesProvider);
  return authState.when(
    data: (user) => user?.uid, // HIER GEÄNDERT: user?.uid statt user?.id
    loading: () => null,
    error: (err, stack) => null,
  );
});