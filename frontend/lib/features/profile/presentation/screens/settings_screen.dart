import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../onboarding/presentation/screens/onboarding_screen.dart';
import 'about-mealo_screen.dart';
import 'edit_profile_screen.dart';
import 'preferences_settings_screen.dart';
import 'package:frontend/services/api_client.dart';
import 'package:provider/provider.dart';
import 'package:frontend/core/providers/app_providers.dart';

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
            onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const EditProfileScreen()),
            );
          },
          ),
          ListTile(
            leading: const Icon(Icons.lock),
            title: const Text('Change Password'),
            onTap: () {/* TODO */},
          ),
          ListTile(
            leading: const Icon(Icons.tune),
            title: const Text('Preferences'),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const PreferencesSettingsScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.quiz),
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
          // --- Premium kaufen Bereich ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Card(
              color: Colors.amber.shade50,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.workspace_premium, color: Colors.amber, size: 32),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FutureBuilder<bool>(
                            future: ApiClient().getPremiumStatus(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return const Text('Lade Premium-Status...', style: TextStyle(fontWeight: FontWeight.bold));
                              }
                              final isPremium = snapshot.data == true;
                              return Text(
                                isPremium
                                  ? 'Du bist Premium-Nutzer!'
                                  : 'Premium kaufen',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    FutureBuilder<bool>(
                      future: ApiClient().getPremiumStatus(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const SizedBox.shrink();
                        }
                        final isPremium = snapshot.data == true;
                        final premiumProvider = Provider.of<PremiumProvider>(context, listen: false);
                        return Text(
                          isPremium
                            ? 'Keine Werbung & du unterstützt die Weiterentwicklung.'
                            : 'Mit Premium genießt du Mealo werbefrei und unterstützt die Weiterentwicklung.',
                          style: TextStyle(color: Colors.grey.shade800),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    Consumer<PremiumProvider>(
                      builder: (context, premiumProvider, _) {
                        final isPremium = premiumProvider.isPremium;
                        if (isPremium) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Premium ist aktiv. Danke für deine Unterstützung!', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  icon: const Icon(Icons.cancel, color: Colors.white),
                                  label: const Text('Premium kündigen'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.redAccent,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  onPressed: () async {
                                    final cancelled = await ApiClient().cancelPremium();
                                    if (cancelled && context.mounted) {
                                      await premiumProvider.loadPremiumStatus();
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Premium wurde gekündigt.')),
                                      );
                                    } else if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Kündigung fehlgeschlagen.')),
                                      );
                                    }
                                  },
                                ),
                              ),
                            ],
                          );
                        }
                        return SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.workspace_premium, color: Colors.white),
                            label: const Text('Premium kaufen'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.amber.shade700,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            onPressed: () async {
                              final bought = await ApiClient().buyPremium();
                              if (bought && context.mounted) {
                                await premiumProvider.loadPremiumStatus();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Danke für deinen Kauf! Du bist jetzt Premium-Nutzer.')),
                                );
                              } else if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Kauf fehlgeschlagen. Bitte versuche es erneut.')),
                                );
                              }
                            },
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
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
