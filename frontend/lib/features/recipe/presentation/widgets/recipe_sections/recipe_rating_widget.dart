import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // For Riverpod ConsumerWidget
import 'package:provider/provider.dart' as legacy_provider; // Alias für traditionellen Provider

import 'package:frontend/features/recipe/presentation/provider/rating_notifier.dart';
import 'package:frontend/features/auth/presentation/providers/auth_state_provider.dart'; // To get currentUserIdProvider
import 'package:frontend/features/recipe/data/models/recipe_model.dart'; // Das Data-Model
import 'package:frontend/features/recipe/domain/entities/recipe.dart'; // NEU: Import für die Domain-Entität Recipe


class RecipeRatingWidget extends ConsumerStatefulWidget {
  final RecipeModel recipe; // Das Data-Model, das übergeben wird

  const RecipeRatingWidget({
    super.key,
    required this.recipe,
  });

  @override
  ConsumerState<RecipeRatingWidget> createState() => _RecipeRatingWidgetState();
}

class _RecipeRatingWidgetState extends ConsumerState<RecipeRatingWidget> {
  double _currentRating = 0.0;
  bool _isLoading = true; // To track if we're fetching the initial rating
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Stelle sicher, dass widget.recipe.id nicht null ist, bevor du versuchst, eine Bewertung abzurufen
    if (widget.recipe.id != null) {
      _fetchUserRating();
    } else {
      // Wenn keine interne Rezept-ID vorhanden ist, kann keine Bewertung gespeichert/geladen werden.
      setState(() {
        _isLoading = false;
        _currentRating = 0.0;
        _errorMessage = 'Recipe ID is missing, cannot load or save rating.';
      });
    }
  }

  // Fetches the user's current rating for this recipe
  void _fetchUserRating() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final String? userId = ref.read(currentUserIdProvider);
    if (userId == null) {
      setState(() {
        _isLoading = false;
        _currentRating = 0.0;
      });
      return;
    }

    // SICHERSTELLEN, DASS recipe.id NICHT NULL IST, BEVOR ES VERWENDET WIRD
    final String? recipeId = widget.recipe.id;
    if (recipeId == null) {
      setState(() {
        _isLoading = false;
        _currentRating = 0.0;
        _errorMessage = 'Recipe ID is missing, cannot load rating.';
      });
      return;
    }

    try {
      final ratingNotifier = legacy_provider.Provider.of<RatingNotifier>(context, listen: false);
      final existingRating = await ratingNotifier.getUserRecipeRating(
        userId: userId,
        recipeId: recipeId, // <-- KORRIGIERT: recipeId ist jetzt String (non-nullable)
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

  // Handles when a user taps on a star to set a rating
  void _handleRatingSelected(double newRating) async {
    final String? userId = ref.read(currentUserIdProvider);

    if (userId == null) {
      _showSnackBar('Please log in to rate recipes.');
      return;
    }

    // SICHERSTELLEN, DASS recipe.id NICHT NULL IST, BEVOR ES VERWENDET WIRD
    if (widget.recipe.id == null) {
      _showSnackBar('Recipe ID is missing, cannot save rating.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final ratingNotifier = legacy_provider.Provider.of<RatingNotifier>(context, listen: false);
      // KORRIGIERT: Umwandlung von RecipeModel zu Recipe Entity
      // Annahme: Ihr RecipeModel hat eine Methode `toEntity()`
      final Recipe recipeEntity = widget.recipe.toEntity();

      await ratingNotifier.addOrUpdateRecipeRating(
        userId: userId,
        spoonacularId: widget.recipe.spoonacularId,
        score: newRating.toInt(),
        recipe: recipeEntity, // <-- KORRIGIERT: Recipe Entity übergeben
      );

      setState(() {
        _currentRating = newRating;
        _isLoading = false;
      });
      _showSnackBar('Rating saved successfully!');
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to save rating: $e';
        _isLoading = false;
      });
      _showSnackBar(_errorMessage!);
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

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white));
    }

    // Zeige Rating-UI nur, wenn UserId vorhanden und Recipe ID nicht null ist
    if (userId == null || widget.recipe.id == null) {
      // Wenn die Recipe ID fehlt, kann der User nicht bewerten oder wir zeigen eine Info an.
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 8.0),
        child: Text(
          'Login to rate this recipe or recipe ID missing.',
          style: TextStyle(color: Colors.white70, fontSize: 14),
          textAlign: TextAlign.center,
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_errorMessage != null)
          Text(
            _errorMessage!,
            style: const TextStyle(color: Colors.red, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            return GestureDetector(
              onTap: () => _handleRatingSelected((index + 1).toDouble()),
              child: Icon(
                index < _currentRating ? Icons.star : Icons.star_border,
                color: Colors.amber,
                size: 30,
              ),
            );
          }),
        ),
        Text(
          _currentRating > 0 ? 'Your rating: $_currentRating' : 'Rate this recipe!',
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
      ],
    );
  }
}