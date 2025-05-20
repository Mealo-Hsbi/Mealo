import 'package:flutter/material.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/favorites/presentation/favorites_screen.dart';

const List<Widget> appTabs = [
  HomeScreen(),
  FavoritesScreen(),
];

const List<BottomNavigationBarItem> appBottomNavigationBarItems = [
  BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
  BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Favorites'),
];