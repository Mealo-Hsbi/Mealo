import 'package:flutter/material.dart';
import 'core/routes/app_router.dart';
import 'core/themes/app_theme.dart';

void main() {
  runApp(const MealoApp());
}

class MealoApp extends StatelessWidget {
  const MealoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mealo',
      theme: AppTheme.lightTheme,
      initialRoute: '/',
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}
