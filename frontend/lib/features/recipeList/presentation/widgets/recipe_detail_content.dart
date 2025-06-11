import 'package:flutter/material.dart';
import 'package:frontend/common/models/recipe/recipe_details.dart';
import 'package:frontend/features/recipeList/presentation/widgets/recipe_health_score_section.dart';
import 'package:frontend/features/recipeList/presentation/widgets/recipe_info_row.dart';
import 'package:frontend/features/recipeList/presentation/widgets/recipe_ingredients_section.dart';
import 'package:frontend/features/recipeList/presentation/widgets/recipe_instructions_section.dart';
import 'package:frontend/features/recipeList/presentation/widgets/recipe_nutrition_section.dart';
import 'package:frontend/features/recipeList/presentation/widgets/recipe_source_link.dart';
import 'package:frontend/features/recipeList/presentation/widgets/recipe_summary_section.dart';

import 'package:frontend/common/models/recipe/extended_ingredient.dart';
import 'package:frontend/features/recipeList/presentation/widgets/servings_adjuster_section.dart';
import 'package:url_launcher/url_launcher.dart';


// Ändere von StatelessWidget zu StatefulWidget
class RecipeDetailContent extends StatefulWidget {
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
  int _currentServings = 0; // Zustand für die aktuelle Portionsanzahl

  @override
  void didUpdateWidget(covariant RecipeDetailContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Initialisiere _currentServings, sobald recipeDetails geladen wurden
    if (widget.recipeDetails != oldWidget.recipeDetails && widget.recipeDetails != null) {
      setState(() {
        _currentServings = widget.recipeDetails!.servings ?? 0;
      });
    }
  }

  // Callback-Funktion zum Aktualisieren der Portionsanzahl
  void _onServingsChanged(int newServings) {
    setState(() {
      _currentServings = newServings;
    });
  }

  // Hilfsfunktion zum Anpassen der Zutatenmengen
  List<ExtendedIngredient>? _getAdjustedIngredients() {
    if (widget.recipeDetails == null || widget.recipeDetails!.extendedIngredients == null || _currentServings <= 0) {
      return null;
    }

    final originalServings = widget.recipeDetails!.servings ?? 1; // Standard auf 1, falls null
    if (originalServings <= 0) return widget.recipeDetails!.extendedIngredients; // Keine Anpassung möglich

    if (_currentServings == originalServings) {
      return widget.recipeDetails!.extendedIngredients; // Keine Anpassung nötig
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
        amount: adjustedAmount, // Angepasster Betrag
        unit: ingredient.unit,
        meta: ingredient.meta,
      );
    }).toList();
  }


  @override
  Widget build(BuildContext context) {
    final Color contentBackgroundColor = Theme.of(context).colorScheme.surface;

    // Hole die angepassten Zutaten
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
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  widget.initialPlace,
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[600],
                  ),
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
                      // Servings und ReadyInMinutes (als einzelne Info-Boxen wie im Mockup)
                      // Ersetze RecipeInfoRow durch die Grid-Darstellung im Mockup
                      _buildInfoGrid(context, widget.recipeDetails!),
                      const SizedBox(height: 20),

                      // NEUE SEKTION: Portion Adjuster (wenn originalServings > 0)
                      if (widget.recipeDetails!.servings != null && widget.recipeDetails!.servings! > 0)
                        ServingsAdjusterSection(
                          originalServings: widget.recipeDetails!.servings!,
                          currentServings: _currentServings,
                          onServingsChanged: _onServingsChanged,
                        ),
                      const SizedBox(height: 20),


                      RecipeHealthScoreSection(healthScore: widget.recipeDetails!.healthScore),

                      // Zutaten mit angepassten Mengen übergeben
                      RecipeSummarySection(summary: widget.recipeDetails!.summary),
                      RecipeIngredientsSection(
                        ingredients: adjustedIngredients,
                        originalServings: widget.recipeDetails!.servings,
                        currentServings: _currentServings,
                      ),
                      RecipeInstructionsSection(analyzedInstructions: widget.recipeDetails!.analyzedInstructions),
                      RecipeNutritionSection(recipeDetails: widget.recipeDetails!),
                      // RecipeSourceLink(sourceUrl: widget.recipeDetails!.sourceUrl, sourceName: widget.recipeDetails!.sourceName),
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

  // Hilfsmethode zur Erstellung des Info-Grids
  Widget _buildInfoGrid(BuildContext context, RecipeDetails details) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero, // Kein Padding um das Grid selbst
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 1, // Startet mit 1 Spalte für kleine Screens
        mainAxisExtent: 70, // Feste Höhe für die Elemente, um Überläufe zu vermeiden
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
      ),
      itemCount: (details.readyInMinutes != null ? 1 : 0) +
          (details.servings != null ? 1 : 0) +
          ((details.sourceUrl != null) ? 1 : 0),
      itemBuilder: (context, index) {
        Widget content;
        IconData icon;
        String label;
        String value;

        if (index == 0 && details.readyInMinutes != null) {
          icon = Icons.access_time;
          label = 'Ready in:';
          value = '${details.readyInMinutes} minutes';
        } else if (index == (details.readyInMinutes != null ? 1 : 0) && details.servings != null) {
          icon = Icons.people_alt;
          label = 'Servings:';
          value = '${details.servings}';
        } else if (index == (details.readyInMinutes != null ? 1 : 0) + (details.servings != null ? 1 : 0) && (details.sourceUrl != null)) {
          icon = Icons.open_in_new; // ExternalLink
          label = 'View Source';
          value = ''; // Kein expliziter Wert, der Link ist das Wichtige
        } else {
          return const SizedBox.shrink(); // Sollte nicht passieren
        }

        return Card(
          elevation: 0,
          color: colorScheme.secondary.withOpacity(0.1), // Leichter Hintergrund
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: InkWell( // Macht die ganze Karte klickbar
            onTap: label == 'View Source'
                ? () {
                    final url = details.sourceUrl;
                    if (url != null) {
                      // TODO: Implement URL launch (z.B. mit url_launcher package)
                      launchUrl(Uri.parse(url));
                      
                    }
                  }
                : null,
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