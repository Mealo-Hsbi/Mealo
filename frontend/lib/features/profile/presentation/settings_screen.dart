// lib/screens/settings_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    // Zurück bis zum Root (z. B. Login-Screen)
    Navigator.of(context, rootNavigator: true).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Einstellungen')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profil bearbeiten'),
            onTap: () {/* TODO: EditProfileScreen */},
          ),
          ListTile(
            leading: const Icon(Icons.lock),
            title: const Text('Passwort ändern'),
            onTap: () {/* TODO */},
          ),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Benachrichtigungen'),
            onTap: () {/* TODO */},
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('Über Mealo'),
            onTap: () {/* TODO */},
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Abmelden'),
            onTap: () => _signOut(context),
          ),
        ],
      ),
    );
  }
}
