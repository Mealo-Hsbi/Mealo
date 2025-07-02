import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/core/providers/app_providers.dart';

class RecipeAdItem extends StatelessWidget {
  const RecipeAdItem({super.key});

  @override
  Widget build(BuildContext context) {
    final premiumProvider = Provider.of<PremiumProvider>(context);
    if (premiumProvider.isPremium) {
      return const SizedBox.shrink();
    }
    return Card(
      color: Colors.amber[100],
      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Row(
          children: [
            Icon(Icons.campaign, size: 48, color: Colors.orange),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                'This is a sponsored ad!\nUpgrade to premium to remove ads.',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 