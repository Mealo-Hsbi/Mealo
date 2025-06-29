// main.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

import 'package:frontend/core/themes/app_theme.dart';
import 'package:frontend/features/auth/presentation/auth_gate.dart';
import 'package:frontend/core/routes/app_router.dart';
import 'package:frontend/core/config/app_config.dart';
import 'package:frontend/core/config/environment.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:frontend/core/providers/app_providers.dart'; // Importiere deine Provider-Konfiguration
// Importe für LoginScreen/RegisterScreen, falls direkt in routes verwendet
import 'package:frontend/features/auth/presentation/login_screen.dart';
import 'package:frontend/features/auth/presentation/register_screen.dart';


import 'firebase_options.dart';

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

Future<void> _initializeAppServices() async {
  WidgetsFlutterBinding.ensureInitialized();

  const isProd = bool.fromEnvironment('dart.vm.product');
  await dotenv.load(fileName: isProd ? '.env.prod' : '.env.dev');

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FirebaseAnalytics.instance.logAppOpen();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);

  AppConfig.init(Environment.dev);
}

void main() {
  _initializeAppServices().then((_) {
    runApp(
      // NEU: ProviderScope umschließt den MultiProvider
      ProviderScope( // <-- HIER IST DER PROVIDERSCOPE
        child: MultiProvider(
          providers: AppProviders.providers, // Hier kommt die saubere Liste von Providern her
          child: const MyApp(),
        ),
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
      home: const AuthGate(), // AuthGate wird dann intern den currentUserIdProvider nutzen
      routes: {
        '/login': (_) => const LoginScreen(),
        '/register': (_) => const RegisterScreen(),
        '/home': (_) => const AppNavigationShell(),
      },
      navigatorObservers: [observer],
      scaffoldMessengerKey: scaffoldMessengerKey,
    );
  }
}