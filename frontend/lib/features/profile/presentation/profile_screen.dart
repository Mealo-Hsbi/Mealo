import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../services/api_client.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ApiClient _api = ApiClient();
  late Future<String> _nameFuture;

  @override
  void initState() {
    super.initState();
    _nameFuture = _fetchName();
  }

  Future<String> _fetchName() async {
    try {
      final response = await _api.getUser();
      final data = response.data['user'] as Map<String, dynamic>;
      // Nimm 'name' falls gesetzt, sonst Email
      return data['name'] as String? ?? data['email'] as String;
    } catch (e) {
      debugPrint('Error fetching name: $e');
      return 'Unbekannt';
    }
  }

  Future<void> _signOut(BuildContext ctx) async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(ctx, rootNavigator: true).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final fbUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Abmelden',
            onPressed: () => _signOut(context),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Profilbild aus Firebase, falls vorhanden
            if (fbUser?.photoURL != null)
              CircleAvatar(
                radius: 48,
                backgroundImage: NetworkImage(fbUser!.photoURL!),
              ),
            const SizedBox(height: 16),
            // Name per FutureBuilder aus dem Backend holen
            FutureBuilder<String>(
              future: _nameFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return const Text('Fehler beim Laden');
                } else {
                  return Text(
                    'Mein Name: ${snapshot.data}',
                    style: const TextStyle(fontSize: 18),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
