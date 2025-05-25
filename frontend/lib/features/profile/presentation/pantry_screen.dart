// lib/screens/pantry_screen.dart

import 'package:flutter/material.dart';

class PantryScreen extends StatelessWidget {
  const PantryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock-Daten
    final items = [
      'Tomaten',
      'Bananen',
      'Haferflocken',
      'Eier',
      'Milch',
      'Reis',
      'Olivenöl',
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Mein Vorratsschrank')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        separatorBuilder: (_, __) => const Divider(),
        itemBuilder: (ctx, i) {
          return ListTile(
            leading: const Icon(Icons.food_bank),
            title: Text(items[i]),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () {
                // TODO: Item entfernen
              },
            ),
          );
        },
      ),
    );
  }
}
