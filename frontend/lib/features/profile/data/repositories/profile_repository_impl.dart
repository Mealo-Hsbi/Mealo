import 'package:dio/dio.dart';
import '../../domain/entities/upload_info.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_data_source.dart';
import '/services/api_client.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remote;
  final ApiClient apiClient;

  ProfileRepositoryImpl(this.remote, this.apiClient);

  @override
  Future<String> fetchAvatarUrl(String objectKey) =>
    remote.getAvatarDownloadUrl(objectKey);

  @override
  Future<UploadInfo> getUploadInfo(String filename, String contentType) =>
    remote.getAvatarUploadInfo(filename, contentType);

  @override
  Future<String> uploadAvatar(
      String filename, List<int> bytes, String contentType) async {
    // 1) Hol dir Upload-URL und objectKey
    final info = await remote.getAvatarUploadInfo(filename, contentType);

    // 2) Raw-PUT über ApiClient.put(...) durchführen
    await apiClient.put(
      info.uploadUrl,               // absolute URL mit allen Query-Parametern
      data: bytes,                  // rohes Byte-Array
      options: Options(             // aus dio: import 'package:dio/dio.dart';
        headers: {'Content-Type': contentType},
      ),
    );

    // 3) Gib objectKey zurück
    return info.objectKey;
  }
}
