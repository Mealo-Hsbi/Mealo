import '../repositories/profile_repository.dart';

class UploadAvatar {
  final ProfileRepository repo;
  UploadAvatar(this.repo);

  /// Lädt [bytes] unter [filename] hoch und speichert den objectKey als avatarUrl in der DB
  Future<void> call(String filename, List<int> bytes, String contentType) async {
    final objectKey = await repo.uploadAvatar(filename, bytes, contentType);
    await repo.saveAvatarKey(objectKey); // <-- PATCH /api/profile
  }
}
