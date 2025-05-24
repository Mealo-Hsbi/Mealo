// lib/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '/services/api_client.dart';  // passe den Pfad an

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ApiClient _apiClient = ApiClient();
  late Future<String?> _emailFuture;

  @override
  void initState() {
    super.initState();
    // beim Aufruf des Tabs holen wir uns einmal die Email aus /users/me
    _emailFuture = _apiClient
        .getUser()
        .then((resp) {
          // erwartet: { user: { uid: ..., email: "xyz@..." } }
          final data = resp.data['user'] as Map<String, dynamic>?;
          return data?['email'] as String?;
        })
        .catchError((e) {
          // bei Fehlern einfach null zurückgeben
          return null;
        });
  }

  Future<void> _signOut(BuildContext ctx) async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(ctx, rootNavigator: true).popUntil((r) => r.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

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
        child: FutureBuilder<String?>(
          future: _emailFuture,
          builder: (context, snap) {
            Widget child;
            if (snap.connectionState == ConnectionState.waiting) {
              child = const CircularProgressIndicator();
            } else if (snap.hasError) {
              child = Text('Fehler: ${snap.error}');
            } else {
              // wenn API-Call geklappt hat, zeige die zurückgelieferte Email
              final email = snap.data;
              child = Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (user?.photoURL != null)
                    CircleAvatar(
                      radius: 48,
                      backgroundImage: NetworkImage(user!.photoURL!),
                    ),
                  const SizedBox(height: 16),
                  Text(
                    email ??
                        user?.displayName ??
                        user?.email ??
                        'Unbekannt',
                    style: const TextStyle(fontSize: 18),
                  ),
                ],
              );
            }
            return child;
          },
        ),
      ),
    );
  }
}
