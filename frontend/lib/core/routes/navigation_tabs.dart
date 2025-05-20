import 'package:flutter/material.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/favorites/presentation/favorites_screen.dart';
import '../../features/explore/exploreScreen.dart';
import '../../features/camera/camera_screen.dart';

const List<Widget> appTabs = [
  HomeScreen(),
  ExploreScreen(),
  CameraScreen(), // Dummy Screen for the third tab
  FavoritesScreen(), // Dummy Screen for the fourth tab
  FavoritesScreen(), // Dummy Screen for the fourth tab
];

const List<BottomNavigationBarItem> appBottomNavigationBarItems = [
  BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
  BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
  BottomNavigationBarItem(icon: Icon(Icons.camera), label: 'Camera'),
  BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Favorites'),
  BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
];