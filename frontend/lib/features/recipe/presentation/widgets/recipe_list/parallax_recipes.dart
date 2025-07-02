import 'package:flutter/material.dart';
import 'package:frontend/common/models/recipe.dart';
import 'package:frontend/features/recipe/presentation/screens/recipe_detail_screen.dart'; // Ensure RecipeDetailScreen is imported
import 'package:flutter/services.dart'; // Import for rootBundle in RecipeItem
import 'package:frontend/features/recipe/presentation/widgets/recipe_ad_item.dart';

class ParallaxRecipes extends StatefulWidget {
  const ParallaxRecipes({
    super.key,
    required this.recipes,
    this.currentSortOption,
    required this.scrollController, // NOW REQUIRED: Receive the controller
    required this.isLoadingMore, // NOW REQUIRED: Receive loading state
    required this.hasMore, // NOW REQUIRED: Receive hasMore state
    this.showAds = true, // Add showAds flag, default true
    this.onRecipeRatingUpdated,
    this.onRecipeTap, // NEU
  });

  final List<Recipe> recipes;
  final String? currentSortOption;
  final ScrollController scrollController; // Store the received controller
  final bool isLoadingMore;
  final bool hasMore;
  final bool showAds; // Add showAds flag
  final void Function(int recipeIndex, double newRating, int newRatingCount)? onRecipeRatingUpdated;
  final void Function(Recipe recipe)? onRecipeTap; // NEU

  @override
  State<ParallaxRecipes> createState() => _ParallaxRecipesState();
}

class _ParallaxRecipesState extends State<ParallaxRecipes> {
  @override
  Widget build(BuildContext context) {
    final showAds = widget.showAds;
    final recipes = widget.recipes;
    // Calculate how many ads will be inserted
    int adCount = showAds ? (recipes.length ~/ 4) : 0;
    int totalCount = recipes.length + adCount + (widget.hasMore ? 1 : 0);

    return ListView.builder(
      controller: widget.scrollController,
      itemCount: totalCount,
      itemBuilder: (context, index) {
        // Loading indicator at the end
        if (index == totalCount - 1 && widget.hasMore) {
          return widget.isLoadingMore
              ? const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Center(child: CircularProgressIndicator()),
                )
              : const SizedBox.shrink();
        }

        if (showAds && (index + 1) % 5 == 0) {
          // Every 5th item (after 4 recipes) is an ad
          return const RecipeAdItem();
        }

        // Calculate the actual recipe index, skipping ads
        int numAdsBefore = showAds ? (index ~/ 5) : 0;
        int recipeIndex = index - numAdsBefore;
        final recipe = recipes[recipeIndex];
        return RecipeItem(
          id: recipe.id,
          internalId: recipe.internalId,
          isInternal: recipe.isInternal ?? false,
          imageUrl: recipe.imageUrl,
          name: recipe.name,
          country: recipe.place ?? '',
          readyInMinutes: recipe.readyInMinutes,
          servings: recipe.servings,
          currentSortOption: widget.currentSortOption,
          calories: recipe.calories,
          protein: recipe.protein,
          fat: recipe.fat,
          carbs: recipe.carbs,
          sugar: recipe.sugar,
          healthScore: recipe.healthScore,
          matchingIngredientsCount: recipe.usedIngredientCount,
          missingIngredientsCount: recipe.missedIngredientCount,
          averageRating: recipe.averageRating,
          ratingCount: recipe.ratingCount,
          onRatingUpdated: widget.onRecipeRatingUpdated == null ? null : (double newRating, int newRatingCount) {
            widget.onRecipeRatingUpdated!(recipeIndex, newRating, newRatingCount);
          },
          containsUserAllergens: recipe.containsUserAllergens,
          matchedAllergens: recipe.matchedAllergens,
          onRecipeTap: widget.onRecipeTap, // NEU
        );
      },
    );
  }
}

@immutable
class RecipeItem extends StatelessWidget {
  final void Function(double newRating, int newRatingCount)? onRatingUpdated;
  final bool? containsUserAllergens;
  final List<String>? matchedAllergens;
  final void Function(Recipe recipe)? onRecipeTap; // NEU
  RecipeItem({
    super.key,
    this.id,
    this.internalId, // Optional: Interne ID für eigene Rezepte
    this.isInternal = false, // Default: false, wenn nicht angegeben
    required this.imageUrl,
    required this.name,
    required this.country,
    this.readyInMinutes,
    this.servings,
    this.currentSortOption,
    this.calories,
    this.protein,
    this.fat,
    this.carbs,
    this.sugar,
    this.healthScore,
    this.matchingIngredientsCount,
    this.missingIngredientsCount,
    this.averageRating,
    this.ratingCount,
    this.onRatingUpdated,
    this.containsUserAllergens,
    this.matchedAllergens,
    this.onRecipeTap, // NEU
  });

  final int? id;
  final String? internalId; // Optional: Interne ID für eigene Rezepte
  final bool isInternal; // Default: false, wenn nicht angegeben
  final String imageUrl;
  final String name;
  final String country;
  final int? readyInMinutes;
  final int? servings;
  final String? currentSortOption;
  final double? calories;
  final double? protein;
  final double? fat;
  final double? carbs;
  final double? sugar;
  final int? healthScore;
  final int? matchingIngredientsCount;
  final int? missingIngredientsCount;
  final double? averageRating;
  final int? ratingCount;

  final GlobalKey _backgroundImageKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        if (onRecipeTap != null) {
          onRecipeTap!(Recipe(
            id: id,
            internalId: internalId,
            isInternal: isInternal,
            name: name,
            imageUrl: imageUrl,
            place: country,
            readyInMinutes: readyInMinutes,
            servings: servings,
            calories: calories,
            protein: protein,
            fat: fat,
            carbs: carbs,
            sugar: sugar,
            healthScore: healthScore,
            usedIngredientCount: matchingIngredientsCount,
            missedIngredientCount: missingIngredientsCount,
            usedIngredients: [],
            missedIngredients: [],
            averageRating: averageRating,
            ratingCount: ratingCount,
            containsUserAllergens: containsUserAllergens,
            matchedAllergens: matchedAllergens,
          ));
        } else {
          final result = await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => RecipeDetailScreen(
                recipeId: id,
                internalRecipeId: internalId, // Pass the internal ID if available
                isInternal: isInternal, // Pass the internal flag
                initialImageUrl: imageUrl,
                initialName: name,
                initialPlace: country,
                initialReadyInMinutes: readyInMinutes,
                containsUserAllergens: containsUserAllergens,
                matchedAllergens: matchedAllergens,
              ),
            ),
          );
          if (result is Map<String, dynamic> && onRatingUpdated != null) {
            final double? newRating = result['averageRating'] as double?;
            final int? newRatingCount = result['ratingCount'] as int?;
            if (newRating != null && newRatingCount != null) {
              onRatingUpdated!(newRating, newRatingCount);
            }
          }
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: AspectRatio(
          // Bleibt beim ursprünglichen 16/9, damit Parallax sichtbar ist
          aspectRatio: 16 / 9,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              children: [
                _buildParallaxBackground(context),
                _buildGradient(),
                _buildTitleAndSubtitle(),
                _buildRatingOverlay(),
                if (containsUserAllergens == true && (matchedAllergens?.isNotEmpty ?? false))
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 180),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.85),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.warning, color: Colors.white, size: 16),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Builder(
                              builder: (context) {
                                final allergens = matchedAllergens ?? [];
                                String text;
                                if (allergens.length > 2) {
                                  text = 'Allergens: '
                                    + allergens.take(2).join(", ")
                                    + ' +${allergens.length - 2} more';
                                } else {
                                  text = 'Allergens: ' + allergens.join(", ");
                                }
                                return Text(
                                  text,
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildParallaxBackground(BuildContext context) {
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
                    'assets/images/placeholder_image.png',
                    key: _backgroundImageKey,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Center(
                      child: Icon(Icons.image_not_supported, size: 48, color: Colors.grey),
                    ),
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
                'assets/images/placeholder_image.png',
                key: _backgroundImageKey,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Center(
                  child: Icon(Icons.image_not_supported, size: 48, color: Colors.grey),
                ),
              ),
      ],
    );
  }

  Widget _buildGradient() {
    return Positioned.fill(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            // HIER KÖNNTEST DU DIE STOPS ANPASSEN, WENN DU MEHR ODER WENIGER VERDECKUNG UNTEN MÖCHTEST
            // Aktuell 0.6 -> transparent bis 0.95 -> 70% schwarz
            stops: const [0.6, 0.95],
          ),
        ),
      ),
    );
  }

  Widget _buildTitleAndSubtitle() {
    String? secondaryInfoText;

    if (currentSortOption != null && !currentSortOption!.startsWith('time_')) {
      switch (currentSortOption) {
        case 'relevance':
          break;
        case 'popularity_desc':
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
        // For 'matchingIngredients_desc', logic will be added when backend provides counts
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
          const SizedBox(height: 8), // Abstand zu den unteren Infos
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (readyInMinutes != null)
                Text(
                  'Prep Time: $readyInMinutes Min.',
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),

              if (secondaryInfoText != null)
                Text(
                  secondaryInfoText!,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRatingOverlay() {
    // Nur anzeigen, wenn Bewertungsdaten vorhanden sind und es Bewertungen gibt
    if (averageRating == null || ratingCount == null || ratingCount! == 0) {
      return const SizedBox.shrink();
    }

    return Positioned(
      top: 12, // Abstand vom oberen Rand
      right: 12, // Abstand vom rechten Rand
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5), // Leichter, dunkler Hintergrund
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min, // Damit der Row nur so breit wie nötig ist
          children: [
            const Icon(Icons.star, color: Colors.amber, size: 14), // Kleines Stern-Icon
            const SizedBox(width: 4),
            Text(
              // averageRating auf eine Dezimalstelle gerundet
              '${averageRating!.toStringAsFixed(1)}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
            // Nur die Anzahl der Bewertungen anzeigen, wenn größer 0
            if (ratingCount! > 0) ...[
              const SizedBox(width: 4),
              Text(
                '($ratingCount)',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 11,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

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
    final scrollableBox = scrollable.context.findRenderObject() as RenderBox;
    final listItemBox = listItemContext.findRenderObject() as RenderBox;
    final listItemOffset = listItemBox.localToGlobal(
      listItemBox.size.centerLeft(Offset.zero),
      ancestor: scrollableBox,
    );

    final viewportDimension = scrollable.position.viewportDimension;
    final scrollFraction = (listItemOffset.dy / viewportDimension).clamp(
      0.0,
      1.0,
    );

    final verticalAlignment = Alignment(0.0, scrollFraction * 2 - 1);

    final backgroundSize =
        (backgroundImageKey.currentContext!.findRenderObject() as RenderBox)
            .size;
    final listItemSize = context.size;
    final childRect = verticalAlignment.inscribe(
      backgroundSize,
      Offset.zero & listItemSize,
    );

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