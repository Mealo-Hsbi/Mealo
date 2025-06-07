// lib/features/recipeDetails/presentation/widgets/recipe_detail_content.dart
import 'package:flutter/material.dart';
import 'package:frontend/common/models/recipe/recipe_details.dart';
import 'package:frontend/features/recipeList/presentation/widgets/recipe_health_score_section.dart';
import 'package:frontend/features/recipeList/presentation/widgets/recipe_info_row.dart';
import 'package:frontend/features/recipeList/presentation/widgets/recipe_ingredients_section.dart';
import 'package:frontend/features/recipeList/presentation/widgets/recipe_instructions_section.dart';
import 'package:frontend/features/recipeList/presentation/widgets/recipe_nutrition_section.dart';
import 'package:frontend/features/recipeList/presentation/widgets/recipe_source_link.dart';
import 'package:frontend/features/recipeList/presentation/widgets/recipe_summary_section.dart'; // Pfad korrigiert


class RecipeDetailContent extends StatelessWidget {
  final String initialName;
  final String initialPlace;
  final bool isLoading;
  final String? errorMessage;
  final RecipeDetails? recipeDetails;

  const RecipeDetailContent({
    super.key,
    required this.initialName,
    required this.initialPlace,
    required this.isLoading,
    this.errorMessage,
    this.recipeDetails,
  });

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildListDelegate([
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Haupttitel (unterhalb des Bildes)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  initialName,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              // Ort/Land
              Text(
                initialPlace,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 16),

              // Ladeindikator oder Fehlermeldung
              if (isLoading)
                const Center(child: CircularProgressIndicator())
              else if (errorMessage != null)
                Center(
                  child: Text(
                    errorMessage!,
                    style: const TextStyle(color: Colors.red, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                )
              else if (recipeDetails != null)
                // Hier werden die schon ausgelagerten Sektionen verwendet
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Servings und ReadyInMinutes
                    RecipeInfoRow(
                      icon: Icons.people_alt,
                      label: 'Servings',
                      value: recipeDetails!.servings?.toString() ?? 'N/A',
                    ),
                    RecipeInfoRow(
                      icon: Icons.access_time,
                      label: 'Ready in',
                      value: '${recipeDetails!.readyInMinutes ?? 'N/A'} min',
                    ),
                    const SizedBox(height: 20),

                    RecipeNutritionSection(recipeDetails: recipeDetails!),
                    RecipeHealthScoreSection(healthScore: recipeDetails!.healthScore),
                    RecipeIngredientsSection(ingredients: recipeDetails!.extendedIngredients),
                    RecipeInstructionsSection(analyzedInstructions: recipeDetails!.analyzedInstructions),
                    RecipeSummarySection(summary: recipeDetails!.summary),
                    RecipeSourceLink(sourceUrl: recipeDetails!.sourceUrl, sourceName: recipeDetails!.sourceName),
                    const SizedBox(height: 40),
                  ],
                )
              else
                const Center(child: Text('No recipe details available.', style: TextStyle(color: Colors.grey))),
            ],
          ),
        ),
      ]),
    );
  }
}