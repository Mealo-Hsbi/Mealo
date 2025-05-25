// lib/screens/achievements_overview_screen.dart

import 'package:flutter/material.dart';

class AchievementsOverviewScreen extends StatelessWidget {
  const AchievementsOverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock-Achievements mit Erfüllungsstatus
    final achievements = [
      {'icon': Icons.book,    'label': '10 Rezepte',           'done': true},
      {'icon': Icons.star,    'label': '100 Likes',            'done': true},
      {'icon': Icons.kitchen, 'label': '50 Zutaten gerettet',  'done': false},
      {'icon': Icons.camera,  'label': '5 Fotos hochgeladen',  'done': false},
      {'icon': Icons.share,   'label': '10 Mal geteilt',       'done': true},
    ];

    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Alle Achievements')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: achievements.length,
        separatorBuilder: (_, __) => const Divider(),
        itemBuilder: (ctx, i) {
          final a = achievements[i];
          final done = a['done'] as bool;
          return ListTile(
            leading: Icon(a['icon'] as IconData, color: done ? theme.colorScheme.primary : Colors.grey),
            title: Text(a['label'] as String),
            trailing: done
                ? Icon(Icons.check_circle, color: theme.colorScheme.primary)
                : Icon(Icons.radio_button_unchecked, color: Colors.grey),
          );
        },
      ),
    );
  }
}
