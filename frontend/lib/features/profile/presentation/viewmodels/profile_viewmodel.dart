// lib/features/profile/presentation/viewmodels/profile_viewmodel.dart

import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

import '../../domain/entities/profile_dto.dart';
import '../../domain/usecases/get_profile.dart';
import '../../domain/usecases/upload_avatar.dart';

class ProfileViewModel extends ChangeNotifier {
  final GetProfile   _getProfile;
  final UploadAvatar _uploadAvatar;

  ProfileDto? profile;
  bool       isLoading = false;

  ProfileViewModel(this._getProfile, this._uploadAvatar);

  Future<void> loadProfile() async {
    isLoading = true;
    notifyListeners();

    final fresh = await _getProfile();
    // nur neu rodern, wenn sich tatsächlich etwas ändert
    if (profile == null || profile! != fresh) {
      profile = fresh;
      notifyListeners();
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> pickAndUploadAvatar() async {
    final picker = ImagePicker();
    final file   = await picker.pickImage(source: ImageSource.gallery);
    if (file == null) return;

    isLoading = true;
    notifyListeners();

    final bytes    = await file.readAsBytes();
    final filename = 'avatars/${DateTime.now().millisecondsSinceEpoch}.png';

    // 1) Bild hochladen und Key in DB speichern
    final objectKey = await _uploadAvatar(filename, bytes, 'image/png');
    // 2) Profil neu laden, um die neue avatarUrl zu bekommen
    final updated = await _getProfile();
    profile = updated;
    notifyListeners();

    isLoading = false;
    notifyListeners();
  }
}
