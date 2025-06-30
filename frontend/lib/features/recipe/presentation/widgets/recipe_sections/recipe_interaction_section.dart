import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/recipe/presentation/widgets/recipe_sections/recipe_rating_widget.dart';
import 'package:frontend/utils/extensions.dart'; // Ensure this extension is still needed, otherwise remove
import 'package:provider/provider.dart' as provider;

import 'package:frontend/common/models/recipe/recipe_details.dart';
import 'package:frontend/features/recipe/presentation/provider/favorite_notifier.dart';
import 'package:frontend/features/auth/presentation/providers/auth_state_provider.dart';
import 'package:frontend/features/recipe/domain/entities/recipe.dart';
import 'package:frontend/main.dart'; // Import main.dart for scaffoldMessengerKey

class RecipeInteractionSection extends ConsumerStatefulWidget {
  final RecipeDetails recipeDetails;
  final void Function(double newAverage, int newCount)? onRatingChanged;

  const RecipeInteractionSection({
    super.key,
    required this.recipeDetails,
    this.onRatingChanged,
  });

  @override
  ConsumerState<RecipeInteractionSection> createState() => _RecipeInteractionSectionState();
}

class _RecipeInteractionSectionState extends ConsumerState<RecipeInteractionSection> {
  String? _lastKnownUserId;

  @override
  void initState() {
    super.initState();
    debugPrint('[RecipeInteractionSection] initState called.');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    debugPrint('[RecipeInteractionSection] didChangeDependencies called.');

    final asyncAuthUser = ref.watch(authStateChangesProvider);
    final String? currentUserId = asyncAuthUser.value?.uid;
    final String? internalRecipeId = widget.recipeDetails.id;

    final favoriteNotifier = provider.Provider.of<FavoriteNotifier>(context, listen: false);

    if (currentUserId != null && internalRecipeId != null) {
      if (_lastKnownUserId != currentUserId) {
        debugPrint('[RecipeInteractionSection] User changed from $_lastKnownUserId to $currentUserId. Resetting FavoriteNotifier and scheduling full fetch.');
        favoriteNotifier.reset();
        _lastKnownUserId = currentUserId;

        WidgetsBinding.instance.addPostFrameCallback((_) async {
          if (!mounted) return;
          debugPrint('[RecipeInteractionSection] PostFrameCallback: Initiating fetchFavoriteRecipes for new user: $currentUserId');
          await favoriteNotifier.fetchFavoriteRecipes(currentUserId);
          debugPrint('[RecipeInteractionSection] Initial favorite status for $internalRecipeId: ${favoriteNotifier.isRecipeCurrentlyFavorited(internalRecipeId)} (after full fetch).');
        });
      } else {
        final bool isGlobalFetchNeeded = favoriteNotifier.status == FavoriteStatus.initial ||
                                            favoriteNotifier.status == FavoriteStatus.error ||
                                            (favoriteNotifier.status == FavoriteStatus.loaded && favoriteNotifier.favoriteRecipes.isEmpty);

        if (isGlobalFetchNeeded && !favoriteNotifier.isLoading) {
          debugPrint('[RecipeInteractionSection] Notifier needs global data fetch (status: ${favoriteNotifier.status}, isLoading: ${favoriteNotifier.isLoading}). Scheduling full fetch.');
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            if (!mounted) return;
            debugPrint('[RecipeInteractionSection] PostFrameCallback: Initiating fetchFavoriteRecipes for user: $currentUserId');
            await favoriteNotifier.fetchFavoriteRecipes(currentUserId);
          });
        } else if (!favoriteNotifier.isRecipeStatusInCache(internalRecipeId) && !favoriteNotifier.isRecipeCheckingFavoriteStatus(internalRecipeId)) {
          debugPrint('[RecipeInteractionSection] Recipe status for $internalRecipeId not in cache or being checked. Scheduling single recipe check.');
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            if (!mounted) return;
            debugPrint('[RecipeInteractionSection] PostFrameCallback: Initiating checkAndLoadInitialFavoriteStatus for recipe: $internalRecipeId');
            await favoriteNotifier.checkAndLoadInitialFavoriteStatus(
              userId: currentUserId,
              recipeId: internalRecipeId,
            );
          });
        } else {
          debugPrint('[RecipeInteractionSection] didChangeDependencies: Favorite status for ${internalRecipeId} is already known or being loaded. Skipping API calls.');
        }
      }
    } else {
      debugPrint('[RecipeInteractionSection] Skipping favorite check: userId ($currentUserId) or internalRecipeId ($internalRecipeId) is null.');
      if (_lastKnownUserId != currentUserId) {
        _lastKnownUserId = currentUserId;
        if (currentUserId == null) {
          favoriteNotifier.reset();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final asyncAuthUser = ref.watch(authStateChangesProvider);
    final String? currentUserId = asyncAuthUser.when(
      data: (user) => user?.uid,
      loading: () => null,
      error: (err, stack) => null,
    );

    final favoriteNotifier = provider.Provider.of<FavoriteNotifier>(context);
    final String? internalRecipeId = widget.recipeDetails.id;

    final bool canInteract = currentUserId != null && internalRecipeId != null;
    final bool isFavoriteButtonLoading = favoriteNotifier.isRecipeCheckingFavoriteStatus(internalRecipeId!) || favoriteNotifier.isLoading;
    final bool isFavorited = favoriteNotifier.isRecipeCurrentlyFavorited(internalRecipeId);

    debugPrint('[RecipeInteractionSection] Build method: Recipe ${internalRecipeId} isFavorited: $isFavorited, ButtonLoading: $isFavoriteButtonLoading (Notifier Status: ${favoriteNotifier.status}, GlobalLoading: ${favoriteNotifier.isLoading}, RecipeLoading: ${favoriteNotifier.isRecipeCheckingFavoriteStatus(internalRecipeId)})');

    if (!canInteract) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Center(
          child: Text(
            asyncAuthUser.isLoading ? 'Checking login status...' : 'Log in to rate or favorite this recipe.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurface),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 4,
            child: RecipeRatingWidget(
              recipeDetails: widget.recipeDetails,
              onRatingChanged: widget.onRatingChanged,
            ),
          ),
          const SizedBox(width: 24),

          // Favorite button in its own well-defined circular container
          InkWell(
            borderRadius: BorderRadius.circular(30),
            onTap: isFavoriteButtonLoading
                ? null
                : () async {
                    if (internalRecipeId == null || currentUserId == null) {
                      scaffoldMessengerKey.currentState?.showSnackBar(
                        const SnackBar(content: Text('Interaction not possible: Recipe ID or User ID missing.')),
                      );
                      return;
                    }

                    await favoriteNotifier.toggleFavorite(
                      userId: currentUserId,
                      spoonacularId: widget.recipeDetails.spoonacularId,
                      recipe: widget.recipeDetails.toRecipe(),
                    );

                    if (mounted) {
                      if (favoriteNotifier.errorMessage != null) {
                        scaffoldMessengerKey.currentState?.showSnackBar(
                          SnackBar(content: Text(favoriteNotifier.errorMessage!)),
                        );
                      }
                    }
                  },
            child: Container(
              padding: const EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Icon(
                isFavorited ? Icons.favorite : Icons.favorite_border,
                color: isFavorited ? Colors.redAccent : Theme.of(context).colorScheme.primary,
                size: 28,
              ),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
    );
  }
}