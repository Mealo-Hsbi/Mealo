import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: Colors.green,
    primarySwatch: Colors.green,
    visualDensity: VisualDensity.adaptivePlatformDensity,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.green,
      foregroundColor: Colors.white,
      elevation: 0,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white, // Hintergrundfarbe der Leiste
      selectedItemColor: Colors.green, // Farbe des ausgewählten Items
      unselectedItemColor: Colors.grey, // Farbe der nicht ausgewählten Items
      selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold), // Stil des ausgewählten Labels
      unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal), // Stil des nicht ausgewählten Labels
      showSelectedLabels: true, // Labels für ausgewählte Items anzeigen
      showUnselectedLabels: false, // Labels für nicht ausgewählte Items ausblenden
      type: BottomNavigationBarType.fixed, // Oder BottomNavigationBarType.shifting für animierte Farbe
    ),
  );
}
