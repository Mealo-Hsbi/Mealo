// lib/features/profile/data/repositories/profile_repository_impl.dart

import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '/services/api_client.dart';                     // hier importieren
import '../../domain/entities/profile_dto.dart';
import '../../domain/entities/upload_info.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_data_source.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remote;
  final ApiClient               apiClient;

  ProfileRepositoryImpl(this.remote, this.apiClient);

  @override
  Future<ProfileDto> fetchProfile() async {
    // Immer direkt vom Server laden, kein Cache mehr
    return await remote.fetchProfile();
  }

  @override
  Future<String> fetchAvatarUrl(String objectKey) =>
    remote.getAvatarDownloadUrl(objectKey);

  @override
  Future<UploadInfo> getUploadInfo(String filename, String contentType) =>
    remote.getAvatarUploadInfo(filename, contentType);

  @override
  Future<String> uploadAvatar(String filename, List<int> bytes, String contentType) async {
    final info = await remote.getAvatarUploadInfo(filename, contentType);

    await apiClient.put(
      info.uploadUrl,
      data: bytes,
      options: Options(headers: {'Content-Type': contentType}),
    );

    await remote.updateAvatarKey(info.objectKey); // 👈 hier wird's gespeichert!

    return info.objectKey;
  }

  @override
  Future<void> saveAvatarKey(String objectKey) =>
    remote.updateAvatarKey(objectKey);

  @override
  void invalidateCache() {
    // Kein Cache mehr vorhanden
  }
}
