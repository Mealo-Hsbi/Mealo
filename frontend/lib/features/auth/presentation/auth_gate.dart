import 'package:flutter/material.dart';
import 'package:frontend/features/auth/data/auth_repository.dart';
import 'package:frontend/features/auth/domain/user_model.dart';
import 'package:frontend/features/auth/presentation/login_screen.dart';
import 'package:frontend/core/routes/app_router.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return StreamBuilder<UserModel?>(
      stream: AuthRepository().user,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasData) {
          // Eingeloggt → direkt zur Hauptnavigation
          return const AppNavigationShell();
        } else {
          // Nicht eingeloggt → Login-Screen
          return const LoginScreen();
        }
      },
    );
  }
}
