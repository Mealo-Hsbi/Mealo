import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../onboarding/presentation/screens/onboarding_screen.dart';
import 'about-mealo_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context, rootNavigator: true).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Edit Profile'),
            onTap: () {/* TODO: EditProfileScreen */},
          ),
          ListTile(
            leading: const Icon(Icons.lock),
            title: const Text('Change Password'),
            onTap: () {/* TODO */},
          ),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Notifications'),
            onTap: () {/* TODO */},
          ),
          ListTile(
            leading: const Icon(Icons.tune),
            title: const Text('Start Onboarding'),
            onTap: () {
              Navigator.of(context, rootNavigator: true).push(
              MaterialPageRoute(
                fullscreenDialog: true, // optional: Slide von unten
                builder: (_) => const OnboardingScreen(),
              ),
            );
            },
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('About Mealo'),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const AboutMealoScreen(),
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Sign Out'),
            onTap: () => _signOut(context),
          ),
        ],
      ),
    );
  }
}
