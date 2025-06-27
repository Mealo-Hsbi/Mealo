// lib/features/recipeDetails/presentation/widgets/recipe_info_row.dart
import 'package:flutter/material.dart';

class RecipeInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const RecipeInfoRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).primaryColor, size: 20),
          const SizedBox(width: 8),
          Text('$label: ', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Flexible( // Added Flexible to prevent overflow if value is too long
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
              overflow: TextOverflow.ellipsis, // Add ellipsis for overflow
            ),
          ),
        ],
      ),
    );
  }
}