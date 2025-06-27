// lib/features/recipe/presentation/provider/favorite_notifier.dart

import 'package:flutter/material.dart';
import 'package:frontend/core/error/failures.dart'; // Ihre Failure-Klassen
import 'package:frontend/features/recipe/domain/entities/favorite.dart';
import 'package:frontend/features/recipe/domain/entities/recipe.dart';
import 'package:frontend/features/recipe/domain/usecases/add_favorite_recipe.dart';
import 'package:frontend/features/recipe/domain/usecases/remove_favorite_recipe.dart';
import 'package:frontend/features/recipe/domain/usecases/get_favorite_recipes.dart';
import 'package:frontend/features/recipe/domain/usecases/is_recipe_favorited.dart';

// Enum für den Zustand, falls Sie detailliertere Lade-/Fehlerzustände abbilden möchten
enum FavoriteStatus { initial, loading, loaded, error }

class FavoriteNotifier extends ChangeNotifier {
  // Use Cases, die über den Konstruktor injiziert werden
  final AddFavoriteRecipe addFavoriteRecipeUseCase;
  final RemoveFavoriteRecipe removeFavoriteRecipeUseCase;
  final GetFavoriteRecipes getFavoriteRecipesUseCase;
  final IsRecipeFavorited isRecipeFavoritedUseCase;

  // Zustand der Favoriten
  List<Favorite> _favoriteRecipes = [];
  List<Favorite> get favoriteRecipes => _favoriteRecipes;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  FavoriteStatus _status = FavoriteStatus.initial;
  FavoriteStatus get status => _status;

  // Ein Map, um den Favoritenstatus einzelner Rezepte schnell nachzuschlagen
  // Key: interne recipeId (UUID), Value: true/false
  final Map<String, bool> _recipeFavoritedStatus = {};
  bool isRecipeCurrentlyFavorited(String recipeId) => _recipeFavoritedStatus[recipeId] ?? false;


  FavoriteNotifier({
    required this.addFavoriteRecipeUseCase,
    required this.removeFavoriteRecipeUseCase,
    required this.getFavoriteRecipesUseCase,
    required this.isRecipeFavoritedUseCase,
  });

  // --- Methoden für Favoriten ---

  Future<void> addFavorite(String userId, int? spoonacularId, Recipe recipe) async {
    _setLoading();
    try {
      // KORRIGIERTER AUFRUF: explizit benannte Parameter verwenden
      await addFavoriteRecipeUseCase(
        userId: userId,
        spoonacularId: spoonacularId,
        recipe: recipe,
      );
      // Wenn erfolgreich, Favoritenliste aktualisieren und Status für das spezifische Rezept setzen
      _recipeFavoritedStatus[recipe.id!] = true; // Annahme: recipe.id ist die interne UUID nach dem Speichern
      await fetchFavoriteRecipes(userId); // Liste aktualisieren
      _setStatus(FavoriteStatus.loaded);
    } on Failure catch (e) {
      _setError(e.message);
    }
  }

  Future<void> removeFavorite(String userId, String favoriteId) async {
    _setLoading();
    try {
      // KORRIGIERTER AUFRUF
      await removeFavoriteRecipeUseCase(
        userId: userId,
        favoriteId: favoriteId,
      );
      // Wenn erfolgreich, Favoritenliste aktualisieren und Status für das spezifische Rezept löschen
      // Wir müssen hier die Recipe ID finden, da removeFavoriteUseCase nur die Favorite ID nimmt
      _favoriteRecipes.removeWhere((fav) {
        if (fav.id == favoriteId) {
          _recipeFavoritedStatus.remove(fav.recipe.id); // Entferne den Status anhand der Recipe ID
          return true;
        }
        return false;
      });
      _favoriteRecipes.removeWhere((fav) => fav.id == favoriteId); // Redundant, aber schadet nicht.
      _setStatus(FavoriteStatus.loaded);
      notifyListeners(); // Benachrichtige die Listener direkt nach dem Löschen
    } on Failure catch (e) {
      _setError(e.message);
    }
  }

  Future<void> fetchFavoriteRecipes(String userId) async {
    _setLoading();
    try {
      // KORRIGIERTER AUFRUF
      _favoriteRecipes = await getFavoriteRecipesUseCase(
        userId: userId,
      );
      // Beim Abrufen aller Favoriten, auch deren Status in der Map aktualisieren
      _recipeFavoritedStatus.clear();
      for (var fav in _favoriteRecipes) {
        if (fav.recipe.id != null) { // Stelle sicher, dass die Recipe ID nicht null ist
          _recipeFavoritedStatus[fav.recipe.id!] = true;
        }
      }
      _setStatus(FavoriteStatus.loaded);
    } on Failure catch (e) {
      _setError(e.message);
    }
  }

  Future<void> checkRecipeFavoritedStatus(String userId, String recipeId) async {
    _setLoading();
    try {
      // KORRIGIERTER AUFRUF
      final isFavorited = await isRecipeFavoritedUseCase(
        userId: userId,
        recipeId: recipeId,
      );
      _recipeFavoritedStatus[recipeId] = isFavorited;
      _setStatus(FavoriteStatus.loaded);
    } on Failure catch (e) {
      _setError(e.message);
    }
  }

  // --- Hilfsmethoden für den Zustand ---
  void _setLoading() {
    _isLoading = true;
    _errorMessage = null;
    _status = FavoriteStatus.loading;
    notifyListeners();
  }

  void _setError(String message) {
    _isLoading = false;
    _errorMessage = message;
    _status = FavoriteStatus.error;
    notifyListeners();
  }

  void _setStatus(FavoriteStatus newStatus) {
    _isLoading = false; // Normalerweise nicht mehr laden, wenn Status sich ändert
    _status = newStatus;
    if (newStatus == FavoriteStatus.loaded) {
      _errorMessage = null; // Fehler zurücksetzen bei Erfolg
    }
    notifyListeners();
  }

  // Diese Methode kann nützlich sein, wenn sich der User ändert oder ausgeloggt wird
  void reset() {
    _favoriteRecipes = [];
    _recipeFavoritedStatus.clear();
    _isLoading = false;
    _errorMessage = null;
    _status = FavoriteStatus.initial;
    notifyListeners();
  }
}