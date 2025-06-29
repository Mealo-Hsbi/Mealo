import 'package:flutter/material.dart';
import 'package:provider/provider.dart' as provider; // Import the provider package Consumer

import 'package:frontend/common/models/recipe/recipe_details.dart';
import 'package:frontend/common/models/recipe/extended_ingredient.dart';

// Import for other sections
import 'package:frontend/features/recipe/presentation/widgets/recipe_sections/recipe_health_score_section.dart';
import 'package:frontend/features/recipe/presentation/widgets/recipe_sections/recipe_ingredients_section.dart';
import 'package:frontend/features/recipe/presentation/widgets/recipe_sections/recipe_instructions_section.dart';
import 'package:frontend/features/recipe/presentation/widgets/recipe_sections/recipe_nutrition_section.dart';
import 'package:frontend/features/recipe/presentation/widgets/recipe_sections/recipe_summary_section.dart';
import 'package:frontend/features/recipe/presentation/widgets/recipe_sections/servings_adjuster_section.dart';
import 'package:url_launcher/url_launcher.dart';

// Import the extracted interaction section
import 'package:frontend/features/recipe/presentation/widgets/recipe_sections/recipe_interaction_section.dart';
import 'package:frontend/features/recipe/presentation/provider/rating_notifier.dart'; // Import your RatingNotifier

class RecipeDetailContent extends StatefulWidget { // Stays StatefulWidget
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
  State<RecipeDetailContent> createState() => _RecipeDetailContentState(); // Stays State
}

class _RecipeDetailContentState extends State<RecipeDetailContent> { // Stays State
  int _currentServings = 0;

  @override
  void initState() {
    super.initState();
    if (widget.recipeDetails != null) {
      _currentServings = widget.recipeDetails!.servings ?? 0;
    }

    // Initialize average rating in the notifier when recipe details are first available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && widget.recipeDetails != null) {
        // Use Provider.of to access the notifier
        final ratingNotifier = provider.Provider.of<RatingNotifier>(context, listen: false);
        ratingNotifier.setInitialAverageRating(widget.recipeDetails!.averageRating ?? 0.0);
        ratingNotifier.setInitialRatingCount(widget.recipeDetails!.ratingCount ?? 0);
        // No notifyListeners in these setInitial methods, as the Consumer below
        // will handle the first render, and subsequent updates will come from
        // addOrUpdateRecipeRating calling notifyListeners.
      }
    });
  }

  @override
  void didUpdateWidget(covariant RecipeDetailContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.recipeDetails != oldWidget.recipeDetails && widget.recipeDetails != null) {
      setState(() {
        _currentServings = widget.recipeDetails!.servings ?? 0;
      });
      // Update average rating in the notifier if recipeDetails change
      final ratingNotifier = provider.Provider.of<RatingNotifier>(context, listen: false);
      ratingNotifier.setInitialAverageRating(widget.recipeDetails!.averageRating ?? 0.0);
      ratingNotifier.setInitialRatingCount(widget.recipeDetails!.ratingCount ?? 0);
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.initialName,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                      ),
                      // Display average rating dynamically using provider's Consumer
                      if (widget.recipeDetails != null && !widget.isLoading && widget.errorMessage == null)
                        provider.Consumer<RatingNotifier>( // Use provider's Consumer here
                          builder: (context, ratingNotifier, child) {
                            final double displayAverageRating = ratingNotifier.averageRating;
                            final int displayRatingCount = ratingNotifier.ratingCount;

                            if (ratingNotifier.isLoading && displayAverageRating == 0.0 && displayRatingCount == 0) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                // child: Text(
                                //   'Loading ratings...',
                                //   style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                                // ),
                              );
                            }

                            return Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Row(
                                children: [
                                  // Display stars
                                  ...List.generate(5, (index) {
                                    return Icon(
                                      index < displayAverageRating.round() ? Icons.star : Icons.star_border,
                                      color: Colors.amber[700],
                                      size: 18,
                                    );
                                  }),
                                  const SizedBox(width: 6),
                                  Flexible(
                                    child: Text(
                                      displayRatingCount > 0 ? '(${displayRatingCount} ratings)' : 'No ratings yet.',
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                    ],
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
                      const SizedBox(height: 16),
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

  // Helper method to build the info grid (unchanged)
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
        IconData icon = Icons.info_outline;
        String label = 'N/A';
        String value = '';
        VoidCallback? onTap;

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