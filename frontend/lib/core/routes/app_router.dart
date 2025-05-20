// lib/core/routes/app_router.dart

import 'package:flutter/material.dart';
import 'package:frontend/features/auth/presentation/auth_gate.dart';
import 'package:frontend/features/home/presentation/home_screen.dart';
import 'package:frontend/features/favorites/presentation/favorites_screen.dart';

class AppRouter {
  Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      // 1) Root-Route: AuthGate entscheidet, ob Login/Register oder Home
      case '/':
        return MaterialPageRoute(
          builder: (_) => AuthGate(),
          settings: settings,
        );

      // 2) Nach dem Login wollen wir direkt auf den HomeScreen
      case '/home':
        return MaterialPageRoute(
          builder: (_) => const HomeScreen(),
          settings: settings,
        );

      // 3) Direkter Favorites-Screen
      case '/favorites':
        return MaterialPageRoute(
          builder: (_) => const FavoritesScreen(),
          settings: settings,
        );

      // 4) Alle anderen Routen
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Seite nicht gefunden')),
          ),
          settings: settings,
        );
    }
  }
}
