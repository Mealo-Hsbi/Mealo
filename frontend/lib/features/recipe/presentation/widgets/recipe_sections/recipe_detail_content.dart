// lib/features/recipeDetails/presentation/widgets/recipe_detail_content.dart

import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart'; // NICHT MEHR BENÖTIGT
// import 'package:provider/provider.dart'; // NICHT MEHR BENÖTIGT

import 'package:frontend/common/models/recipe/recipe_details.dart';
import 'package:frontend/common/models/recipe/extended_ingredient.dart';

// Importe für Ihre anderen Sektionen
import 'package:frontend/features/recipe/presentation/widgets/recipe_sections/recipe_health_score_section.dart';
import 'package:frontend/features/recipe/presentation/widgets/recipe_sections/recipe_ingredients_section.dart';
import 'package:frontend/features/recipe/presentation/widgets/recipe_sections/recipe_instructions_section.dart';
import 'package:frontend/features/recipe/presentation/widgets/recipe_sections/recipe_nutrition_section.dart';
import 'package:frontend/features/recipe/presentation/widgets/recipe_sections/recipe_summary_section.dart';
import 'package:frontend/features/recipe/presentation/widgets/recipe_sections/servings_adjuster_section.dart';
import 'package:url_launcher/url_launcher.dart';

// NEU: Import der ausgelagerten Interaktions-Sektion
import 'package:frontend/features/recipe/presentation/widgets/recipe_sections/recipe_interaction_section.dart';

// // Diese Imports sind jetzt im RecipeInteractionSection
// import 'package:frontend/features/recipeDetails/presentation/widgets/recipe_rating_widget.dart';
// import 'package:frontend/features/recipe/presentation/provider/favorite_notifier.dart';
// import 'package:frontend/features/auth/presentation/providers/auth_state_provider.dart';
// import 'package:frontend/features/recipe/domain/entities/recipe.dart';
// import 'package:frontend/core/utils/extensions.dart';


// ZURÜCK ZU StatelessWidget, da keine direkten Riverpod/Provider-Abhängigkeiten mehr
class RecipeDetailContent extends StatefulWidget { // Korrektur: Kein ConsumerStatefulWidget mehr
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
  State<RecipeDetailContent> createState() => _RecipeDetailContentState();
}

class _RecipeDetailContentState extends State<RecipeDetailContent> {
  int _currentServings = 0;

  @override
  void initState() {
    super.initState();
    // Initialisiere _currentServings, falls recipeDetails direkt verfügbar sind
    if (widget.recipeDetails != null) {
      _currentServings = widget.recipeDetails!.servings ?? 0;
    }
    // Die Logik für _currentUserId und Favoriten ist jetzt in RecipeInteractionSection!
  }

  @override
  void didUpdateWidget(covariant RecipeDetailContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.recipeDetails != oldWidget.recipeDetails && widget.recipeDetails != null) {
      setState(() {
        _currentServings = widget.recipeDetails!.servings ?? 0;
      });
      // Die Logik für Favoriten-Neuladen ist jetzt in RecipeInteractionSection!
    }
  }

  void _onServingsChanged(int newServings) {
    setState(() {
      _currentServings = newServings;
    });
  }

  List<ExtendedIngredient>? _getAdjustedIngredients() {
    if (widget.recipeDetails == null || widget.recipeDetails!.extendedIngredients == null || _currentServings <= 0) {
      return null;
    }

    final originalServings = widget.recipeDetails!.servings ?? 1;
    if (originalServings <= 0) return widget.recipeDetails!.extendedIngredients;

    if (_currentServings == originalServings) {
      return widget.recipeDetails!.extendedIngredients;
    }

    final adjustmentFactor = _currentServings / originalServings;

    return widget.recipeDetails!.extendedIngredients!.map((ingredient) {
      double? adjustedAmount;
      if (ingredient.amount != null) {
        adjustedAmount = ingredient.amount! * adjustmentFactor;
      }
      return ExtendedIngredient(
        id: ingredient.id,
        aisle: ingredient.aisle,
        image: ingredient.image,
        consistency: ingredient.consistency,
        name: ingredient.name,
        original: ingredient.original,
        originalName: ingredient.originalName,
        amount: adjustedAmount,
        unit: ingredient.unit,
        meta: ingredient.meta,
      );
    }).toList();
  }


  @override
  Widget build(BuildContext context) {
    final Color contentBackgroundColor = Theme.of(context).colorScheme.surface;
    final List<ExtendedIngredient>? adjustedIngredients = _getAdjustedIngredients();

    return SliverList(
      delegate: SliverChildListDelegate([
        Container(
          color: contentBackgroundColor,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    widget.initialName,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                  ),
                ),
                Text(
                  widget.initialPlace,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
                ),
                const SizedBox(height: 16),
                if (widget.isLoading)
                  const Center(child: CircularProgressIndicator())
                else if (widget.errorMessage != null)
                  Center(
                    child: Text(
                      widget.errorMessage!,
                      style: const TextStyle(color: Colors.red, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  )
                else if (widget.recipeDetails != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // NEU: Einfach das ausgelagerte Widget einfügen!
                      RecipeInteractionSection(
                        recipeDetails: widget.recipeDetails!,
                      ),
                      const SizedBox(height: 20),

                      _buildInfoGrid(context, widget.recipeDetails!),
                      const SizedBox(height: 20),

                      if (widget.recipeDetails!.servings != null && widget.recipeDetails!.servings! > 0)
                        ServingsAdjusterSection(
                          originalServings: widget.recipeDetails!.servings!,
                          currentServings: _currentServings,
                          onServingsChanged: _onServingsChanged,
                        ),
                      const SizedBox(height: 20),

                      RecipeHealthScoreSection(healthScore: widget.recipeDetails!.healthScore),
                      RecipeSummarySection(summary: widget.recipeDetails!.summary),
                      RecipeIngredientsSection(
                        ingredients: adjustedIngredients,
                        originalServings: widget.recipeDetails!.servings,
                        currentServings: _currentServings,
                      ),
                      RecipeInstructionsSection(analyzedInstructions: widget.recipeDetails!.analyzedInstructions),
                      RecipeNutritionSection(recipeDetails: widget.recipeDetails!),
                      const SizedBox(height: 40),
                    ],
                  )
                else
                  const Center(child: Text('No recipe details available.', style: TextStyle(color: Colors.grey))),
              ],
            ),
          ),
        ),
      ]),
    );
  }

  // Hilfsmethode zur Erstellung des Info-Grids (unverändert)
  Widget _buildInfoGrid(BuildContext context, RecipeDetails details) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 1,
        mainAxisExtent: 70,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
      ),
      itemCount: (details.readyInMinutes != null ? 1 : 0) +
          (details.servings != null ? 1 : 0) +
          ((details.sourceUrl != null) ? 1 : 0),
      itemBuilder: (context, index) {
        // --- KORREKTUR: Initialisiere alle lokalen Variablen ---
        IconData icon = Icons.info_outline; // Default icon
        String label = 'N/A'; // Default label
        String value = ''; // Default value
        VoidCallback? onTap; // Nullable, default is null

        int currentCount = 0;

        if (details.readyInMinutes != null) {
          if (index == currentCount) {
            icon = Icons.access_time;
            label = 'Ready in:';
            value = '${details.readyInMinutes} minutes';
            onTap = null;
          }
          currentCount++;
        }

        if (details.servings != null) {
          if (index == currentCount) {
            icon = Icons.people_alt;
            label = 'Servings:';
            value = '${details.servings}';
            onTap = null;
          }
          currentCount++;
        }

        if (details.sourceUrl != null) {
          if (index == currentCount) {
            icon = Icons.open_in_new;
            label = 'View Source';
            value = '';
            onTap = () {
              final url = details.sourceUrl;
              if (url != null) {
                launchUrl(Uri.parse(url));
              }
            };
          }
          currentCount++;
        }

        // If the index doesn't correspond to any valid item based on the details,
        // we return an empty SizedBox. This handles cases where itemCount
        // might not perfectly align with the conditional checks, or if some
        // details are null.
        if (index >= currentCount) {
          return const SizedBox.shrink();
        }

        return Card(
          elevation: 0,
          color: colorScheme.secondary.withOpacity(0.1),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  Icon(icon, color: colorScheme.primary, size: 24),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          label,
                          style: textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        if (value.isNotEmpty)
                          Text(
                            value,
                            style: textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}