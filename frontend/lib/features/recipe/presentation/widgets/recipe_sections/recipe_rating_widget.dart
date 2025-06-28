import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as legacy_provider;

import 'package:frontend/features/recipe/presentation/provider/rating_notifier.dart';
import 'package:frontend/features/auth/presentation/providers/auth_state_provider.dart';
import 'package:frontend/common/models/recipe/recipe_details.dart';
import 'package:frontend/features/recipe/domain/entities/recipe.dart';

class RecipeRatingWidget extends ConsumerStatefulWidget {
  final RecipeDetails recipeDetails;

  const RecipeRatingWidget({
    super.key,
    required this.recipeDetails,
  });

  @override
  ConsumerState<RecipeRatingWidget> createState() => _RecipeRatingWidgetState();
}

class _RecipeRatingWidgetState extends ConsumerState<RecipeRatingWidget> {
  // _currentRating speichert die EIGENE Bewertung des Nutzers.
  // This remains local state as it updates instantly on tap.
  double _currentRating = 0.0;
  // bool _isLoading = true; // No longer needed as RatingNotifier will handle loading state for initial fetch
  String? _errorMessage; // Still useful for local errors not related to notifier's main ops

  @override
  void initState() {
    super.initState();
    // Initialize _currentRating immediately from recipeDetails
    _currentRating = widget.recipeDetails.userRating?.score?.toDouble() ?? 0.0;

    // Defer the initial setting of notifier state and fetching of user rating
    // until after the first frame has rendered.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ratingNotifier = legacy_provider.Provider.of<RatingNotifier>(context, listen: false);
      // Set initial values in the notifier from recipeDetails if they are not already set
      // (This prevents redundant updates if RatingNotifier is persistent across navigations)
      if (ratingNotifier.averageRating == 0.0 && ratingNotifier.ratingCount == 0) { // Or a more robust check
        ratingNotifier.setInitialAverageRating(widget.recipeDetails.averageRating ?? 0.0);
        ratingNotifier.setInitialRatingCount(widget.recipeDetails.ratingCount ?? 0);
      }

      // Load the user's rating only if the internal recipe ID (UUID) is available.
      if (widget.recipeDetails.id != null) {
        _fetchUserRating(); // Ensures the latest user rating is loaded
      }
      // No else block needed as _isLoading is now primarily handled by the notifier
    });
  }

  void _fetchUserRating() async {
    // No local setState for _isLoading = true; here, as the notifier will manage its own loading state.
    // We only set local error message for this specific fetch.
    setState(() {
      _errorMessage = null;
    });

    final String? userId = ref.read(currentUserIdProvider);
    if (userId == null) {
      // No local isLoading update needed, simply return
      return;
    }

    final String? internalRecipeId = widget.recipeDetails.id;
    if (internalRecipeId == null) {
      setState(() {
        _errorMessage = 'Internal Recipe ID is missing, cannot load rating.';
      });
      _showSnackBar(_errorMessage!);
      return;
    }

    final ratingNotifier = legacy_provider.Provider.of<RatingNotifier>(context, listen: false);
    // Set notifier's loading state before API call
    ratingNotifier.setLoading(true);

    try {
      final existingRating = await ratingNotifier.getUserRecipeRating(
        userId: userId,
        recipeId: internalRecipeId,
      );

      setState(() {
        _currentRating = existingRating?.score.toDouble() ?? 0.0;
        // _isLoading = false; // Not needed
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Could not load your rating: $e';
        _currentRating = 0.0;
      });
      _showSnackBar(_errorMessage!);
    } finally {
      // Ensure loading state is turned off by notifier
      ratingNotifier.setLoading(false);
    }
  }

  void _handleRatingSelected(double newRating) async {
    final String? userId = ref.read(currentUserIdProvider);

    if (userId == null) {
      _showSnackBar('Please log in to rate recipes.');
      return;
    }

    // Instantly update the local user's rating for immediate visual feedback
    setState(() {
      _currentRating = newRating;
      _errorMessage = null; // Clear any previous local error
    });

    // Show loading state for the actual API call
    final ratingNotifier = legacy_provider.Provider.of<RatingNotifier>(context, listen: false);
    ratingNotifier.setLoading(true); // Use the notifier's isLoading state

    try {
      final Recipe recipeEntity = Recipe(
        id: widget.recipeDetails.id,
        spoonacularId: widget.recipeDetails.spoonacularId,
        title: widget.recipeDetails.title,
        imageUrl: widget.recipeDetails.image ?? '',
      );

      // This call will update the averageRating and ratingCount within the RatingNotifier
      await ratingNotifier.addOrUpdateRecipeRating(
        userId: userId,
        spoonacularId: widget.recipeDetails.spoonacularId,
        score: newRating.toInt(),
        recipe: recipeEntity,
        // comment: '', // Add comment if you have an input for it
      );

      // _showSnackBar('Rating saved successfully!');

    } catch (e) {
      // Catch error from notifier and display it
      _showSnackBar('Failed to save rating: ${ratingNotifier.errorMessage ?? 'Unknown error'}');
      // If an error occurred, re-fetch the user's rating to revert if needed
      // and potentially refresh the average/count from backend.
      // Do this in a post-frame callback to avoid a nested build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _fetchUserRating();
      });
    } finally {
      // Ensure loading state is turned off by notifier
      ratingNotifier.setLoading(false);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String? userId = ref.watch(currentUserIdProvider);
    final theme = Theme.of(context);

    // WATCH the RatingNotifier to get the current average rating and count.
    // This is the crucial change: the UI now reacts to updates in the notifier.
    final ratingNotifier = legacy_provider.Provider.of<RatingNotifier>(context);
    final double displayAverageRating = ratingNotifier.averageRating;
    final int displayRatingCount = ratingNotifier.ratingCount;

    // Use the notifier's isLoading state for the main loading indicator.
    // The `_isLoading` local state was removed for this reason.
    if (ratingNotifier.isLoading && userId != null) {
      return Center(child: CircularProgressIndicator(strokeWidth: 2, color: theme.colorScheme.primary));
    }

    // If no user is logged in, show only the average rating and no interaction.
    if (userId == null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return Icon(
                index < displayAverageRating.round() ? Icons.star : Icons.star_border,
                color: Colors.amber[700],
                size: 30,
              );
            }),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Text(
              displayRatingCount > 0
                  ? '${displayAverageRating.toStringAsFixed(1)} / 5.0 (${displayRatingCount} ratings)'
                  : 'No ratings yet.',
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              'Login to rate this recipe.',
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      );
    }

    // If a user is logged in:
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (ratingNotifier.errorMessage != null) // Use notifier's error message
          Text(
            ratingNotifier.errorMessage!,
            style: const TextStyle(color: Colors.red, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        // Average rating and number of ratings
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            return Icon(
              index < displayAverageRating.round() ? Icons.star : Icons.star_border,
              color: Colors.amber[700],
              size: 24, // Slightly smaller for average display
            );
          }),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(
            displayRatingCount > 0
                ? 'Average: ${displayAverageRating.toStringAsFixed(1)} / 5.0 (${displayRatingCount} ratings)'
                : 'No ratings yet.',
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
        ),
        // User's own rating and interaction to rate
        Text(
          'Your rating:',
          style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            return GestureDetector(
              onTap: () => _handleRatingSelected((index + 1).toDouble()),
              child: Icon(
                index < _currentRating ? Icons.star : Icons.star_border, // Shows YOUR rating
                color: Colors.blueAccent, // Different color to highlight user's own rating
                size: 36, // Larger to indicate interaction
              ),
            );
          }),
        ),
        Text(
          _currentRating > 0 ? 'You rated: ${_currentRating.toInt()}' : 'Tap stars to rate!',
          style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }
}