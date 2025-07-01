import 'package:flutter/foundation.dart';
import 'package:frontend/features/profile/domain/repositories/profile_repository.dart';
import 'package:image_picker/image_picker.dart';

import '../../domain/entities/profile_dto.dart';
import '../../domain/usecases/get_profile.dart';
import '../../domain/usecases/upload_avatar.dart';
import 'package:mime/mime.dart';
import 'dart:io';

class ProfileViewModel extends ChangeNotifier {
  final GetProfile _getProfile;
  final UploadAvatar _uploadAvatar;
  final ProfileRepository _profileRepository;

  ProfileDto? profile;
  bool isLoading = false;
  String? errorMessage;

  ProfileViewModel(this._getProfile, this._uploadAvatar, this._profileRepository);

  Future<void> loadProfile() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      print('[ProfileViewModel] Lade Profil...');
      final fresh = await _getProfile();
      print('[ProfileViewModel] Profil geladen: ' + fresh.toString());
      if (profile == null || profile!.avatarUrl != fresh.avatarUrl) {
        profile = fresh;
        notifyListeners();
      }
    } catch (e, st) {
      errorMessage = 'Fehler beim Laden des Profils: '
          '\n${e.toString()}';
      print('[ProfileViewModel] ERROR beim Laden des Profils: $e\n$st');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> pickAndUploadAvatar() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery);
    if (file == null) return;

    await uploadAvatar(File(file.path));
  }

  Future<void> uploadAvatar(File file) async {
  isLoading = true;
  notifyListeners();

  final bytes = await file.readAsBytes();
  final mimeType = lookupMimeType(file.path) ?? 'image/png';
  final filename = 'avatars/${DateTime.now().millisecondsSinceEpoch}.png';

  await _uploadAvatar(filename, bytes, mimeType);

  // Cache löschen
  _profileRepository.invalidateCache();

  // ⏳ Verzögerung, damit der Server die neue avatarUrl zurückgeben kann
  await Future.delayed(const Duration(milliseconds: 500));

  // Profil neu laden
  await loadProfile();

  isLoading = false;
  notifyListeners();
}

}
