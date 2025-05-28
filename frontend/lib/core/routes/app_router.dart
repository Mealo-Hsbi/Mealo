// lib/core/routes/app_router.dart

import 'package:flutter/material.dart';
import 'package:frontend/features/auth/presentation/auth_gate.dart';
import 'package:frontend/core/routes/navigation_tabs.dart';
import 'package:frontend/providers/current_tab_provider.dart';
import 'package:provider/provider.dart';

/// Der zentrale Router für named routes.
/// "/" → AuthGate (Login/Register oder Home)
/// alle anderen → AppNavigationShell (deine Tab-Navigation)
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


/// Deine bestehende Tab-Navigation (unverändert)
class AppNavigationShell extends StatefulWidget {
  final int initialIndex;

  const AppNavigationShell({super.key, this.initialIndex = 0});

  @override
  State<AppNavigationShell> createState() => _AppNavigationShellState();
}

class _AppNavigationShellState extends State<AppNavigationShell> {
  // int _currentIndex = 0;
  final List<int> _tabHistory = [0];
  final Map<int, List<int>> _tabStacks = {};
  final List<GlobalKey<NavigatorState>> _navigatorKeys = [];

  @override
  void initState() {
    super.initState();

    _tabHistory.add(context.read<CurrentTabProvider>().currentIndex);
    for (int i = 0; i < getAppTabs(0).length; i++) {
      _tabStacks[i] = [];
      _navigatorKeys.add(GlobalKey<NavigatorState>());
    }
  }

  Future<bool> _onWillPop() async {
    final int currentTab = context.read<CurrentTabProvider>().currentIndex; // Aktuellen Tab vom Provider holen
    final currentNavigator = _navigatorKeys[currentTab].currentState!;
    
    if (currentNavigator.canPop()) {
      currentNavigator.pop();
      _tabStacks[currentTab]?.removeLast();
      return false;
    } else if (_tabHistory.length > 1) {
      setState(() {
        _tabHistory.removeLast();
        // Setze den _currentIndex im Provider auf den vorherigen Tab in der Historie
        context.read<CurrentTabProvider>().setCurrentIndex(_tabHistory.last);
      });
      return false;
    }
    return true;
  }

  void _onTabTapped(int index) {
    final int previousIndex = context.read<CurrentTabProvider>().currentIndex; // Vorherigen Index holen
    if (index != previousIndex) {
      // Setze den neuen Index im Provider
      context.read<CurrentTabProvider>().setCurrentIndex(index);
      setState(() { // setState hier, um _tabHistory zu aktualisieren
        _tabHistory.add(index);
      });
    } else {
      // Wenn auf den bereits aktiven Tab getippt wird, pop to root
      _navigatorKeys[index].currentState?.popUntil((route) => route.isFirst);
      _tabStacks[index]?.clear();
    }
  }

  Widget _buildOffstageNavigator(int index, int currentActiveIndex) { // currentActiveIndex als Parameter
    return Offstage(
      offstage: currentActiveIndex != index, // Vergleich mit dem aktiven Index vom Provider
      child: Navigator(
        key: _navigatorKeys[index],
        onGenerateRoute: (settings) {
          return MaterialPageRoute(
            builder: (_) => getAppTabs(index)[index], // Hier den Index für den Tab übergeben
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Schau auf den CurrentTabProvider, um den aktuellen Index zu bekommen
    final int currentIndex = context.watch<CurrentTabProvider>().currentIndex;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: Stack(
          children: getAppTabs(currentIndex).asMap().entries.map((entry) {
            int index = entry.key;
            return _buildOffstageNavigator(index, currentIndex); // currentIndex an die Methode übergeben
          }).toList(),
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: currentIndex, // Nutze den currentIndex vom Provider
          onTap: _onTabTapped, // Deine onTap Logik
          items: appBottomNavigationBarItems,
        ),
      ),
    );
  }
}