// lib/features/recipeList/parallax_recipes.dart

import 'package:flutter/material.dart';
import 'package:frontend/common/models/recipe.dart';
import 'package:frontend/features/recipeList/recipe_detail_screen.dart'; // Ensure RecipeDetailScreen is imported
import 'package:flutter/services.dart'; // Import for rootBundle in RecipeItem

// Note: If RecipeItem and ParallaxFlowDelegate are in separate files,
// you would import 'package:frontend/features/recipeList/recipe_item.dart'; here
// and keep RecipeItem and ParallaxFlowDelegate in that separate file.
// For simplicity in this answer, I'm keeping them together in this file.

class ParallaxRecipes extends StatefulWidget {
  const ParallaxRecipes({
    super.key,
    required this.recipes,
    this.currentSortOption,
    required this.scrollController, // NOW REQUIRED: Receive the controller
    required this.isLoadingMore, // NOW REQUIRED: Receive loading state
    required this.hasMore, // NOW REQUIRED: Receive hasMore state
  });

  final List<Recipe> recipes;
  final String? currentSortOption;
  final ScrollController scrollController; // Store the received controller
  final bool isLoadingMore;
  final bool hasMore;

  @override
  State<ParallaxRecipes> createState() => _ParallaxRecipesState();
}

class _ParallaxRecipesState extends State<ParallaxRecipes> {
  @override
  Widget build(BuildContext context) {
    // Use ListView.builder directly within ParallaxRecipes
    return ListView.builder(
      controller: widget.scrollController, // Attach the received controller
      itemCount: widget.recipes.length + (widget.hasMore ? 1 : 0), // Add 1 for the loading indicator
      itemBuilder: (context, index) {
        if (index == widget.recipes.length) {
          // This is the loading indicator at the end of the list
          return widget.isLoadingMore
              ? const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Center(child: CircularProgressIndicator()),
                )
              : const SizedBox.shrink(); // No more items, hide indicator
        }

        final recipe = widget.recipes[index];
        return RecipeItem(
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
          matchingIngredientsCount: recipe.matchingIngredientsCount,
          missingIngredientsCount: recipe.missingIngredientsCount,
        );
      },
    );
  }
}

// Keep RecipeItem and ParallaxFlowDelegate as they are (or move to recipe_item.dart)
@immutable
class RecipeItem extends StatelessWidget {
  RecipeItem({
    super.key,
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
    return Flow(
      delegate: ParallaxFlowDelegate(
        scrollable: Scrollable.of(context), // This will now correctly find the ListView.builder inside ParallaxRecipes
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (readyInMinutes != null)
                Text(
                  'Zubereitungszeit: $readyInMinutes Min.',
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