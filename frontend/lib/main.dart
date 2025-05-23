// main.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Für SystemChrome
import 'package:frontend/core/routes/app_router.dart';
import 'package:frontend/core/themes/app_theme.dart';
import 'package:frontend/core/config/app_config.dart';
import 'package:frontend/core/config/environment.dart';

// Eine neue Funktion zur Initialisierung von App-Services
Future<void> _initializeAppServices() async {
  // Stellt sicher, dass die Flutter-Engine bereit ist, bevor native Services aufgerufen werden
  WidgetsFlutterBinding.ensureInitialized();

  // Beschränkt die App auf den Hochformat-Modus
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Setzt den Stil der System-UI-Overlays (z.B. Uhrzeit, Batterieanzeige).
  // Dies kann auch pro Screen mit AnnotatedRegion<SystemUiOverlayStyle> überschrieben werden,
  // aber hier setzt du einen globalen Standard.
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark); // Oder .light, je nach globalem Standard

  // Initialisiert die App-Konfiguration
  AppConfig.init(Environment.dev);
}

void main() {
  // Rufe die Initialisierungsfunktion auf und starte die App, sobald sie abgeschlossen ist
  _initializeAppServices().then((_) {
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: AppNavigationShell(),
    );
  }
}