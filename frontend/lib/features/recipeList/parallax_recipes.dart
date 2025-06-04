import 'package:flutter/material.dart';
import 'package:frontend/common/models/recipe.dart';
import 'package:frontend/features/recipeList/recipe_detail_screen.dart';

class ParallaxRecipes extends StatelessWidget {
  const ParallaxRecipes({
    super.key,
    required this.recipes,
    required this.currentSortOption, // NEU: currentSortOption hier hinzufügen
  });

  final List<Recipe> recipes;
  final String currentSortOption; // NEU: currentSortOption als Property

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final recipe in recipes)
          RecipeItem(
            imageUrl: recipe.imageUrl,
            name: recipe.name,
            country: recipe.place ?? '',
            readyInMinutes: recipe.readyInMinutes,
            servings: recipe.servings,
            // currentSortOption: currentSortOption, // <-- HIER WIRD ES WEITERGEGEBEN
            // calories: recipe.calories, // NEU: Kalorien
            // protein: recipe.protein,   // NEU: Protein
            // fat: recipe.fat,         // NEU: Fett
            // carbs: recipe.carbs,     // NEU: Kohlenhydrate
            // sugar: recipe.sugar,     // NEU: Zucker
            // healthScore: recipe.healthScore, // NEU: Healthiness Score
            // matchingIngredientsCount: recipe.matchingIngredientsCount, // NEU: Zutaten-Zähler
            // missingIngredientsCount: recipe.missingIngredientsCount,   // NEU: Zutaten-Zähler
          ),
      ],
    );
  }
}

@immutable
class RecipeItem extends StatelessWidget {
  RecipeItem({
    super.key,
    required this.imageUrl,
    required this.name,
    required this.country,
    this.readyInMinutes,
    this.servings,
    this.currentSortOption, // Aktuelle Sortieroption
    this.calories, // Kalorien
    this.protein,  // Protein
    this.fat,      // Fett
    this.carbs,    // Kohlenhydrate
    this.sugar,    // Zucker
    this.healthScore, // Healthiness Score
    this.matchingIngredientsCount, // Anzahl passender Zutaten
    this.missingIngredientsCount,  // Anzahl fehlender Zutaten
  });

  final String imageUrl;
  final String name;
  final String country;
  final int? readyInMinutes;
  final int? servings;
  final String? currentSortOption;
  final int? calories;
  final double? protein;
  final double? fat;
  final double? carbs;
  final double? sugar;
  final int? healthScore;
  final int? matchingIngredientsCount;
  final int? missingIngredientsCount;

  final GlobalKey _backgroundImageKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => RecipeDetailScreen(name: name, imageUrl: imageUrl, place: country),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              children: [
                _buildParallaxBackground(context),
                _buildGradient(),
                _buildTitleAndSubtitle(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildParallaxBackground(BuildContext context) {
    // ... (unverändert) ...
    // Code für _buildParallaxBackground bleibt gleich
    return Flow(
      delegate: ParallaxFlowDelegate(
        scrollable: Scrollable.of(context),
        listItemContext: context,
        backgroundImageKey: _backgroundImageKey,
      ),
      children: [
        (imageUrl.isNotEmpty)
            ? Image.network(
                imageUrl,
                key: _backgroundImageKey,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Image.asset(
                    'assets/placeholder_image.png',
                    key: _backgroundImageKey,
                    fit: BoxFit.cover,
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                          : null,
                      color: Colors.white,
                    ),
                  );
                },
              )
            : Image.asset(
                'assets/no_image_available.png',
                key: _backgroundImageKey,
                fit: BoxFit.cover,
              ),
      ],
    );
  }

  Widget _buildGradient() {
    // ... (unverändert) ...
    // Code für _buildGradient bleibt gleich
    return Positioned.fill(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: const [0.6, 0.95],
          ),
        ),
      ),
    );
  }

  Widget _buildTitleAndSubtitle() {
    String? secondaryInfoText;

    // Bestimme den Text für die sekundäre Informationszeile basierend auf der Sortierung
    // Zeige nur dann eine sekundäre Info, wenn sie nicht die Zubereitungszeit selbst ist
    if (currentSortOption != null && !currentSortOption!.startsWith('time_')) {
      switch (currentSortOption) {
        case 'relevance':
          // Optional: Könntest hier z.B. Popularität oder eine andere Standardinfo anzeigen,
          // falls du eine numerische Relevanz von Spoonacular bekämest.
          // Für jetzt lassen wir es leer.
          break;
        case 'popularity_desc':
          // Spoonacular hat keinen direkten "Popularity Score" in der Suche,
          // aber wenn du ihn später über Details abrufst, könntest du ihn hier anzeigen.
          // secondaryInfoText = 'Popularity: N/A'; // Beispiel
          break;
        case 'calories_asc':
        case 'calories_desc':
          if (calories != null) {
            secondaryInfoText = '${calories!.round()} kcal';
          }
          break;
        case 'healthiness_desc':
          if (healthScore != null) {
            secondaryInfoText = 'Health Score: $healthScore';
          }
          break;
        case 'protein_desc':
          if (protein != null) {
            secondaryInfoText = '${protein!.toStringAsFixed(1)}g Protein';
          }
          break;
        case 'fat_desc':
          if (fat != null) {
            secondaryInfoText = '${fat!.toStringAsFixed(1)}g Fett';
          }
          break;
        case 'carbs_desc':
          if (carbs != null) {
            secondaryInfoText = '${carbs!.toStringAsFixed(1)}g Kohlenhydrate';
          }
          break;
        case 'sugar_desc':
          if (sugar != null) {
            secondaryInfoText = '${sugar!.toStringAsFixed(1)}g Zucker';
          }
          break;
        // Für 'matchingIngredients_desc' kommt die Logik später, wenn das Backend die Zähler liefert
        // case 'matchingIngredients_desc':
        //   if (matchingIngredientsCount != null && missingIngredientsCount != null) {
        //     secondaryInfoText = '$matchingIngredientsCount / ${matchingIngredientsCount! + missingIngredientsCount!} Zutaten';
        //   }
        //   break;
      }
    }


    return Positioned(
      left: 20,
      right: 20,
      bottom: 20,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          // NEU: Row für Zubereitungszeit und sekundäre Info auf einer Zeile
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween, // Verteilt den Platz
            children: [
              // Zubereitungszeit (immer, wenn verfügbar)
              if (readyInMinutes != null)
                Text(
                  'Zubereitungszeit: $readyInMinutes Min.',
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
              
              // Sekundäre Info (wenn vorhanden und nicht die Zubereitungszeit selbst)
              if (secondaryInfoText != null)
                Text(
                  secondaryInfoText!,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
            ],
          ),
          // Optional: Servings, wenn du es doch anzeigen willst
          // if (servings != null)
          //   Text(
          //     'Portionen: $servings',
          //     style: const TextStyle(color: Colors.white, fontSize: 14),
          //   ),
        ],
      ),
    );
  }
}

// ... (ParallaxFlowDelegate bleibt unverändert) ...




class ParallaxFlowDelegate extends FlowDelegate {
  ParallaxFlowDelegate({
    required this.scrollable,
    required this.listItemContext,
    required this.backgroundImageKey,
  }) : super(repaint: scrollable.position);

  final ScrollableState scrollable;
  final BuildContext listItemContext;
  final GlobalKey backgroundImageKey;

  @override
  BoxConstraints getConstraintsForChild(int i, BoxConstraints constraints) {
    return BoxConstraints.tightFor(width: constraints.maxWidth);
  }

  @override
  void paintChildren(FlowPaintingContext context) {
    // Calculate the position of this list item within the viewport.
    final scrollableBox = scrollable.context.findRenderObject() as RenderBox;
    final listItemBox = listItemContext.findRenderObject() as RenderBox;
    final listItemOffset = listItemBox.localToGlobal(
      listItemBox.size.centerLeft(Offset.zero),
      ancestor: scrollableBox,
    );

    // Determine the percent position of this list item within the
    // scrollable area.
    final viewportDimension = scrollable.position.viewportDimension;
    final scrollFraction = (listItemOffset.dy / viewportDimension).clamp(
      0.0,
      1.0,
    );

    // Calculate the vertical alignment of the background
    // based on the scroll percent.
    final verticalAlignment = Alignment(0.0, scrollFraction * 2 - 1);

    // Convert the background alignment into a pixel offset for
    // painting purposes.
    final backgroundSize =
        (backgroundImageKey.currentContext!.findRenderObject() as RenderBox)
            .size;
    final listItemSize = context.size;
    final childRect = verticalAlignment.inscribe(
      backgroundSize,
      Offset.zero & listItemSize,
    );

    // Paint the background.
    context.paintChild(
      0,
      transform:
          Transform.translate(offset: Offset(0.0, childRect.top)).transform,
    );
  }

  @override
  bool shouldRepaint(ParallaxFlowDelegate oldDelegate) {
    return scrollable != oldDelegate.scrollable ||
        listItemContext != oldDelegate.listItemContext ||
        backgroundImageKey != oldDelegate.backgroundImageKey;
  }
}