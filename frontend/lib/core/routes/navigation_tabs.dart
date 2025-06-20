import 'package:flutter/material.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/favorites/presentation/favorites_screen.dart';
import '../../features/explore/exploreScreen.dart';
import '../../features/camera/presentation/screens/camera_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';

List<Widget> getAppTabs(int currentIndex) {
  return [
    const HomeScreen(),
    const ExploreScreen(),
    CameraScreen(isVisible: currentIndex == 2),
    const FavoritesScreen(),
    ProfileScreen(),
  ];
}

const List<BottomNavigationBarItem> appBottomNavigationBarItems = [
  BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
  BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
  BottomNavigationBarItem(icon: Icon(Icons.camera), label: 'Camera'),
  BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Favorites'),
  BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
];