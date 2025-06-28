// lib/features/recipe/presentation/widgets/recipe_sections/recipe_rating_widget.dart

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
  bool _isLoading = true;
  String? _errorMessage;

  // REMOVE these local state variables.
  // double _averageRating = 0.0; // No longer needed here
  // int _ratingCount = 0;      // No longer needed here

  @override
  void initState() {
    super.initState();
    // Set the initial user's own rating from recipeDetails
    _currentRating = widget.recipeDetails.userRating?.score?.toDouble() ?? 0.0;

    // Initialize RatingNotifier's averageRating and ratingCount
    // This is crucial to set the initial values from the recipeDetails
    // into the notifier's state when the widget first loads.
    final ratingNotifier = legacy_provider.Provider.of<RatingNotifier>(context, listen: false);
    ratingNotifier.setInitialAverageRating(widget.recipeDetails.averageRating ?? 0.0);
    ratingNotifier.setInitialRatingCount(widget.recipeDetails.ratingCount ?? 0);

    // Load the user's rating only if the internal recipe ID (UUID) is available.
    if (widget.recipeDetails.id != null) {
      _fetchUserRating(); // Ensures the latest user rating is loaded
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // This method is now primarily used to update the user's own rating
  // and ensure it is current.
  void _fetchUserRating() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final String? userId = ref.read(currentUserIdProvider);
    if (userId == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    final String? internalRecipeId = widget.recipeDetails.id;
    if (internalRecipeId == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Internal Recipe ID is missing, cannot load rating.';
      });
      return;
    }

    try {
      final ratingNotifier = legacy_provider.Provider.of<RatingNotifier>(context, listen: false);
      final existingRating = await ratingNotifier.getUserRecipeRating(
        userId: userId,
        recipeId: internalRecipeId,
      );

      setState(() {
        _currentRating = existingRating?.score.toDouble() ?? 0.0;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Could not load your rating: $e';
        _isLoading = false;
        _currentRating = 0.0;
      });
      _showSnackBar(_errorMessage!);
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
      _errorMessage = null;
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

      // No need for local setState(_isLoading = false) here, notifier handles it
      _showSnackBar('Rating saved successfully!');

    } catch (e) {
      // Catch error from notifier
      _showSnackBar('Failed to save rating: ${ratingNotifier.errorMessage ?? 'Unknown error'}');
      // If an error occurred, re-fetch the user's rating to revert if needed
      // and potentially refresh the average/count from backend.
      _fetchUserRating();
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

    // Use the notifier's isLoading state
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