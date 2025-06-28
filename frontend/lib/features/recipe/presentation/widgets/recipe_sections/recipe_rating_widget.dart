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
  // _currentRating speichert die EIGENE Bewertung des Nutzers und wird sofort aktualisiert.
  double _currentRating = 0.0;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // _currentRating initialisiert sich aus den userRating Details.
    _currentRating = widget.recipeDetails.userRating?.score?.toDouble() ?? 0.0;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ratingNotifier = legacy_provider.Provider.of<RatingNotifier>(context, listen: false);
      // Setze initiale Werte im Notifier, falls noch nicht geschehen.
      if (ratingNotifier.averageRating == 0.0 && ratingNotifier.ratingCount == 0) {
        ratingNotifier.setInitialAverageRating(widget.recipeDetails.averageRating ?? 0.0);
        ratingNotifier.setInitialRatingCount(widget.recipeDetails.ratingCount ?? 0);
      }

      // Lade die Bewertung des Benutzers nur, wenn die interne Rezept-ID verfügbar ist.
      if (widget.recipeDetails.id != null) {
        _fetchUserRating(); // Stellt sicher, dass die neueste Nutzerbewertung geladen wird
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

    final ratingNotifier = legacy_provider.Provider.of<RatingNotifier>(context, listen: false);
    // Behalte den Ladezustand des Notifiers für den initialen Fetch bei,
    // damit der Ladekreis bei der ersten Anzeige erscheint, falls die Daten fehlen.
    ratingNotifier.setLoading(true);

    try {
      final existingRating = await ratingNotifier.getUserRecipeRating(
        userId: userId,
        recipeId: internalRecipeId,
      );

      if (mounted) {
        setState(() {
          // Aktualisiere _currentRating basierend auf der geladenen Bewertung
          _currentRating = existingRating?.score.toDouble() ?? 0.0;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Could not load your rating: $e';
          _currentRating = 0.0; // Setze auf 0 bei Fehler
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

    // SOFORTIGE AKTUALISIERUNG des lokalen States für visuelles Feedback
    setState(() {
      _currentRating = newRating;
      _errorMessage = null; // Alte Fehlermeldungen löschen
    });

    try {
      final Recipe recipeEntity = Recipe(
        id: widget.recipeDetails.id,
        spoonacularId: widget.recipeDetails.spoonacularId,
        title: widget.recipeDetails.title,
        imageUrl: widget.recipeDetails.image ?? '',
      );

      // Hier wird der Notifier-Aufruf verwendet, wie er ursprünglich war.
      // Er muss kein UserRating zurückgeben.
      await legacy_provider.Provider.of<RatingNotifier>(context, listen: false).addOrUpdateRecipeRating(
        userId: userId,
        spoonacularId: widget.recipeDetails.spoonacularId,
        score: newRating.toInt(),
        recipe: recipeEntity,
      );

      // Optional: Wenn der API-Aufruf fehlschlägt und die UI nicht sofort
      // zurückgesetzt wird, könnte hier nach dem Erfolg eine Überprüfung
      // oder eine erneute Abfrage des User-Ratings erfolgen,
      // um die Konsistenz zu gewährleisten, falls der lokale Zustand nicht 100% genau ist.
      // Aber für die "keine Ladeanzeige"-Anforderung ist das hier der Punkt des Erfolgs.

    } catch (e) {
      if (mounted) {
        // Bei Fehler: Snackbar anzeigen und die Sterne auf den Zustand VOR der Änderung zurücksetzen
        final ratingNotifier = legacy_provider.Provider.of<RatingNotifier>(context, listen: false);
        _showSnackBar('Failed to save rating: ${ratingNotifier.errorMessage ?? 'Unknown error'}');

        // WICHTIG: Im Fehlerfall die Bewertung des Nutzers erneut vom Backend laden,
        // um den lokalen _currentRating-Wert auf den echten, zuletzt gespeicherten Wert zu setzen.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _fetchUserRating();
          }
        });
      }
    }
    // Kein finally-Block hier, da keine spezielle Ladeanzeige verwaltet wird
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String? userId = ref.watch(currentUserIdProvider);
    final theme = Theme.of(context);

    // Watch the RatingNotifier for changes to average rating and count
    final ratingNotifier = legacy_provider.Provider.of<RatingNotifier>(context);
    final double displayAverageRating = ratingNotifier.averageRating;
    final int displayRatingCount = ratingNotifier.ratingCount;

    // Behalte den Ladekreis NUR für den initialen Fetch, wenn der Notifier lädt
    // und noch KEINE Daten für die eigene Bewertung oder den Durchschnitt vorhanden sind.
    if (ratingNotifier.isLoading && userId != null && _currentRating == 0.0 && displayRatingCount == 0) {
      return Center(child: CircularProgressIndicator(strokeWidth: 2, color: theme.colorScheme.primary));
    }

    // Wenn kein Benutzer angemeldet ist
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
        if (ratingNotifier.errorMessage != null)
          Text(
            ratingNotifier.errorMessage!,
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
              size: 24,
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
        // Eigene Bewertung des Benutzers und Interaktion zum Bewerten
        Text(
          'Your rating:',
          style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface),
        ),
        const SizedBox(height: 4), // Konstante Höhe für Layout-Stabilität

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            return GestureDetector(
              // `onTap` ist immer aktiv. Die Sterne ändern sich SOFORT (durch setState),
              // und werden bei Erfolg oder Misserfolg durch den Backend-Call korrigiert.
              onTap: () => _handleRatingSelected((index + 1).toDouble()),
              child: Icon(
                index < _currentRating ? Icons.star : Icons.star_border, // Zeigt DEINE Bewertung (lokaler State)
                color: Colors.blueAccent, // Andere Farbe zur Hervorhebung der eigenen Bewertung
                size: 36, // Größer zur Anzeige der Interaktion
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