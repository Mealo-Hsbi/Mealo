import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import '../../domain/usecases/get_avatar.dart';
import '../../domain/usecases/upload_avatar.dart';

/// ChangeNotifier für den Profile-Screen
class ProfileViewModel extends ChangeNotifier {
  final GetAvatarUrl _getAvatarUrl;
  final UploadAvatar _uploadAvatar;

  String? avatarUrl;
  bool isLoading = false;

  ProfileViewModel(this._getAvatarUrl, this._uploadAvatar);

  Future<void> loadAvatar(String objectKey) async {
    isLoading = true;
    notifyListeners();

    avatarUrl = await _getAvatarUrl(objectKey);

    isLoading = false;
    notifyListeners();
  }

  Future<void> pickAndUploadAvatar() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery);
    if (file == null) return;

    isLoading = true;
    notifyListeners();

    final bytes = await file.readAsBytes();
    final filename =
        'avatars/${DateTime.now().millisecondsSinceEpoch}.png';
    final objectKey = await _uploadAvatar(
      filename,
      bytes,
      'image/png',
    );
    avatarUrl = await _getAvatarUrl(objectKey);

    isLoading = false;
    notifyListeners();
  }
}
