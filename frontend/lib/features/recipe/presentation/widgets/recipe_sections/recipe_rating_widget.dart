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
  double _currentRating = 0.0;
  bool _isLoading = true;
  String? _errorMessage;

  // Neue Felder für die aggregierten Bewertungen
  double _averageRating = 0.0;
  int _ratingCount = 0;

  @override
  void initState() {
    super.initState();
    // Setze die Anfangswerte basierend auf den übergebenen recipeDetails
    _currentRating = widget.recipeDetails.userRating?.score?.toDouble() ?? 0.0;
    _averageRating = widget.recipeDetails.averageRating ?? 0.0;
    _ratingCount = widget.recipeDetails.ratingCount ?? 0;

    // Lade die Benutzerbewertung nur, wenn die interne Rezept-ID (UUID) verfügbar ist.
    // Dies ist wichtig, falls die initialen Daten keine User-Bewertung enthielten
    // oder wenn sich der User nach dem Laden der Seite anmeldet.
    if (widget.recipeDetails.id != null) {
      _fetchUserRating(); // Stellt sicher, dass die aktuellste Benutzerbewertung geladen wird
    } else {
      setState(() {
        _isLoading = false;
        // Wenn keine interne ID vorhanden ist, kann keine Bewertung abgerufen werden.
        // Die initialen Werte für AverageRating und Count bleiben wie aus RecipeDetails gesetzt.
      });
    }
  }

  // Diese Methode wird jetzt primär dazu verwendet, die eigene Bewertung des Nutzers zu aktualisieren
  // und sicherzustellen, dass sie aktuell ist.
  void _fetchUserRating() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final String? userId = ref.read(currentUserIdProvider);
    if (userId == null) {
      setState(() {
        _isLoading = false;
        // _currentRating bleibt 0.0, da kein Nutzer angemeldet ist
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

      // Hier wird nur die eigene Bewertung aktualisiert.
      // Die aggregierten Werte kommen idealerweise direkt aus recipeDetails
      // oder müssen bei einer Bewertung neu vom Backend abgerufen werden.
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

    setState(() {
      _errorMessage = null;
    });

    try {
      final ratingNotifier = legacy_provider.Provider.of<RatingNotifier>(context, listen: false);

      final Recipe recipeEntity = Recipe(
        id: widget.recipeDetails.id,
        spoonacularId: widget.recipeDetails.spoonacularId,
        title: widget.recipeDetails.title,
        imageUrl: widget.recipeDetails.image ?? '',
      );

      await ratingNotifier.addOrUpdateRecipeRating(
        userId: userId,
        spoonacularId: widget.recipeDetails.spoonacularId,
        score: newRating.toInt(),
        recipe: recipeEntity,
      );

      setState(() {
        _currentRating = newRating; // Eigene Bewertung aktualisieren
        _isLoading = false; // Ladezustand hier auf false setzen, da die Operation abgeschlossen ist
      });
      _showSnackBar('Rating saved successfully!');

    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to save rating: $e';
        _isLoading = false; // Fehler aufgetreten, Ladezustand beenden
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
    final theme = Theme.of(context);

    // Initialisiere die Werte mit denen aus recipeDetails, falls sie vorhanden sind
    // und noch nicht über _fetchUserRating aktualisiert wurden.
    // Dies ist besonders wichtig, wenn der User nicht angemeldet ist,
    // damit trotzdem die Durchschnittsbewertung angezeigt wird.
    final double displayAverageRating = widget.recipeDetails.averageRating ?? 0.0;
    final int displayRatingCount = widget.recipeDetails.ratingCount ?? 0;
    final double displayUserRating = widget.recipeDetails.userRating?.score?.toDouble() ?? 0.0;


    if (_isLoading && userId != null) { // Zeige Ladeindikator nur, wenn wir spezifisch eine Nutzerbewertung laden
      return Center(child: CircularProgressIndicator(strokeWidth: 2, color: theme.colorScheme.primary));
    }

    // Wenn kein Benutzer angemeldet ist, zeige nur die durchschnittliche Bewertung an
    // und biete keine Interaktion zur eigenen Bewertung an.
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

    // Wenn ein Benutzer angemeldet ist:
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_errorMessage != null)
          Text(
            _errorMessage!,
            style: const TextStyle(color: Colors.red, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        // Durchschnittliche Bewertung und Anzahl der Bewertungen
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            return Icon(
              index < displayAverageRating.round() ? Icons.star : Icons.star_border,
              color: Colors.amber[700],
              size: 24, // Etwas kleiner für die Durchschnittsanzeige
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
        // Eigene Bewertung und Interaktion zum Bewerten
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
                index < _currentRating ? Icons.star : Icons.star_border, // Zeigt die EIGENE Bewertung an
                color: Colors.blueAccent, // Eine andere Farbe, um die eigene Bewertung abzuheben
                size: 36, // Größer, um Interaktion zu zeigen
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