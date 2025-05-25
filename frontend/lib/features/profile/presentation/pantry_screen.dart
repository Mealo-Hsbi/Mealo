import 'package:flutter/material.dart';

class PantryScreen extends StatelessWidget {
  const PantryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock data
    final items = [
      'Tomatoes',
      'Bananas',
      'Oatmeal',
      'Eggs',
      'Milk',
      'Rice',
      'Olive oil',
    ];

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(title: const Text('My Pantry')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (ctx, i) {
          return ListTile(
            leading: const Icon(Icons.food_bank),
            title: Text(items[i]),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () {
                // TODO: remove item
              },
            ),
          );
        },
      ),
    );
  }
}
