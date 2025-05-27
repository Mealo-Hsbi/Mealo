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

  ProfileDto?  _cache;
  DateTime?    _cacheTime;
  final Duration cacheDuration = const Duration(minutes: 5);

  ProfileRepositoryImpl(this.remote, this.apiClient);

  @override
  Future<ProfileDto> fetchProfile() async {
    if (_cache != null
        && _cacheTime != null
        && DateTime.now().difference(_cacheTime!) < cacheDuration) {
      _refreshProfile();
      return _cache!;
    }
    final profile = await remote.fetchProfile();
    _cache     = profile;
    _cacheTime = DateTime.now();
    return profile;
  }

  Future<void> _refreshProfile() async {
    try {
      final fresh = await remote.fetchProfile();
      if (fresh != _cache) {
        _cache     = fresh;
        _cacheTime = DateTime.now();
      }
    } catch (_) {}
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
    return info.objectKey;
  }

  @override
  Future<void> saveAvatarKey(String objectKey) =>
    remote.updateAvatarKey(objectKey);
}
