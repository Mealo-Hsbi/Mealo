import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/recipe/presentation/widgets/recipe_sections/recipe_rating_widget.dart';
import 'package:frontend/utils/extensions.dart';
import 'package:provider/provider.dart' as provider;

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
  @override
  void initState() {
    super.initState();
    debugPrint('[RecipeInteractionSection] initState called.');
    // Starte die Initialisierung des Notifiers sofort nach dem ersten Frame.
    // Dies gibt Flutter Zeit, das Widget zu mounten und den Kontext verfügbar zu machen.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeFavoriteNotifier();
    });
  }

  void _initializeFavoriteNotifier() async {
    final asyncAuthUser = ref.read(authStateChangesProvider); // Lese den aktuellen Wert
    final String? currentUserId = await asyncAuthUser.when(
      data: (user) => user?.uid,
      loading: () => null,
      error: (err, stack) => null,
    );

    // Wenn keine User-ID verfügbar ist, können wir den Notifier nicht initialisieren.
    if (currentUserId == null) {
      debugPrint('[RecipeInteractionSection] _initializeFavoriteNotifier: No currentUserId, skipping FavoriteNotifier init.');
      return;
    }

    // Holen Sie den Notifier mit listen: false, da wir ihn nur initial triggern wollen.
    final favoriteNotifier = provider.Provider.of<FavoriteNotifier>(context, listen: false);
    
    // Rufen Sie die neue `init` Methode des Notifiers auf.
    // Diese Methode enthält die Logik, ob die Favoriten neu geladen werden müssen.
    debugPrint('[RecipeInteractionSection] Calling favoriteNotifier.init with userId: $currentUserId');
    await favoriteNotifier.init(currentUserId);
    debugPrint('[RecipeInteractionSection] favoriteNotifier.init completed.');
  }

  @override
  Widget build(BuildContext context) {
    final asyncAuthUser = ref.watch(authStateChangesProvider);
    final String? currentUserId = asyncAuthUser.when(
      data: (user) => user?.uid,
      loading: () => null,
      error: (err, stack) => null,
    );

    // Hier lauschen wir auf den FavoriteNotifier, um bei Änderungen neu zu rendern.
    final favoriteNotifier = provider.Provider.of<FavoriteNotifier>(context);
    final String? internalRecipeId = widget.recipeDetails.id;
    final theme = Theme.of(context);

    // Bestimme, ob Interaktionen möglich sind (User angemeldet, Rezept-ID vorhanden)
    final bool canInteract = currentUserId != null && internalRecipeId != null;

    // --- Allgemeine Lade- und Fehlerbehandlung (für Auth-Status oder fehlende Interaktionsdaten) ---
    // Dies ist der Ladekreis, wenn der Anmeldestatus des Benutzers noch ermittelt wird,
    // ODER wenn die notwendigen IDs fehlen.
    if (asyncAuthUser.isLoading) {
      debugPrint('[RecipeInteractionSection] Build: Auth loading, show general loader.');
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Center(
          child: CircularProgressIndicator(strokeWidth: 2, color: theme.colorScheme.primary),
        ),
      );
    }
    
    // Wenn Interaktion nicht möglich (z.B. nicht eingeloggt oder Rezept-ID fehlt)
    if (!canInteract) {
      debugPrint('[RecipeInteractionSection] Build: Cannot interact. UserID: $currentUserId, RecipeID: $internalRecipeId. Show login message.');
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

    // --- Favoriten-UI mit Ladeanzeige für den initialen Fetch des Herzens ---
    // `favoriteNotifier.isLoading` spiegelt den Ladezustand wider (initialer Fetch oder toggle).
    // `favoriteNotifier.status == FavoriteStatus.initial` stellt sicher, dass wir laden,
    // wenn der Notifier noch keine Daten hat.
    final bool showFavoriteLoader = favoriteNotifier.isLoading || favoriteNotifier.status == FavoriteStatus.initial;
    
    // Favoritenstatus: Wenn geladen wird, ist es standardmäßig false, sonst der tatsächliche Status.
    final bool isFavorited = showFavoriteLoader
        ? false 
        : favoriteNotifier.isRecipeCurrentlyFavorited(internalRecipeId!);

    debugPrint('[RecipeInteractionSection] Build: Recipe ${internalRecipeId ?? 'N/A'} showFavoriteLoader: $showFavoriteLoader, isFavorited: $isFavorited (Notifier status: ${favoriteNotifier.status})');

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
              // Conditional rendering: Loader or Heart Icon
              showFavoriteLoader
                  ? SizedBox( // Bietet Platz für den Ladeindikator
                      width: 30, 
                      height: 30,
                      child: CircularProgressIndicator(strokeWidth: 2, color: theme.colorScheme.primary),
                    )
                  : IconButton(
                      icon: Icon(
                        isFavorited ? Icons.favorite : Icons.favorite_border,
                        color: isFavorited ? Colors.redAccent : theme.colorScheme.onSurface.withOpacity(0.6),
                        size: 30,
                      ),
                      // Der Button ist deaktiviert, wenn Interaktion nicht möglich
                      // oder wenn der Notifier gerade eine Operation ausführt (`isLoading`).
                      onPressed: (!canInteract || favoriteNotifier.isLoading) 
                          ? null 
                          : () async {
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
                                }
                              }
                            },
                    ),
            ],
          ),
        ],
      ),
    );
  }
}