import 'package:flutter/material.dart';
import 'package:frontend/core/routes/app_router.dart';
import 'package:frontend/core/themes/app_theme.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: AppNavigationShell(),
    );
  }
}