import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: TabNavigationExample(),
    );
  }
}

class TabNavigationExample extends StatefulWidget {
  @override
  _TabNavigationExampleState createState() => _TabNavigationExampleState();
}

class _TabNavigationExampleState extends State<TabNavigationExample> {
  int _currentIndex = 0;
  final List<int> _tabHistory = [0];
  final Map<int, List<int>> _tabStacks = {0: [], 1: []}; // Added history per tab

  final _navigatorKeys = [
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
  ];

  Future<bool> _onWillPop() async {
    final currentNavigator = _navigatorKeys[_currentIndex].currentState!;
    
    // Check if the current tab has a deeper stack
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
    return true; // will exit app
  }

  void _onTabTapped(int index) {
    if (index != _currentIndex) {
      setState(() {
        _currentIndex = index;
        _tabHistory.add(index);
      });
    }
  }

  Widget _buildOffstageNavigator(int index) {
    return Offstage(
      offstage: _currentIndex != index,
      child: Navigator(
        key: _navigatorKeys[index],
        onGenerateRoute: (settings) {
          return MaterialPageRoute(
            builder: (_) => index == 0 ? HomePage() : SearchPage(),
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
          children: [
            _buildOffstageNavigator(0),
            _buildOffstageNavigator(1),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onTabTapped,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          ],
        ),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Home')),
      body: Center(
        child: ElevatedButton(
          child: Text('Go to Detail'),
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => DetailPage(title: 'Home Detail'),
            ));
          },
        ),
      ),
    );
  }
}

class SearchPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Search')),
      body: Center(
        child: ElevatedButton(
          child: Text('Go to Detail'),
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => DetailPage(title: 'Search Detail'),
            ));
          },
        ),
      ),
    );
  }
}

class DetailPage extends StatelessWidget {
  final String title;

  const DetailPage({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text('Detail page')),
    );
  }
}
