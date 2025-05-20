// lib/features/auth/presentation/auth_gate.dart

import 'package:flutter/material.dart';
import 'package:frontend/features/auth/data/auth_repository.dart';
import 'package:frontend/features/auth/domain/user_model.dart';
import 'package:frontend/features/auth/presentation/login_screen.dart';
import 'package:frontend/features/auth/presentation/register_screen.dart';
import 'package:frontend/core/routes/app_router.dart'; // oder direkt AppNavigationShell importieren

class AuthGate extends StatelessWidget {
  // kein `const` mehr, weil wir _repo initialisieren:
  AuthGate({Key? key}) : super(key: key);

  final AuthRepository _repo = AuthRepository();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<UserModel?>(
      stream: _repo.user,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // eingeloggt → unsere Tab-Shell statt Material NavigationBar
        if (snapshot.hasData && snapshot.data != null) {
          return const AppNavigationShell();
        }

        // nicht eingeloggt → eigener Navigator für Login/Register
        return Navigator(
          initialRoute: '/login',
          onGenerateRoute: (settings) {
            late Widget page;
            switch (settings.name) {
              case '/register':
                page = const RegisterScreen();
                break;
              case '/login':
              default:
                page = const LoginScreen();
            }
            return MaterialPageRoute(
              builder: (_) => page,
              settings: settings,
            );
          },
        );
      },
    );
  }
}
