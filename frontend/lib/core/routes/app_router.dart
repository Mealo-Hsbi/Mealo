// lib/core/routes/app_router.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Für SystemNavigator.pop()
import 'package:frontend/features/auth/presentation/auth_gate.dart';
import 'package:frontend/core/routes/navigation_tabs.dart'; // Nur für appBottomNavigationBarItems
import 'package:frontend/providers/current_tab_provider.dart';
import 'package:provider/provider.dart';

// Importiere alle deine Tab-Screens hier direkt
import 'package:frontend/features/home/presentation/home_screen.dart';
import 'package:frontend/features/favorites/presentation/favorites_screen.dart';
import 'package:frontend/features/explore/exploreScreen.dart';
import 'package:frontend/features/camera/presentation/screens/camera_screen.dart';
import 'package:frontend/features/profile/presentation/profile_screen.dart';

/// Der zentrale Router für named routes.
class AppRouter {
  Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(
          builder: (_) => AuthGate(),
          settings: settings,
        );
      default:
        return MaterialPageRoute(
          builder: (_) => const AppNavigationShell(),
          settings: settings,
        );
    }
  }
}

/// Deine bestehende Tab-Navigation
class AppNavigationShell extends StatefulWidget {
  final int initialIndex;

  const AppNavigationShell({super.key, this.initialIndex = 0});

  @override
  State<AppNavigationShell> createState() => _AppNavigationShellState();
}

class _AppNavigationShellState extends State<AppNavigationShell> {
  final List<GlobalKey<NavigatorState>> _navigatorKeys = [];
  late final List<Widget> _persistentTabNavigators; // Hält die Navigatoren persistent
  final List<int> _tabHistory = [0]; // Behalte die Historie für den Back-Button

  @override
  void initState() {
    super.initState();

    // Initialisiere die Navigator-Keys für jeden Tab
    for (int i = 0; i < appBottomNavigationBarItems.length; i++) {
      _navigatorKeys.add(GlobalKey<NavigatorState>());
    }

    // Initialisiere die Liste der Navigatoren einmalig in initState.
    // Jeder Navigator enthält seinen Tab-Screen.
    _persistentTabNavigators = List.generate(appBottomNavigationBarItems.length, (index) {
      // Wrapper für den Screen, damit er seine eigene Navigationshistorie hat
      return Navigator(
        key: _navigatorKeys[index], // Wichtig: Der GlobalKey bleibt für diesen Navigator konstant
        onGenerateRoute: (settings) {
          Widget screen;
          // Erstelle die Screens je nach Index
          switch (index) {
            case 0:
              screen = const HomeScreen();
              break;
            case 1:
              screen = const ExploreScreen();
              break;
            case 2:
              // Das ist der Kamera-Tab.
              // Hier übergeben wir den isVisible-Prop basierend darauf,
              // ob dieser Navigator der aktuell aktive im IndexedStack ist.
              // Wir müssen hier das `context.watch` verwenden, damit der Builder
              // bei Änderungen des Providers neu gebaut wird und das `isVisible` korrekt setzt.
              screen = Builder(
                builder: (BuildContext innerContext) {
                  final int currentActiveTab = innerContext.watch<CurrentTabProvider>().currentIndex;
                  return CameraScreen(isVisible: currentActiveTab == index);
                },
              );
              break;
            case 3:
              screen = const FavoritesScreen();
              break;
            case 4:
              screen = const ProfileScreen();
              break;
            default:
              screen = const Text('Error: Unknown Tab');
          }
          return MaterialPageRoute(builder: (_) => screen, settings: settings);
        },
      );
    });

    // Füge den initialen Index zur Historie hinzu, falls nicht schon 0
    if (widget.initialIndex != _tabHistory.last) {
      _tabHistory.add(widget.initialIndex);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Schau auf den CurrentTabProvider, um den aktuellen Index zu bekommen
    final int currentIndex = context.watch<CurrentTabProvider>().currentIndex;

    return PopScope( // Modernes PopScope statt WillPopScope
      canPop: false, // Standardmäßiges Zurückgehen verhindern
      onPopInvoked: (didPop) {
        if (didPop) return; // Wenn System-Pop stattgefunden hat, ignorieren

        // Versuche, den aktuellen Navigator zu poppen
        final currentNavigator = _navigatorKeys[currentIndex].currentState;
        if (currentNavigator != null && currentNavigator.canPop()) {
          currentNavigator.pop();
        } else {
          // Wenn der aktuelle Tab nicht gepoppt werden kann,
          // versuche, im Tab-Verlauf zurückzugehen
          if (_tabHistory.length > 1) {
            setState(() {
              _tabHistory.removeLast();
              context.read<CurrentTabProvider>().setCurrentIndex(_tabHistory.last);
            });
          } else {
            // Wenn keine Tab-Historie mehr, App schließen
            SystemNavigator.pop();
          }
        }
      },
      child: Scaffold(
        body: IndexedStack(
          index: currentIndex, // IndexedStack zeigt das Kind an diesem Index an
          children: _persistentTabNavigators, // Die einmalig erstellten Navigatoren
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: (index) {
            final int previousIndex = context.read<CurrentTabProvider>().currentIndex;
            if (index != previousIndex) {
              context.read<CurrentTabProvider>().setCurrentIndex(index);
              // Aktualisiere die _tabHistory, wenn der Tab gewechselt wird
              setState(() {
                _tabHistory.add(index);
              });
            } else {
              // Beim erneuten Tippen auf den aktiven Tab: pop to root des Navigators
              _navigatorKeys[index].currentState?.popUntil((route) => route.isFirst);
            }
          },
          items: appBottomNavigationBarItems,
        ),
      ),
    );
  }
}