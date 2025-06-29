import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/recipe/presentation/widgets/recipe_sections/recipe_rating_widget.dart';
import 'package:frontend/utils/extensions.dart';
import 'package:provider/provider.dart' as provider;

import 'package:frontend/common/models/recipe/recipe_details.dart';
import 'package:frontend/features/recipe/presentation/provider/favorite_notifier.dart';
import 'package:frontend/features/auth/presentation/providers/auth_state_provider.dart';
import 'package:frontend/features/recipe/domain/entities/recipe.dart';
import 'package:frontend/main.dart';

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
  String? _lastKnownUserId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeFavoriteNotifier();
    });
  }

  void _initializeFavoriteNotifier() async {
    final asyncAuthUser = ref.read(authStateChangesProvider);
    final String? currentUserId = await asyncAuthUser.when(
      data: (user) => user?.uid,
      loading: () => null,
      error: (_, __) => null,
    );

    final favoriteNotifier = provider.Provider.of<FavoriteNotifier>(context, listen: false);
    final String? internalRecipeId = widget.recipeDetails.id;

    if (currentUserId == null || internalRecipeId == null) {
      debugPrint('[RecipeInteractionSection] Skipping: currentUserId or recipeId is null');
      if (_lastKnownUserId != currentUserId) {
        _lastKnownUserId = currentUserId;
        if (currentUserId == null) favoriteNotifier.reset();
      }
      return;
    }

    if (_lastKnownUserId != currentUserId) {
      favoriteNotifier.reset();
      _lastKnownUserId = currentUserId;
      await favoriteNotifier.init(currentUserId);
    } else if (!favoriteNotifier.isRecipeStatusInCache(internalRecipeId) &&
               !favoriteNotifier.isRecipeCheckingFavoriteStatus(internalRecipeId)) {
      // Optional: spezifischen Check nachreichen
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final asyncAuthUser = ref.watch(authStateChangesProvider);
    final String? currentUserId = asyncAuthUser.when(
      data: (user) => user?.uid,
      loading: () => null,
      error: (_, __) => null,
    );

    final favoriteNotifier = provider.Provider.of<FavoriteNotifier>(context);
    final String? internalRecipeId = widget.recipeDetails.id;
    final bool canInteract = currentUserId != null && internalRecipeId != null;

    final bool showFavoriteLoader = favoriteNotifier.isLoading ||
        favoriteNotifier.isRecipeCheckingFavoriteStatus(internalRecipeId ?? '');
    final bool isFavorited = showFavoriteLoader
        ? false
        : favoriteNotifier.isRecipeCurrentlyFavorited(internalRecipeId ?? '');

    if (asyncAuthUser.isLoading) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
    }

    if (!canInteract) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Center(
          child: Text(
            'Log in to rate or favorite this recipe.',
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 4,
            child: RecipeRatingWidget(recipeDetails: widget.recipeDetails),
          ),
          const SizedBox(width: 24),
          InkWell(
            borderRadius: BorderRadius.circular(30),
            onTap: showFavoriteLoader
                ? null
                : () async {
                    if (internalRecipeId == null || currentUserId == null) return;

                    await favoriteNotifier.toggleFavorite(
                      userId: currentUserId,
                      spoonacularId: widget.recipeDetails.spoonacularId,
                      recipe: widget.recipeDetails.toRecipe(),
                    );

                    if (mounted && favoriteNotifier.errorMessage != null) {
                      scaffoldMessengerKey.currentState?.showSnackBar(
                        SnackBar(content: Text(favoriteNotifier.errorMessage!)),
                      );
                    }
                  },
            child: Container(
              padding: const EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceVariant.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: theme.colorScheme.outline.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: showFavoriteLoader
                  ? SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary.withOpacity(0.6)),
                      ),
                    )
                  : Icon(
                      isFavorited ? Icons.favorite : Icons.favorite_border,
                      color: isFavorited ? Colors.redAccent : theme.colorScheme.primary,
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
