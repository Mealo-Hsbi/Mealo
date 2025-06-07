import '../repositories/profile_repository.dart';

class UploadAvatar {
  final ProfileRepository repo;
  UploadAvatar(this.repo);

  /// Lädt [bytes] unter [filename] hoch und gibt den objectKey zurück
  Future<String> call(String filename, List<int> bytes, String contentType) {
    return repo.uploadAvatar(filename, bytes, contentType);
  }
}
