import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Keep this for ConsumerStatefulWidget
import 'package:provider/provider.dart' as legacy_provider; // Use this for ChangeNotifier access

import 'package:frontend/features/recipe/presentation/provider/rating_notifier.dart';
import 'package:frontend/features/auth/presentation/providers/auth_state_provider.dart';
import 'package:frontend/common/models/recipe/recipe_details.dart';
import 'package:frontend/features/recipe/domain/entities/recipe.dart';
import 'package:frontend/main.dart'; // Import main.dart for scaffoldMessengerKey

class RecipeRatingWidget extends ConsumerStatefulWidget { // Remains ConsumerStatefulWidget
  final RecipeDetails recipeDetails;
  final void Function(double newAverage, int newCount)? onRatingChanged;

  const RecipeRatingWidget({
    super.key,
    required this.recipeDetails,
    this.onRatingChanged,
  });

  @override
  ConsumerState<RecipeRatingWidget> createState() => _RecipeRatingWidgetState();
}

class _RecipeRatingWidgetState extends ConsumerState<RecipeRatingWidget> {
  double _currentRating = 0.0;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _currentRating = widget.recipeDetails.userRating?.score?.toDouble() ?? 0.0;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.recipeDetails.id != null) {
        _fetchUserRating();
      }
    });
  }

  void _fetchUserRating() async {
    setState(() {
      _errorMessage = null;
    });

    final String? userId = ref.read(currentUserIdProvider);
    if (userId == null) {
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

    // Access the ChangeNotifier using legacy_provider.Provider.of
    final ratingNotifier = legacy_provider.Provider.of<RatingNotifier>(context, listen: false);
    ratingNotifier.setLoading(true);

    try {
      final existingRating = await ratingNotifier.getUserRecipeRating(
        userId: userId,
        recipeId: internalRecipeId,
      );

      if (mounted) {
        setState(() {
          _currentRating = existingRating?.score.toDouble() ?? 0.0;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Could not load your rating: ${e.toString()}';
          _currentRating = 0.0;
        });
        _showSnackBar(_errorMessage!);
      }
    } finally {
      if (mounted) {
        ratingNotifier.setLoading(false);
      }
    }
  }

  void _handleRatingSelected(double newRating) async {
    final String? userId = ref.read(currentUserIdProvider);

    if (userId == null) {
      _showSnackBar('Please log in to rate recipes.');
      return;
    }

    setState(() {
      _currentRating = newRating;
      _errorMessage = null;
    });

    try {
      final Recipe recipeEntity = Recipe(
        id: widget.recipeDetails.id,
        spoonacularId: widget.recipeDetails.spoonacularId,
        title: widget.recipeDetails.title,
        imageUrl: widget.recipeDetails.image ?? '',
      );

      // Access the ChangeNotifier using legacy_provider.Provider.of
      await legacy_provider.Provider.of<RatingNotifier>(context, listen: false).addOrUpdateRecipeRating(
        userId: userId,
        spoonacularId: widget.recipeDetails.spoonacularId,
        score: newRating.toInt(),
        recipe: recipeEntity,
      );

    } catch (e) {
      if (mounted) {
        final ratingNotifier = legacy_provider.Provider.of<RatingNotifier>(context, listen: false);
        _showSnackBar('Failed to save rating: ${ratingNotifier.errorMessage ?? 'Unknown error'}');

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _fetchUserRating(); // Re-fetch user rating to revert on error
          }
        });
      }
    }
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    // This uses ref.watch, so this widget remains ConsumerStatefulWidget
    final String? userId = ref.watch(currentUserIdProvider);
    final theme = Theme.of(context);

    // This listens to the ChangeNotifier for loading/error states for *this* widget
    final ratingNotifier = legacy_provider.Provider.of<RatingNotifier>(context);

    if (ratingNotifier.isLoading && userId != null && _currentRating == 0.0) {
      return Center(child: CircularProgressIndicator(strokeWidth: 2, color: theme.colorScheme.primary));
    }

    if (userId == null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Want to rate this recipe?',
            style: theme.textTheme.titleSmall?.copyWith(color: theme.colorScheme.onSurface),
            textAlign: TextAlign.start,
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: () {
              _showSnackBar('Login feature not implemented yet!');
            },
            icon: const Icon(Icons.login),
            label: const Text('Log in to Rate'),
            style: ElevatedButton.styleFrom(
              foregroundColor: theme.colorScheme.onPrimary,
              backgroundColor: theme.colorScheme.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (ratingNotifier.errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              ratingNotifier.errorMessage!,
              style: const TextStyle(color: Colors.red, fontSize: 12),
              textAlign: TextAlign.start,
            ),
          ),
        Text(
          _currentRating > 0 ? 'Your rating:' : 'Rate this recipe:',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.start,
        ),
        const SizedBox(height: 8),

        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: List.generate(5, (index) {
            return InkWell(
              onTap: () => _handleRatingSelected((index + 1).toDouble()),
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Icon(
                  index < _currentRating ? Icons.star : Icons.star_border,
                  color: theme.colorScheme.primary,
                  size: 36,
                ),
              ),
            );
          }),
        ),
        if (_currentRating > 0)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            // child: Text(
            //   'You rated: ${_currentRating.toInt()}',
            //   style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            //   textAlign: TextAlign.start,
            // ),
          ),
      ],
    );
  }
}