// lib/features/recipeDetails/presentation/widgets/recipe_nutrition_section.dart
import 'package:flutter/material.dart';
import 'package:frontend/common/models/recipe/recipe_details.dart';

class RecipeNutritionSection extends StatelessWidget {
  final RecipeDetails recipeDetails;

  const RecipeNutritionSection({super.key, required this.recipeDetails});

  Widget _buildNutritionRow(String label, double? value, {String unit = ''}) {
    if (value == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          Text('$label: ', style: const TextStyle(fontSize: 16)),
          Text(
            '${value.toStringAsFixed(value.truncateToDouble() == value ? 0 : 1)}$unit',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (recipeDetails.calories == null &&
        recipeDetails.protein == null &&
        recipeDetails.fat == null &&
        recipeDetails.carbs == null &&
        recipeDetails.sugar == null) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ANGEPASSTER TITEL HIER:
        const Text(
          'Nutrition Information',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4), // Kleiner Abstand zwischen Überschrift und Zusatz
        Text(
          '(per serving)', // Zusatz in einer eigenen Zeile
          style: TextStyle(fontSize: 14, color: Colors.grey[600]), // Kleiner und heller
        ),
        const Divider(),
        _buildNutritionRow('Calories', recipeDetails.calories),
        _buildNutritionRow('Protein', recipeDetails.protein, unit: 'g'),
        _buildNutritionRow('Fat', recipeDetails.fat, unit: 'g'),
        _buildNutritionRow('Carbs', recipeDetails.carbs, unit: 'g'),
        _buildNutritionRow('Sugar', recipeDetails.sugar, unit: 'g'),
        const SizedBox(height: 20),
      ],
    );
  }
}