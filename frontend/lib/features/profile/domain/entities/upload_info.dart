// lib/features/profile/domain/entities/upload_info.dart

class UploadInfo {
  final String uploadUrl;
  final String objectKey;
  UploadInfo({required this.uploadUrl, required this.objectKey});

  factory UploadInfo.fromJson(Map<String, dynamic> json) {
    return UploadInfo(
      uploadUrl: json['uploadUrl'] as String,
      objectKey: json['objectKey'] as String,
    );
  }
}
