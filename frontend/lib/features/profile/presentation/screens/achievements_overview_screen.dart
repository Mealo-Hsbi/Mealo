import 'package:flutter/material.dart';

class AchievementsOverviewScreen extends StatelessWidget {
  const AchievementsOverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock achievements with completion status
    final achievements = [
      {'icon': Icons.book,       'label': '10 Recipes',            'done': true},
      {'icon': Icons.star,       'label': '100 Likes',             'done': true},
      {'icon': Icons.kitchen,    'label': '50 Ingredients Saved',  'done': false},
      {'icon': Icons.camera_alt, 'label': '5 Photos Uploaded',      'done': false},
      {'icon': Icons.share,      'label': '10 Shares',             'done': true},
    ];

    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(title: const Text('All Achievements')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: achievements.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (ctx, i) {
          final a = achievements[i];
          final done = a['done'] as bool;
          return ListTile(
            leading: Icon(
              a['icon'] as IconData,
              color: done ? theme.colorScheme.primary : Colors.grey,
            ),
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
