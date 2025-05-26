// lib/features/profile/domain/repositories/profile_repository.dart

import '../entities/upload_info.dart';

abstract class ProfileRepository {
  Future<String> fetchAvatarUrl(String objectKey);
  Future<UploadInfo> getUploadInfo(String filename, String contentType);

  /// Neu: lädt die Bytes direkt ins Bucket und gibt den objectKey zurück
  Future<String> uploadAvatar(
    String filename,
    List<int> bytes,
    String contentType,
  );
}
