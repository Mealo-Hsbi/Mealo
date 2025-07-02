// lib/features/favorites/presentation/favorites_screen.dart (FINAL KORRIGIERTE VERSION)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as legacy_provider;
import 'package:frontend/features/recipe/domain/entities/recipe.dart' as detailed_recipe;
import 'package:frontend/common/models/recipe.dart' as common_recipe;
import 'package:frontend/features/auth/presentation/providers/auth_state_provider.dart';
import 'package:frontend/features/recipe/presentation/provider/favorite_notifier.dart';
import 'package:frontend/features/recipe/domain/entities/favorite.dart'; // Für das Favorite-Entity
// Importiere ParallaxRecipes, das deine Rezeptliste anzeigt
import 'package:frontend/features/recipe/presentation/widgets/recipe_list/parallax_recipes.dart';
// Du brauchst hier KEIN RecipeListItem mehr direkt, da ParallaxRecipes es intern nutzen sollte
import 'package:frontend/core/providers/app_providers.dart';
import 'package:provider/provider.dart' as provider;

class FavoritesScreen extends ConsumerStatefulWidget {
  const FavoritesScreen({super.key});

  @override
  ConsumerState<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends ConsumerState<FavoritesScreen> {
  String? _lastFetchedUserId; // Um zu verfolgen, ob der Benutzer gewechselt hat
  final ScrollController _scrollController = ScrollController(); // Für ParallaxRecipes

  @override
  void initState() {
    super.initState();
    // Der ScrollController wird benötigt, wenn ParallaxRecipes Lazy Loading unterstützt
    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        // Hier könntest du zukünftig eine "load more favorites"-Funktion aufrufen,
        // falls dein Backend Paginierung für Favoriten unterstützt.
        // Aktuell lädt favoriteNotifier.fetchFavoriteRecipes alle Favoriten auf einmal.
        debugPrint('[FavoritesScreen] Scrolled to end, but no further favorites to load (yet).');
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fetchFavoritesForCurrentUser();
  }

  void _fetchFavoritesForCurrentUser() {
    final asyncAuthUser = ref.read(authStateChangesProvider);
    final String? currentUserId = asyncAuthUser.value?.uid;

    final favoriteNotifier = legacy_provider.Provider.of<FavoriteNotifier>(
      context,
      listen: false,
    );

    debugPrint('[FavoritesScreen] _fetchFavoritesForCurrentUser: currentUserId: $currentUserId');
    debugPrint('[FavoritesScreen] _fetchFavoritesForCurrentUser: _lastFetchedUserId: $_lastFetchedUserId');
    debugPrint('[FavoritesScreen] _fetchFavoritesForCurrentUser: favoriteNotifier.status: ${favoriteNotifier.status}, favoriteNotifier.isLoading: ${favoriteNotifier.isLoading}');

    // Fall 1: Benutzer hat sich abgemeldet oder es ist kein Benutzer angemeldet
    if (currentUserId == null) {
      if (_lastFetchedUserId != null) {
        debugPrint('[FavoritesScreen] User logged out. Resetting FavoriteNotifier.');
        favoriteNotifier.reset();
        _lastFetchedUserId = null;
      } else {
        debugPrint('[FavoritesScreen] No user logged in. Skipping favorite fetch.');
      }
      return;
    }

    // Fall 2: Benutzer ist angemeldet, und wir müssen die Favoriten abrufen/aktualisieren
    if (_lastFetchedUserId != currentUserId ||
        favoriteNotifier.status == FavoriteStatus.initial ||
        (favoriteNotifier.status == FavoriteStatus.error && !favoriteNotifier.isLoading) ||
        (favoriteNotifier.status != FavoriteStatus.loaded && !favoriteNotifier.isLoading))
    {
      if (favoriteNotifier.isLoading) {
        debugPrint('[FavoritesScreen] FavoriteNotifier is already loading. Skipping new fetch.');
        return;
      }

      _lastFetchedUserId = currentUserId;

      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) return;
        debugPrint('[FavoritesScreen] PostFrameCallback: Calling fetchFavoriteRecipes for userId: $currentUserId');
        await favoriteNotifier.fetchFavoriteRecipes(currentUserId);
        debugPrint('[FavoritesScreen] PostFrameCallback: Favorite fetch completed. Status: ${favoriteNotifier.status}');
      });
    } else {
      debugPrint('[FavoritesScreen] Skipping favorite fetch: Conditions not met (e.g., already fetched, no change).');
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final favoriteNotifier = legacy_provider.Provider.of<FavoriteNotifier>(context);
    final asyncAuthUser = ref.watch(authStateChangesProvider);

    final String? currentUserId = asyncAuthUser.value?.uid;

    // ----- UI-Logik für verschiedene Zustände -----

    // 1. Authentifizierungs-Ladezustand
    if (asyncAuthUser.isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('Favorites')),
        body: const Center(child: Text('Checking login status...')),
      );
    }

    // 2. Kein Benutzer angemeldet
    if (currentUserId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Favorites')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(
              'Please log in to view your favorite recipes.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        ),
      );
    }

    // 3. Favoriten-Ladezustand (wenn Liste noch leer ist)
    if (favoriteNotifier.isLoading && favoriteNotifier.favoriteRecipes.isEmpty) {
      // Du könntest hier auch Skeletons anzeigen, wie in SearchScreen
      return Scaffold(
        appBar: AppBar(title: const Text('Favorites')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // 4. Fehlerzustand
    if (favoriteNotifier.status == FavoriteStatus.error) {
      return Scaffold(
        appBar: AppBar(title: const Text('Favorites')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  favoriteNotifier.errorMessage ?? 'Failed to load favorite recipes.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    // Erneuten Fetch triggern
                    _fetchFavoritesForCurrentUser();
                  },
                  child: const Text('Try again'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // 5. Keine Favoriten gefunden (nachdem Laden abgeschlossen ist)
    if (favoriteNotifier.favoriteRecipes.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Favorites')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(
              'You have no favorite recipes yet. Start exploring!',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        ),
      );
    }

    // 6. Favoriten anzeigen (erfolgreich geladen und Liste nicht leer)
    // Extrahiere die Rezepte aus den Favoriten-Objekten
    final List<detailed_recipe.Recipe> recipes = favoriteNotifier.favoriteRecipes.map((fav) => fav.recipe).toList();
    
    print('[FavoritesScreen] Loaded ${recipes.length} favorite recipes for user: $currentUserId');
    print('List: ${favoriteNotifier.favoriteRecipes}');


    final List<common_recipe.Recipe> recipesToShow = recipes.map((recipe) {
      return common_recipe.Recipe(
        id: recipe.spoonacularId,
        internalId: recipe.id,
        isInternal: recipe.spoonacularId == null,
        imageUrl: recipe.imageUrl ?? '',
        name: recipe.title ?? '',
        place:  '',
        averageRating: null,
        ratingCount: 0,
      );
    }).toList();


    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
        centerTitle: true,
      ),
      body: provider.Consumer<PremiumProvider>(
        builder: (context, premiumProvider, _) {
          return ParallaxRecipes(
            recipes: recipesToShow,
            scrollController: _scrollController,
            isLoadingMore: false,
            hasMore: false,
            currentSortOption: null,
            showAds: !premiumProvider.isPremium,
          );
        },
      ),
    );
  }
}