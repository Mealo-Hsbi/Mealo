// lib/features/recipe/presentation/widgets/recipe_sections/recipe_rating_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/common/models/recipe/recipe_details.dart';
import 'package:frontend/features/auth/presentation/providers/auth_state_provider.dart'; // Für User-ID
import 'package:frontend/main.dart'; // Für scaffoldMessengerKey
import 'package:frontend/features/recipe/presentation/provider/rating_notifier.dart'; // Für den Notifier

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
  // Lokaler State für die Anzeige der Sterne, bevor die API-Antwort kommt
  int? _displayScore;
  String? _lastFetchedUserId;
  String? _lastFetchedInternalRecipeId;

  @override
  void initState() {
    super.initState();
    // Setze den initialen Score basierend auf der userRating, wenn vorhanden
    _displayScore = widget.recipeDetails.userRating?.score;
  }

  @override
  void didUpdateWidget(covariant RecipeRatingWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Wenn sich die recipeDetails ändern, aktualisiere den _displayScore
    if (widget.recipeDetails.userRating?.score != oldWidget.recipeDetails.userRating?.score) {
      setState(() {
        _displayScore = widget.recipeDetails.userRating?.score;
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Hole User ID
    final asyncAuthUser = ref.read(authStateChangesProvider);
    final String? currentUserId = asyncAuthUser.value?.uid;
    final String? internalRecipeId = widget.recipeDetails.id;

    // Trigger zum Laden der Benutzerbewertung, wenn User oder Rezept sich ändern
    if (currentUserId != null &&
        internalRecipeId != null &&
        (currentUserId != _lastFetchedUserId || internalRecipeId != _lastFetchedInternalRecipeId)) {

      _lastFetchedUserId = currentUserId;
      _lastFetchedInternalRecipeId = internalRecipeId;

      // API-Aufruf verzögern
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          final recipeRatingNotifier = ref.read(recipeRatingNotifierProvider.notifier);
          // Nur laden, wenn die Bewertung nicht bereits vom Backend geladen wurde
          // und der Notifier nicht schon lädt
          if (widget.recipeDetails.userRating == null && !recipeRatingNotifier.isLoading) {
             recipeRatingNotifier.fetchUserRecipeRating(currentUserId, internalRecipeId);
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Color primaryColor = theme.colorScheme.primary;
    final Color greyStarColor = Colors.grey[400]!; // Für unbewertete/durchschnittliche Sterne

    final asyncAuthUser = ref.watch(authStateChangesProvider);
    final String? currentUserId = asyncAuthUser.when(
      data: (user) => user?.uid,
      loading: () => null,
      error: (err, stack) => null,
    );

    final recipeRatingNotifier = ref.watch(recipeRatingNotifierProvider.notifier);
    // Bevorzugen wir den Score vom Notifier, falls er sich nach einer Interaktion ändert.
    // Ansonsten den initialen Score von recipeDetails oder den geladenen Score.
    final int? userScore = recipeRatingNotifier.userRating?.score ?? _displayScore ?? widget.recipeDetails.userRating?.score;

    final double? averageRating = widget.recipeDetails.averageRating;
    final int? ratingCount = widget.recipeDetails.ratingCount;

    // Hilfsfunktion zum Anzeigen von Sternen (statisch für Durchschnitt, interaktiv für Benutzer)
    Widget buildStarRow({
      required int filledStars,
      required Color filledColor,
      Color? borderColor, // Optional für Border-Sterne
      bool interactive = false,
      Function(int)? onStarTap,
    }) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(5, (index) {
          final int starNumber = index + 1;
          return IconButton(
            // Verwende Icon für statische Sterne, IconButton für interaktive
            icon: Icon(
              starNumber <= filledStars ? Icons.star : Icons.star_border,
              color: starNumber <= filledStars ? filledColor : greyStarColor,
              size: interactive ? 28 : 20, // Interaktive Sterne etwas größer
            ),
            padding: EdgeInsets.zero, // Kein Padding um die Icons
            constraints: BoxConstraints.tightFor(width: interactive ? 30 : 22, height: interactive ? 30 : 22), // Konsistente Größe
            onPressed: interactive && currentUserId != null && widget.recipeDetails.id != null && !recipeRatingNotifier.isLoading
                ? () {
                    // Update the local display score immediately for a snappier UI
                    setState(() {
                      _displayScore = starNumber;
                    });
                    // Then trigger the API call
                    onStarTap?.call(starNumber);
                  }
                : null, // Deaktiviert, wenn nicht interaktiv oder keine Interaktion möglich
          );
        }),
      );
    }

    // Wenn kein Benutzer angemeldet ist, zeige nur die durchschnittliche Bewertung (falls vorhanden)
    if (currentUserId == null) {
      if (averageRating != null && averageRating > 0 && ratingCount != null && ratingCount > 0) {
        return Column(
          children: [
            Text('Average Rating', style: theme.textTheme.titleSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                buildStarRow(
                  filledStars: averageRating.round(), // Runden für Anzeige
                  filledColor: primaryColor.withOpacity(0.8), // Leichte Transparenz für Durchschnitt
                ),
                const SizedBox(width: 8),
                Text(
                  '${averageRating.toStringAsFixed(1)} ($ratingCount reviews)',
                  style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface),
                ),
              ],
            ),
          ],
        );
      } else {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            'No ratings yet. Log in to be the first!',
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
        );
      }
    }

    // Wenn Benutzer angemeldet ist
    return Column(
      children: [
        // 1. Durchschnittliche Bewertung anzeigen (wenn vorhanden)
        if (averageRating != null && averageRating > 0 && ratingCount != null && ratingCount > 0)
          Column(
            children: [
              Text('Average Rating', style: theme.textTheme.titleSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  buildStarRow(
                    filledStars: averageRating.round(),
                    filledColor: primaryColor.withOpacity(0.8),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${averageRating.toStringAsFixed(1)} ($ratingCount reviews)',
                    style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
          ),
        
        // 2. Deine Bewertung als interaktive Sterne
        Text('Your Rating:', style: theme.textTheme.titleSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        buildStarRow(
          filledStars: userScore ?? 0, // Zeige den Score des Benutzers
          filledColor: primaryColor, // Volle Primärfarbe für Benutzerbewertung
          interactive: true,
          onStarTap: (score) async {
            // Stelle sicher, dass die internalRecipeId verfügbar ist
            if (widget.recipeDetails.id == null) {
              scaffoldMessengerKey.currentState?.showSnackBar(
                const SnackBar(content: Text('Cannot save rating: Recipe ID missing.')),
              );
              return;
            }

            try {
              // Rufe den Notifier auf, um die Bewertung zu speichern
              await recipeRatingNotifier.addOrUpdateRating(
                currentUserId!,
                widget.recipeDetails.spoonacularId,
                score,
                widget.recipeDetails.toEntity(), // Basisrezept-Daten als Entität
                comment: widget.recipeDetails.userRating?.comment, // Vorhandenen Kommentar übernehmen
              );

              // Snackbar für Erfolg anzeigen
              scaffoldMessengerKey.currentState?.showSnackBar(
                const SnackBar(content: Text('Rating saved successfully!')),
              );
            } catch (e) {
              // Snackbar für Fehler anzeigen
              scaffoldMessengerKey.currentState?.showSnackBar(
                SnackBar(content: Text('Failed to save rating: ${e.toString()}')),
              );
            }
          },
        ),
        // Lade-Indikator, wenn eine Bewertung gespeichert/aktualisiert wird
        if (recipeRatingNotifier.isLoading)
          const Padding(
            padding: EdgeInsets.only(top: 8.0),
            child: CircularProgressIndicator.adaptive(),
          ),
      ],
    );
  }
}
