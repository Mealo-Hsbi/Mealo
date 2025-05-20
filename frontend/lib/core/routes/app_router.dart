import 'package:flutter/material.dart';
import 'package:frontend/core/routes/navigation_tabs.dart';

class AppNavigationShell extends StatefulWidget {
  const AppNavigationShell({super.key});

  @override
  State<AppNavigationShell> createState() => _AppNavigationShellState();
}

class _AppNavigationShellState extends State<AppNavigationShell> {
  int _currentIndex = 0;
  final List<int> _tabHistory = [0];
  final Map<int, List<int>> _tabStacks = {};
  final List<GlobalKey<NavigatorState>> _navigatorKeys = [];

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < getAppTabs(0).length; i++) {
      _tabStacks[i] = [];
      _navigatorKeys.add(GlobalKey<NavigatorState>());
    }
  }

  Future<bool> _onWillPop() async {
    final currentNavigator = _navigatorKeys[_currentIndex].currentState!;

    if (currentNavigator.canPop()) {
      currentNavigator.pop();
      _tabStacks[_currentIndex]?.removeLast();
      return false;
    } else if (_tabHistory.length > 1) {
      setState(() {
        _tabHistory.removeLast();
        _currentIndex = _tabHistory.last;
      });
      return false;
    }
    return true;
  }

  void _onTabTapped(int index) {
    if (index != _currentIndex) {
      setState(() {
        _currentIndex = index;
        _tabHistory.add(index);
      });
    // } else if (index == 0) {  // 0 is the home tab TODO: maybe implement this function for all tabs and maybe use smth. like enums for the indexes
    //   _navigatorKeys[index].currentState?.popUntil((route) => route.isFirst);
    //   _tabStacks[index]?.clear();
    // }

    } else {
      _navigatorKeys[index].currentState?.popUntil((route) => route.isFirst);
      _tabStacks[index]?.clear();
    }
  }

  Widget _buildOffstageNavigator(int index) {
    return Offstage(
      offstage: _currentIndex != index,
      child: Navigator(
        key: _navigatorKeys[index],
        onGenerateRoute: (settings) {
          return MaterialPageRoute(
            builder: (_) => getAppTabs(_currentIndex)[index],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: Stack(
          children: getAppTabs(_currentIndex).asMap().entries.map((entry) {
            int index = entry.key;
            return _buildOffstageNavigator(index);
          }).toList(),
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onTabTapped,
          items: appBottomNavigationBarItems,
        ),
      ),
    );
  }
}