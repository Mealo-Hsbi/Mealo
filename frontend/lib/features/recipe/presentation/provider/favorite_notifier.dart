// lib/features/recipe/presentation/provider/favorite_notifier.dart

import 'package:flutter/material.dart';
import 'package:frontend/core/error/failures.dart';
import 'package:frontend/features/recipe/domain/entities/favorite.dart';
import 'package:frontend/features/recipe/domain/entities/recipe.dart';
import 'package:frontend/features/recipe/domain/usecases/add_favorite_recipe.dart';
import 'package:frontend/features/recipe/domain/usecases/remove_favorite_recipe.dart';
import 'package:frontend/features/recipe/domain/usecases/get_favorite_recipes.dart';
// import 'package:frontend/features/recipe/domain/usecases/is_recipe_favorited.dart'; // Dieser UseCase wird nicht mehr direkt im Notifier benötigt, da fetchFavoriteRecipes alle Infos holt.

enum FavoriteStatus { initial, loading, loaded, error }

class FavoriteNotifier extends ChangeNotifier {
  final AddFavoriteRecipe addFavoriteRecipeUseCase;
  final RemoveFavoriteRecipe removeFavoriteRecipeUseCase;
  final GetFavoriteRecipes getFavoriteRecipesUseCase;
  // final IsRecipeFavorited isRecipeFavoritedUseCase; // Entfernt, da getFavoriteRecipesUseCase dies abdeckt

  List<Favorite> _favoriteRecipes = [];
  List<Favorite> get favoriteRecipes => _favoriteRecipes;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  FavoriteStatus _status = FavoriteStatus.initial;
  FavoriteStatus get status => _status;

  // NEU: Speichere den zuletzt geladenen UserId, um Redundanz zu vermeiden
  String? _lastLoadedUserId; 

  // Cache für den Favoritenstatus einzelner Rezepte und deren Favorite-IDs
  final Map<String, bool> _recipeFavoritedStatus = {};
  final Map<String, String?> _recipeFavoriteIds = {};

  // Die Getter bleiben wie sie sind
  bool isRecipeCurrentlyFavorited(String recipeId) => _recipeFavoritedStatus[recipeId] ?? false;
  String? getFavoriteIdForRecipe(String recipeId) => _recipeFavoriteIds[recipeId];


  FavoriteNotifier({
    required this.addFavoriteRecipeUseCase,
    required this.removeFavoriteRecipeUseCase,
    required this.getFavoriteRecipesUseCase,
    // required this.isRecipeFavoritedUseCase, // Entfernt
  });

  // Hilfsmethoden für Zustandsänderungen
  void _setLoading() {
    _isLoading = true;
    _errorMessage = null;
    _status = FavoriteStatus.loading;
    notifyListeners();
    debugPrint('[FavoriteNotifier] State: Loading, _isLoading: true');
  }

  void _setError(String message) {
    _isLoading = false;
    _errorMessage = message;
    _status = FavoriteStatus.error;
    notifyListeners();
    debugPrint('[FavoriteNotifier] State: Error, Message: $message');
  }

  void _setStatus(FavoriteStatus newStatus) {
    _isLoading = false; // Nach dem Ladevorgang ist isLoading immer false
    _status = newStatus;
    if (newStatus == FavoriteStatus.loaded) {
      _errorMessage = null;
    }
    notifyListeners();
    debugPrint('[FavoriteNotifier] State: $newStatus, _isLoading: false');
  }

  // Initialisierungslogik des Notifiers
  // Diese Methode sollte einmal aufgerufen werden, wenn der Notifier
  // mit dem aktuellen Benutzer-Kontext verknüpft wird.
  // Sie ist der primäre Weg, um die Favoriten beim App-Start/Login zu laden.
  Future<void> init(String userId) async {
    // Nur laden, wenn sich der Benutzer geändert hat ODER der Status nicht geladen ist
    // UND keine andere Ladung im Gange ist.
    if (_lastLoadedUserId != userId || (_status != FavoriteStatus.loaded && !_isLoading)) {
      debugPrint('[FavoriteNotifier] init: User changed or data not loaded. Fetching favorites for $userId.');
      _lastLoadedUserId = userId; // Aktualisiere den zuletzt geladenen userId
      await fetchFavoriteRecipes(userId); // Rufe den Fetch auf und warte darauf
    } else {
      debugPrint('[FavoriteNotifier] init: Favorites already loaded for user $userId, skipping fetch.');
    }
  }

  // Diese Methode holt ALLE Favoriten für einen Benutzer und füllt den Cache
  // `@override` entfernt, da dies keine Methode einer ChangeNotifier-Basisklasse ist,
  // es sei denn, du hast eine benutzerdefinierte Basisklasse mit dieser Signatur.
  // Wenn ja, behalte @override.
  Future<void> fetchFavoriteRecipes(String userId) async {
    // Zusätzliche Prüfung, um doppelte Fetches zu verhindern, wenn sie durch UI-Events ausgelöst werden.
    if (_isLoading && _status == FavoriteStatus.loading) {
        debugPrint('[FavoriteNotifier] fetchFavoriteRecipes: Already in loading state, skipping new fetch.');
        return;
    }
    if (_status == FavoriteStatus.loaded && _lastLoadedUserId == userId) {
        debugPrint('[FavoriteNotifier] fetchFavoriteRecipes: Data already loaded for this user, skipping fetch.');
        return;
    }

    _setLoading(); // Setzt _isLoading = true und _status = loading, ruft notifyListeners auf
    debugPrint('[FavoriteNotifier] fetchFavoriteRecipes starting for userId: $userId');
    try {
      final List<Favorite> favorites = await getFavoriteRecipesUseCase(userId: userId);

      _favoriteRecipes = favorites;
      _recipeFavoritedStatus.clear();
      _recipeFavoriteIds.clear();
      for (var fav in _favoriteRecipes) {
        if (fav.recipe.id != null) {
          _recipeFavoritedStatus[fav.recipe.id!] = true;
          _recipeFavoriteIds[fav.recipe.id!] = fav.id;
          debugPrint('[FavoriteNotifier] Added favorite (from fetchAll) for recipe ID: ${fav.recipe.id!} (Favorite ID: ${fav.id})');
        } else {
          debugPrint('[FavoriteNotifier] Warning: Favorite without recipe.id found: ${fav.id}');
        }
      }
      _setStatus(FavoriteStatus.loaded); // Setzt _isLoading = false und _status = loaded, ruft notifyListeners auf
      debugPrint('[FavoriteNotifier] Successfully fetched ${favorites.length} favorite recipes. Current _recipeFavoritedStatus: $_recipeFavoritedStatus');
    } on Failure catch (e) {
      _setError(e.message); // Setzt _isLoading = false und _status = error, ruft notifyListeners auf
      debugPrint('[FavoriteNotifier] Error fetching favorite recipes: ${e.message}');
    } catch (e) {
      _setError('An unexpected error occurred during fetching favorite recipes: ${e.toString()}');
      _recipeFavoritedStatus.clear(); // Bei unerwartetem Fehler auch den Cache leeren
      _recipeFavoriteIds.clear();
      debugPrint('[FavoriteNotifier] Unexpected error fetching favorite recipes: $e');
    }
  }

  // Die toggleFavorite Methode bleibt so, wie du sie hattest.
  // Sie nutzt die bereits geladenen Daten oder aktualisiert sie.
  Future<void> toggleFavorite({
    required String userId,
    required int? spoonacularId,
    required Recipe recipe,
  }) async {
    if (recipe.id == null) {
      _setError("Recipe ID is missing for favoriting operation.");
      return;
    }

    // Setzt isLoading = true, aber hier wollen wir keine globale Statusänderung auf 'loading'
    // für den gesamten Notifier, da der Hauptstatus 'loaded' bleiben sollte.
    // Daher nur isLoading temporär setzen und notifyListeners aufrufen.
    _isLoading = true;
    _errorMessage = null; // Lösche vorherige Fehlermeldungen für diesen Vorgang
    notifyListeners(); // UI sofort aktualisieren (z.B. Button deaktivieren)

    final String recipeId = recipe.id!;
    debugPrint('[FavoriteNotifier] toggleFavorite called for recipeId: $recipeId, current status: ${isRecipeCurrentlyFavorited(recipeId)}');

    try {
      if (isRecipeCurrentlyFavorited(recipeId)) {
        final String? favoriteId = _recipeFavoriteIds[recipeId];
        if (favoriteId == null) {
          _setError('Cannot unfavorite: Favorite ID for this recipe is missing locally. Please reload the page.');
          _isLoading = false; // Wichtig: isLoading zurücksetzen bei Fehler
          notifyListeners();
          return;
        }

        await removeFavoriteRecipeUseCase(
          userId: userId,
          favoriteId: favoriteId,
        );

        _recipeFavoritedStatus[recipeId] = false;
        _recipeFavoriteIds.remove(recipeId);
        _favoriteRecipes.removeWhere((fav) => fav.id == favoriteId); // Stelle sicher, dass `fav.id` und `favoriteId` übereinstimmen

      } else {
        final Favorite newFavorite = await addFavoriteRecipeUseCase(
          userId: userId,
          spoonacularId: spoonacularId,
          recipe: recipe,
        );

        _recipeFavoritedStatus[recipeId] = true;
        _recipeFavoriteIds[recipeId] = newFavorite.id;
        _favoriteRecipes.add(newFavorite);
      }
      debugPrint('[FavoriteNotifier] Successfully toggled recipe: $recipeId');
      _isLoading = false; // Erfolg: isLoading zurücksetzen
      _errorMessage = null; // Fehler bei Erfolg löschen
      notifyListeners(); // UI final aktualisieren

    } on Failure catch (e) {
      // Wenn ein Fehler auftritt, Zustand zurücksetzen, falls er optimistich geändert wurde
      if (isRecipeCurrentlyFavorited(recipeId)) { // Wenn wir dachten, es ist jetzt favorisiert, aber ein Fehler kam
        if (!isRecipeCurrentlyFavorited(recipeId)) { // Wenn wir es entfernt haben, aber es sollte bleiben
          // Logik um den Cache hier wiederherzustellen
          // Am besten ist es, wenn du eine Kopie vor der Änderung machst
          // und diese bei Fehler wiederherstellst.
          // Hier nur ein simpler Ansatz:
          _recipeFavoritedStatus[recipeId] = !isRecipeCurrentlyFavorited(recipeId); // Revert
          _favoriteRecipes = await getFavoriteRecipesUseCase(userId: userId); // Oder komplette Neuladung bei Fehler
        }
      } else { // Wenn wir dachten, es ist jetzt unfavorisiert, aber ein Fehler kam
        if (isRecipeCurrentlyFavorited(recipeId)) { // Wenn es hinzugefügt wurde, aber es sollte nicht
          // Rollback-Logik
        }
      }

      _setError(e.message); // Setzt isLoading = false und errorMessage
      debugPrint('[FavoriteNotifier] Error in toggleFavorite: ${e.message}');
    } catch (e) {
      _setError('An unexpected error occurred during toggle: ${e.toString()}');
      debugPrint('[FavoriteNotifier] Unexpected error in toggleFavorite: $e');
    }
    debugPrint('[FavoriteNotifier] After toggle, recipe $recipeId is now favorited: ${isRecipeCurrentlyFavorited(recipeId)}');
  }

  // Die reset Methode bleibt, da sie nützlich ist
  void reset() {
    debugPrint('[FavoriteNotifier] State Reset.');
    _favoriteRecipes = [];
    _recipeFavoritedStatus.clear();
    _recipeFavoriteIds.clear();
    _isLoading = false;
    _errorMessage = null;
    _status = FavoriteStatus.initial;
    _lastLoadedUserId = null; // Auch diesen zurücksetzen
    notifyListeners();
  }
}