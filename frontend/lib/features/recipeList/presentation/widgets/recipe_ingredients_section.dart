// lib/features/recipeDetails/presentation/widgets/recipe_ingredients_section.dart
import 'package:flutter/material.dart';
import 'package:frontend/common/models/recipe/extended_ingredient.dart'; // Benötigt für ExtendedIngredient

class RecipeIngredientsSection extends StatelessWidget {
  final List<ExtendedIngredient>? ingredients;

  const RecipeIngredientsSection({super.key, required this.ingredients});

  @override
  Widget build(BuildContext context) {
    if (ingredients == null || ingredients!.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Ingredients:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const Divider(),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: ingredients!.map((ing) => Padding(
            padding: const EdgeInsets.only(bottom: 4.0),
            child: Text(
              '• ${ing.original}',
              style: const TextStyle(fontSize: 16),
            ),
          )).toList(),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}