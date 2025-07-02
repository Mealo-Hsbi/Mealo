import 'package:firebase_auth/firebase_auth.dart';

class UserModel {
  final String uid;
  final String? email;
  final String? photoUrl;
  final bool hasCompletedOnboarding;

  UserModel({
    required this.uid,
    this.email,
    this.photoUrl,
    this.hasCompletedOnboarding = false,
  });

  factory UserModel.fromFirebase(User user, {bool hasCompletedOnboarding = false}) {
    return UserModel(
      uid: user.uid,
      email: user.email,
      photoUrl: user.photoURL,
      hasCompletedOnboarding: hasCompletedOnboarding,
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['firebase_uid'] ?? json['uid'],
      email: json['email'],
      photoUrl: json['avatar_url'] ?? json['photoUrl'],
      hasCompletedOnboarding: json['has_completed_onboarding'] ?? false,
    );
  }
}