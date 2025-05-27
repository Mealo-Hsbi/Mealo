// lib/features/profile/domain/usecases/get_profile.dart

import '../entities/profile_dto.dart';
import '../repositories/profile_repository.dart';

/// Use-Case zum Laden aller Profildaten vom Backend.
class GetProfile {
  final ProfileRepository _repository;

  /// Konstruktor erwartet eine Implementierung von [ProfileRepository].
  GetProfile(this._repository);

  /// Ruft `/api/profilescreen` über das Repository ab und
  /// liefert ein [ProfileDto] zurück.
  Future<ProfileDto> call() {
    return _repository.fetchProfile();
  }
}
