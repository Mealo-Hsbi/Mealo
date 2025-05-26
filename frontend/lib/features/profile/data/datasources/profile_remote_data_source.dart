// lib/features/profile/data/datasources/profile_remote_data_source.dart

import '/services/api_client.dart';
import '../../domain/entities/upload_info.dart';

abstract class ProfileRemoteDataSource {
  Future<UploadInfo> getAvatarUploadInfo(String filename, String contentType);
  Future<String> getAvatarDownloadUrl(String objectKey);
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final ApiClient apiClient;
  ProfileRemoteDataSourceImpl(this.apiClient);

  @override
  Future<UploadInfo> getAvatarUploadInfo(String filename, String contentType) async {
    final res = await apiClient.post('/media/upload-url', data: {
      'filename': filename,
      'contentType': contentType,
    });
    return UploadInfo.fromJson(res.data as Map<String, dynamic>);
  }

  @override
  Future<String> getAvatarDownloadUrl(String objectKey) async {
    final res = await apiClient.get('/media/download-url?objectKey=$objectKey');
    return (res.data as Map<String, dynamic>)['downloadUrl'] as String;
  }
}
