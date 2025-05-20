// lib/features/auth/presentation/auth_gate.dart

import 'package:flutter/material.dart';
import 'package:frontend/features/auth/data/auth_repository.dart';
import 'package:frontend/features/auth/domain/user_model.dart';
import 'package:frontend/features/auth/presentation/login_screen.dart';
import 'package:frontend/features/auth/presentation/register_screen.dart';
import 'package:frontend/core/routes/app_router.dart'; // oder direkt AppNavigationShell importieren

class AuthGate extends StatelessWidget {
  final _repo = AuthRepository();

  @override
  Widget build(BuildContext ctx) {
    return StreamBuilder<UserModel?>(
      stream: _repo.user,
      builder: (ctx, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snap.hasData) {
          // eingeloggt → Home-Route pushen, ersetzt Login
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(ctx).pushReplacementNamed('/home');
          });
          return const SizedBox.shrink();
        } else {
          // nicht eingeloggt → Login-Route (ersetzt ggf. AuthGate)
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(ctx).pushReplacementNamed('/login');
          });
          return const SizedBox.shrink();
        }
      },
    );
  }
}