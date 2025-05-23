import 'package:firebase_auth/firebase_auth.dart';

class UserModel {
  final String uid;
  final String? email;
  final String? photoUrl;

  UserModel({
    required this.uid,
    this.email,
    this.photoUrl,
  });

  factory UserModel.fromFirebase(User user) {
    return UserModel(
      uid: user.uid,
      email: user.email,
      photoUrl: user.photoURL,
    );
  }
}