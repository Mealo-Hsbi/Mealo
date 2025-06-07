// lib/features/profile/domain/usecases/get_avatar_url.dart

import '../repositories/profile_repository.dart';

class GetAvatarUrl {
  final ProfileRepository repo;
  GetAvatarUrl(this.repo);

  Future<String> call(String objectKey) => repo.fetchAvatarUrl(objectKey);
}
