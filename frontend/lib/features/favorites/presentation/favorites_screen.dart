import 'package:flutter/material.dart';
import 'package:frontend/features/favorites/presentation/detail_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Favorites')),
      body: Center(
        child: ElevatedButton(
          child: const Text('Go to Detail'),
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => const DetailScreen(),
            ));
          },
        ),
      ),
    );
  }
}
