// lib/main.dart

import 'package:flutter/material.dart';
import 'package:frontend/core/themes/app_theme.dart';
import 'package:frontend/core/routes/app_router.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final router = AppRouter();

    return MaterialApp(
      title: 'Mealo',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,

      initialRoute: '/',
      onGenerateRoute: AppRouter().onGenerateRoute,

      // Entferne `home:` ganz, da wir jetzt über onGenerateRoute gehen
);
  }
}
