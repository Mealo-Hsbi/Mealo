// lib/features/recipeDetails/presentation/widgets/recipe_health_score_section.dart
import 'package:flutter/material.dart';

class RecipeHealthScoreSection extends StatelessWidget {
  final double? healthScore;

  const RecipeHealthScoreSection({super.key, required this.healthScore});

  @override
  Widget build(BuildContext context) {
    if (healthScore == null) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Health Score:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const Divider(),
        Text('${healthScore!.toStringAsFixed(0)}%', style: const TextStyle(fontSize: 16)),
        const SizedBox(height: 20),
      ],
    );
  }
}