import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/recipe/presentation/widgets/recipe_sections/recipe_rating_widget.dart';
import 'package:frontend/utils/extensions.dart';
import 'package:provider/provider.dart' as provider; // For FavoriteNotifier

import 'package:frontend/common/models/recipe/recipe_details.dart';
import 'package:frontend/features/recipe/presentation/provider/favorite_notifier.dart';
import 'package:frontend/features/auth/presentation/providers/auth_state_provider.dart';
import 'package:frontend/features/recipe/domain/entities/recipe.dart';
import 'package:frontend/main.dart'; // Import main.dart for scaffoldMessengerKey

class RecipeInteractionSection extends ConsumerStatefulWidget {
  final RecipeDetails recipeDetails;

  const RecipeInteractionSection({
    super.key,
    required this.recipeDetails,
  });

  @override
  ConsumerState<RecipeInteractionSection> createState() => _RecipeInteractionSectionState();
}

class _RecipeInteractionSectionState extends ConsumerState<RecipeInteractionSection> {
  // Lokales Flag, um zu verfolgen, ob der initiale Favoriten-Fetch für den aktuellen Benutzer abgeschlossen ist.
  // Setzen wir es zurück, wenn sich der Benutzer ändert oder die Komponente neu initialisiert wird.
  String? _lastKnownUserId; // Um den Wechsel des Benutzers zu erkennen

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

    if (currentUserId == null || internalRecipeId == null) {
      debugPrint('[RecipeInteractionSection] Skipping favorite check: userId or internalRecipeId is null. User ID: $currentUserId, Recipe ID: $internalRecipeId');
      if (_lastKnownUserId != currentUserId) { // Handle user logout/initial state
        _lastKnownUserId = currentUserId;
      }
      return;
    }

    final favoriteNotifier = provider.Provider.of<FavoriteNotifier>(context, listen: false);

    // If user changed or it's the very first load for this user, reset and fetch all favorites.
    if (_lastKnownUserId != currentUserId) {
      debugPrint('[RecipeInteractionSection] User changed from $_lastKnownUserId to $currentUserId. Resetting FavoriteNotifier and fetching new favorites.');
      favoriteNotifier.reset(); // Reset to clear previous user's data
      _lastKnownUserId = currentUserId; // Update last known user ID
      
      // Schedule fetch after current frame
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) return;
        debugPrint('[RecipeInteractionSection] PostFrameCallback: Initiating fetchFavoriteRecipes for new user: $currentUserId');
        await favoriteNotifier.fetchFavoriteRecipes(currentUserId);
        debugPrint('[RecipeInteractionSection] Initial favorite status for $internalRecipeId: ${favoriteNotifier.isRecipeCurrentlyFavorited(internalRecipeId)} (after full fetch for new user).');
      });
      return; // Exit this didChangeDependencies call. It will be called again after notifyListeners.
    }

    // If the notifier hasn't successfully loaded yet OR is in an error state,
    // and it's not currently loading, try to fetch favorite recipes.
    // We explicitly check favoriteRecipes.isEmpty to ensure we fetch if the list is empty,
    // even if status is 'loaded' but perhaps due to a previous partial load or bug.
    if (!favoriteNotifier.isLoading && 
        (favoriteNotifier.status == FavoriteStatus.initial || 
        favoriteNotifier.status == FavoriteStatus.error || 
        favoriteNotifier.favoriteRecipes.isEmpty) // Ensures fetch if list is unexpectedly empty
      ) {
      debugPrint('[RecipeInteractionSection] PostFrameCallback: Notifier needs data (initial/error/empty list). Calling fetchFavoriteRecipes for user: $currentUserId');
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) return;
        await favoriteNotifier.fetchFavoriteRecipes(currentUserId);
        // After fetching all favorites, the status for internalRecipeId should be known in cache.
        debugPrint('[RecipeInteractionSection] Initial favorite status for $internalRecipeId: ${favoriteNotifier.isRecipeCurrentlyFavorited(internalRecipeId)} (after callback).');
      });
    } else {
      // If we reach here, it means the notifier is either loading, or already successfully loaded
      // and the favoriteRecipes list is not empty.
      debugPrint('[RecipeInteractionSection] didChangeDependencies: Favorite status for ${internalRecipeId} already known or Notifier loading/loaded. Skipping API calls.');
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

    // WICHTIG: Hier `provider.Provider.of<FavoriteNotifier>(context)` OHNE listen: false verwenden.
    final favoriteNotifier = provider.Provider.of<FavoriteNotifier>(context); // <- Hier lauschst du auf Änderungen
    
    final String? internalRecipeId = widget.recipeDetails.id;

    final bool isFavorited = favoriteNotifier.isRecipeCurrentlyFavorited(internalRecipeId ?? '');
    final theme = Theme.of(context);

    final bool canInteract = currentUserId != null && internalRecipeId != null;

    if (!canInteract) {
      debugPrint('[RecipeInteractionSection] Build: Cannot interact. UserID: $currentUserId, RecipeID: $internalRecipeId. Loading: ${asyncAuthUser.isLoading}');
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Center(
          child: Text(
            asyncAuthUser.isLoading ? 'Checking login status...' : 'Log in to rate or favorite this recipe.',
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    debugPrint('[RecipeInteractionSection] Build method: Recipe ${internalRecipeId ?? 'N/A'} isFavorited: $isFavorited (from Notifier state)');

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(
            child: Column(
              children: [
                RecipeRatingWidget(
                  recipeDetails: widget.recipeDetails,
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Column(
            children: [
              IconButton(
                icon: Icon(
                  isFavorited ? Icons.favorite : Icons.favorite_border,
                  color: isFavorited ? Colors.redAccent : theme.colorScheme.onSurface.withOpacity(0.6),
                  size: 30,
                ),
                onPressed: favoriteNotifier.isLoading || !canInteract
                    ? null // Deaktiviere den Button, wenn der Notifier lädt oder Interaktion nicht möglich ist
                    : () async {
                        if (favoriteNotifier.isLoading) {
                          return;
                        }

                        if (internalRecipeId == null || currentUserId == null) {
                          scaffoldMessengerKey.currentState?.showSnackBar(
                            const SnackBar(content: Text('Cannot interact: Recipe ID or User ID missing.')),
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
                          } else {
                            // final bool newIsFavorited = favoriteNotifier.isRecipeCurrentlyFavorited(internalRecipeId);
                            // scaffoldMessengerKey.currentState?.showSnackBar(
                            //     SnackBar(content: Text(newIsFavorited ? 'Recipe favorited!' : 'Recipe unfavorited!'))
                            // );
                          }
                        }
                      },
              ),
              // Text(isFavorited ? 'Favorited' : 'Add to favorites', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            ],
          ),
        ],
      ),
    );
  }
}