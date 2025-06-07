// lib/features/profile/domain/repositories/profile_repository.dart

import '../entities/profile_dto.dart';
import '../entities/upload_info.dart';

abstract class ProfileRepository {
  Future<ProfileDto> fetchProfile();
  Future<String>    fetchAvatarUrl(String objectKey);
  Future<UploadInfo> getUploadInfo(String filename, String contentType);
  Future<String>    uploadAvatar(String filename, List<int> bytes, String contentType);
  Future<void>      saveAvatarKey(String objectKey);  // neu
}
