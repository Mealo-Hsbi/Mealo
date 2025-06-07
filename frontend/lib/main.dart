// main.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/features/auth/presentation/login_screen.dart';
import 'package:frontend/features/auth/presentation/register_screen.dart';
import 'package:provider/provider.dart';

import 'package:frontend/core/themes/app_theme.dart';
import 'package:frontend/features/auth/presentation/auth_gate.dart';
// import 'package:frontend/features/auth/presentation/login_screen.dart'; // Nicht direkt nötig, wenn über routes
// import 'package:frontend/features/auth/presentation/register_screen.dart'; // Nicht direkt nötig, wenn über routes
import 'package:frontend/core/routes/app_router.dart'; // AppNavigationShell ist hier
import 'package:frontend/core/config/app_config.dart';
import 'package:frontend/core/config/environment.dart';

import 'package:frontend/core/providers/app_providers.dart'; // NEU: Importiere deine Provider-Konfiguration

import 'firebase_options.dart';


// Eine neue Funktion zur Initialisierung von App-Services
Future<void> _initializeAppServices() async {
  WidgetsFlutterBinding.ensureInitialized();

  const isProd = bool.fromEnvironment('dart.vm.product');
  await dotenv.load(fileName: isProd ? '.env.prod' : '.env.dev');

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FirebaseAnalytics.instance.logAppOpen();

  // Stellt sicher, dass die Flutter-Engine bereit ist, bevor native Services aufgerufen werden
  WidgetsFlutterBinding.ensureInitialized(); // Doppelt, aber schadet nicht. Erste ist für Firebase, zweite für Services.

  // Beschränkt die App auf den Hochformat-Modus
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Setzt den Stil der System-UI-Overlays (z.B. Uhrzeit, Batterieanzeige).
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);

  // Initialisiert die App-Konfiguration
  AppConfig.init(Environment.dev); // Verwende Environment.dev für die Entwicklung
}

void main() {
  _initializeAppServices().then((_) {
    runApp(
      MultiProvider(
        providers: AppProviders.providers, // Hier kommt die saubere Liste von Providern her
        child: const MyApp(),
      ),
    );
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static final FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  static final FirebaseAnalyticsObserver observer =
      FirebaseAnalyticsObserver(analytics: analytics);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mealo',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: const AuthGate(),
      routes: {
        '/login': (_) => const LoginScreen(), // Sicherstellen, dass diese Imports existieren
        '/register': (_) => const RegisterScreen(), // Sicherstellen, dass diese Imports existieren
        '/home': (_) => const AppNavigationShell(),
      },
      navigatorObservers: [observer],
    );
  }
}