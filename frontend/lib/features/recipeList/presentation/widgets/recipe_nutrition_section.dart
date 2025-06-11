// lib/features/recipeDetails/presentation/widgets/recipe_nutrition_section.dart
import 'package:flutter/material.dart';
import 'package:frontend/common/models/recipe/recipe_details.dart';
import 'dart:ui'; // Für ImageFilter.blur

class RecipeNutritionSection extends StatelessWidget {
  final RecipeDetails recipeDetails;

  const RecipeNutritionSection({super.key, required this.recipeDetails});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> nutrientsToShow = [];

    if (recipeDetails.calories != null) {
      nutrientsToShow.add({
        'name': 'Calories',
        'amount': recipeDetails.calories,
        'unit': 'kcal',
      });
    }
    if (recipeDetails.protein != null) {
      nutrientsToShow.add({
        'name': 'Protein',
        'amount': recipeDetails.protein,
        'unit': 'g',
      });
    }
    if (recipeDetails.fat != null) {
      nutrientsToShow.add({
        'name': 'Fat',
        'amount': recipeDetails.fat,
        'unit': 'g',
      });
    }
    if (recipeDetails.carbs != null) {
      nutrientsToShow.add({
        'name': 'Carbohydrates',
        'amount': recipeDetails.carbs,
        'unit': 'g',
      });
    }
    if (recipeDetails.sugar != null) {
      nutrientsToShow.add({
        'name': 'Sugar',
        'amount': recipeDetails.sugar,
        'unit': 'g',
        'percentOfDailyNeeds': null,
      });
    }

    if (nutrientsToShow.isEmpty) {
      return const SizedBox.shrink();
    }

    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Nutritional Information',
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onBackground,
            ),
          ),
          Text(
            '(per serving)',
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),

          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 2.1,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: nutrientsToShow.length,
            itemBuilder: (context, index) {
              final nutrient = nutrientsToShow[index];
              final String name = nutrient['name'];
              final double amount = nutrient['amount'];
              final String unit = nutrient['unit'];
              final double? percentOfDailyNeeds = nutrient['percentOfDailyNeeds'];

              return ClipRRect( // Wichtig für die abgerundeten Ecken des Blur-Effekts
                borderRadius: BorderRadius.circular(8),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0), // Der eigentliche Glas-Effekt
                  child: Container(
                    // Hintergrundfarbe für den Glas-Effekt
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceVariant.withOpacity(0.1), // Sehr leicht transparent
                      borderRadius: BorderRadius.circular(8),
                      // Optional: Ein leichter Rand, um die Kontur zu definieren
                      border: Border.all(color: colorScheme.onSurface.withOpacity(0.05)),
                    ),
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          name,
                          style: textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          name == "Calories" ? '${amount.toStringAsFixed(0)} kcal' :
                          '${amount.toStringAsFixed(amount.truncateToDouble() == amount ? 0 : 1)}$unit',
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
                          ),
                        ),
                        if (percentOfDailyNeeds != null)
                          Text(
                            '(${percentOfDailyNeeds.toStringAsFixed(0)}% DV)',
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}