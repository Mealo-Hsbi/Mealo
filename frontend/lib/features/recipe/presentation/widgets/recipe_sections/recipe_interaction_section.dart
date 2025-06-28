// lib/features/recipe/presentation/widgets/recipe_sections/recipe_interaction_section.dart

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
  // NEW: State variables to track the last fetched user and recipe IDs.
  // This prevents continuous API calls when the widget rebuilds but the IDs haven't changed.
  String? _lastFetchedUserId;
  String? _lastFetchedInternalRecipeId;

  @override
  void initState() {
    super.initState();
    // initState is generally for one-time initialization.
    // API calls that depend on Riverpod values or widget properties
    // are better placed in didChangeDependencies or directly in build with careful conditions.
  }

  // NEW: didChangeDependencies is called when the dependencies of this widget change.
  // This is a more appropriate place to react to changes in providers or widget properties
  // that might trigger data fetching, compared to addPostFrameCallback in build.
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Read the current authentication status from Riverpod.
    // We use `ref.read` here because we just need the current value, not to rebuild on every change
    // when this method is called. The `build` method already uses `ref.watch`.
    final asyncAuthUser = ref.read(authStateChangesProvider);
    final String? currentUserId = asyncAuthUser.value?.uid; // Get the user ID if available

    // Get the internal recipe ID from the RecipeDetails object.
    // This ID is provided by our backend, NOT the Spoonacular ID.
    final String? internalRecipeId = widget.recipeDetails.id;

    // Condition to decide whether to fetch favorite status and user's favorites:
    // 1. A user is logged in (`currentUserId` is not null) AND
    // 2. An internal recipe ID is available (`internalRecipeId` is not null) AND
    // 3. Either the user ID OR the internal recipe ID has changed since the last fetch.
    if (currentUserId != null &&
        internalRecipeId != null &&
        (currentUserId != _lastFetchedUserId || internalRecipeId != _lastFetchedInternalRecipeId)) {

      // Update the stored IDs to prevent immediate re-fetching on the next build/dependency change.
      _lastFetchedUserId = currentUserId;
      _lastFetchedInternalRecipeId = internalRecipeId;

      // Schedule the API calls to happen after the current build frame.
      // This is still needed to avoid calling `Provider.of` during build,
      // but the condition above ensures it only runs when necessary.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Ensure the widget is still mounted before accessing the context.
        if (mounted) {
          final favoriteNotifier = provider.Provider.of<FavoriteNotifier>(context, listen: false);

          // Only proceed if the notifier is not already busy loading to avoid queuing multiple requests.
          if (!favoriteNotifier.isLoading) {
            // Check the favorite status for the SPECIFIC internal recipe ID.
            favoriteNotifier.checkRecipeFavoritedStatus(currentUserId, internalRecipeId);
            // Fetch ALL favorite recipes for the user (needed to populate the list in FavoriteNotifier).
            favoriteNotifier.fetchFavoriteRecipes(currentUserId);
            // Note: RecipeRatingWidget is designed to handle fetching the user's rating itself
            // when `recipeDetails.userRating` is initially null.
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch the authentication state provider to react to user login/logout.
    final asyncAuthUser = ref.watch(authStateChangesProvider);
    final String? currentUserId = asyncAuthUser.when(
      data: (user) => user?.uid,
      loading: () => null,
      error: (err, stack) => null,
    );

    // Watch the FavoriteNotifier to react to changes in favorite status or loading state.
    final favoriteNotifier = context.watch<FavoriteNotifier>();

    // Determine if the current recipe is favorited. We use `widget.recipeDetails.id`
    // because this is the internal DB ID which is used for favorite checks.
    final bool isFavorited = favoriteNotifier.isRecipeCurrentlyFavorited(widget.recipeDetails.id ?? '');
    final theme = Theme.of(context);

    // Get the ID of the specific favorite entry if the recipe is favorited.
    // This `id` is needed for `removeFavorite` call.
    final String? favoriteEntryId = widget.recipeDetails.id != null
        ? favoriteNotifier.favoriteRecipes
              .firstWhereOrNull((fav) => fav.recipe.id == widget.recipeDetails.id)
              ?.id
        : null;

    // Determine if interaction (favoriting/rating) is possible.
    // Both a logged-in user and an internal recipe ID are required.
    final bool canInteract = currentUserId != null && widget.recipeDetails.id != null;

    // If interaction is not possible, display a message (e.g., "Log in to interact").
    if (!canInteract) {
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

    // If interaction is possible, display the favorite and rating widgets.
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(
            child: Column(
              children: [
                // RecipeRatingWidget now receives the RecipeDetails, which includes userRating, averageRating.
                // It will handle its own display logic based on these properties.
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
                // Disable button if loading or not interactable.
                onPressed: favoriteNotifier.isLoading || !canInteract
                    ? null
                    : () async {
                        // Double-check: if already loading, exit.
                        if (favoriteNotifier.isLoading) return;

                        // These checks should ideally be covered by `canInteract` beforehand,
                        // but act as a fail-safe.
                        if (widget.recipeDetails.id == null || currentUserId == null) {
                          // NEW: Use the global ScaffoldMessengerKey for Snackbars.
                          scaffoldMessengerKey.currentState?.showSnackBar(
                            const SnackBar(content: Text('Cannot interact: Recipe ID or User ID missing.')),
                          );
                          return;
                        }

                        // Create a Recipe entity using the internal DB ID and Spoonacular ID.
                        final Recipe recipeEntity = Recipe(
                          id: widget.recipeDetails.id!, // Use the internal DB ID (String UUID)
                          spoonacularId: widget.recipeDetails.spoonacularId, // Use the Spoonacular ID (int)
                          title: widget.recipeDetails.title,
                          imageUrl: widget.recipeDetails.image ?? '',
                        );

                        // Toggle favorite status.
                        if (isFavorited) {
                          // If already favorited, remove it.
                          if (favoriteEntryId != null) {
                            await favoriteNotifier.removeFavorite(currentUserId, favoriteEntryId);
                          } else {
                            // This case should ideally not happen if `isFavorited` is true,
                            // but `favoriteEntryId` is null.
                            scaffoldMessengerKey.currentState?.showSnackBar(
                              const SnackBar(content: Text('Error: Could not unfavorite (ID missing).')),
                            );
                          }
                        } else {
                          // If not favorited, add it.
                          await favoriteNotifier.addFavorite(
                            currentUserId,
                            widget.recipeDetails.spoonacularId,
                            recipeEntity,
                          );
                        }

                        // Display a SnackBar after the operation is complete.
                        // Using the global key avoids issues with context no longer being available.
                        // The `mounted` check is less critical now but still good practice.
                        if (mounted) {
                          if (favoriteNotifier.errorMessage != null) {
                            scaffoldMessengerKey.currentState?.showSnackBar(
                              SnackBar(content: Text(favoriteNotifier.errorMessage!)),
                            );
                            // NEW: Clear the error message after it has been displayed.
                            // This prevents the same error from showing up on subsequent rebuilds.
                            // favoriteNotifier.clearErrorMessage();
                          } else {
                            // Optional: Show a success message.
                            scaffoldMessengerKey.currentState?.showSnackBar(
                                SnackBar(content: Text(isFavorited ? 'Recipe unfavorited!' : 'Recipe favorited!'))
                            );
                          }
                        }
                      },
              ),
              Text(isFavorited ? 'Favorited' : 'Add to favorites', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            ],
          ),
        ],
      ),
    );
  }
}
