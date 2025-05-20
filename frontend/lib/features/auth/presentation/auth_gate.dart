import 'package:flutter/material.dart';
import 'package:frontend/features/auth/data/auth_repository.dart';
import 'package:frontend/features/auth/domain/user_model.dart';
import 'package:frontend/features/auth/presentation/login_screen.dart';
import 'package:frontend/features/auth/presentation/register_screen.dart';
import 'package:frontend/features/home/presentation/home_screen.dart';

/// Dieses Widget entscheidet, ob wir eingeloggt sind oder in den Auth-Flow springen.
class AuthGate extends StatelessWidget {
  final AuthRepository _repo = AuthRepository();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<UserModel?>(
      stream: _repo.user,
      builder: (context, snapshot) {
        // noch am Laden?
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // eingeloggt → Home
        if (snapshot.hasData && snapshot.data != null) {
          return const HomeScreen();
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
