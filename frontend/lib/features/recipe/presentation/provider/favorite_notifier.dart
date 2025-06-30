import 'package:flutter/material.dart';
import 'package:frontend/core/error/failures.dart';
import 'package:frontend/features/recipe/domain/entities/favorite.dart';
import 'package:frontend/features/recipe/domain/entities/recipe.dart';
import 'package:frontend/features/recipe/domain/usecases/add_favorite_recipe.dart';
import 'package:frontend/features/recipe/domain/usecases/remove_favorite_recipe.dart';
import 'package:frontend/features/recipe/domain/usecases/get_favorite_recipes.dart';

enum FavoriteStatus { initial, loading, loaded, error }

class FavoriteNotifier extends ChangeNotifier {
  final AddFavoriteRecipe addFavoriteRecipeUseCase;
  final RemoveFavoriteRecipe removeFavoriteRecipeUseCase;
  final GetFavoriteRecipes getFavoriteRecipesUseCase;

  List<Favorite> _favoriteRecipes = [];
  List<Favorite> get favoriteRecipes => _favoriteRecipes;

  bool _isLoadingGlobal = false;
  bool get isLoading => _isLoadingGlobal;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  FavoriteStatus _status = FavoriteStatus.initial;
  FavoriteStatus get status => _status;

  String? _lastLoadedUserId;

  FavoriteNotifier({
    required this.addFavoriteRecipeUseCase,
    required this.removeFavoriteRecipeUseCase,
    required this.getFavoriteRecipesUseCase,
  });

  void _setLoading() {
    _isLoadingGlobal = true;
    _errorMessage = null;
    _status = FavoriteStatus.loading;
    notifyListeners();
  }

  void _setError(String message) {
    _isLoadingGlobal = false;
    _errorMessage = message;
    _status = FavoriteStatus.error;
    notifyListeners();
  }

  void _setStatus(FavoriteStatus newStatus) {
    _isLoadingGlobal = false;
    _status = newStatus;
    if (newStatus == FavoriteStatus.loaded) {
      _errorMessage = null;
    }
    notifyListeners();
  }

  Future<void> init(String userId) async {
    if (_lastLoadedUserId != userId || _status != FavoriteStatus.loaded) {
      _lastLoadedUserId = userId;
      await fetchFavoriteRecipes(userId);
    }
  }

  Future<void> fetchFavoriteRecipes(String userId) async {
    if (_isLoadingGlobal || (_status == FavoriteStatus.loaded && _lastLoadedUserId == userId)) {
      return;
    }

    _setLoading();

    try {
      final favorites = await getFavoriteRecipesUseCase(userId: userId);
      _favoriteRecipes = favorites;

      _setStatus(FavoriteStatus.loaded);
    } on Failure catch (e) {
      _setError(e.message);
    } catch (e) {
      _setError('Ein unerwarteter Fehler ist aufgetreten: $e');
    }
  }

  Future<void> toggleFavorite({
    required String userId,
    int? spoonacularId,
    String? internalRecipeId,
    required Recipe recipe,
  }) async {
    final recipeId = recipe.id?.toString();
    if (recipeId == null) {
      _setError("Rezept-ID fehlt.");
      return;
    }

    _setLoading();

    try {
      final isFavorited = _favoriteRecipes.any((fav) => fav.recipe.id?.toString() == recipeId);
      if (isFavorited) {
        final favorite = _favoriteRecipes.firstWhere((fav) => fav.recipe.id?.toString() == recipeId);
        final favoriteId = favorite.id;
        if (favoriteId == null) {
          _setError('Favorite-ID fehlt. Bitte Seite neu laden.');
          notifyListeners();
          return;
        }
        await removeFavoriteRecipeUseCase(userId: userId, favoriteId: favoriteId);
        _favoriteRecipes.removeWhere((fav) => fav.id == favoriteId);
      } else {
        final data = {
          'userId': userId,
          'spoonacularId': spoonacularId,
          'internalRecipeId': internalRecipeId,
          'recipeData': recipe.toJson(),
        };
        // Sende data an das Backend (z.B. via Dio oder ApiClient)
        // ...
        final newFavorite = await addFavoriteRecipeUseCase(
          userId: userId,
          spoonacularId: spoonacularId,
          recipe: recipe,
        );
        _favoriteRecipes.add(newFavorite);
      }
    } on Failure catch (e) {
      await fetchFavoriteRecipes(userId);
      _setError(e.message);
    } catch (e) {
      _setError('Fehler beim Ändern des Favoritenstatus: $e');
    } finally {
      _setStatus(FavoriteStatus.loaded);
      notifyListeners();
    }
  }

  void reset() {
    _favoriteRecipes = [];
    _isLoadingGlobal = false;
    _errorMessage = null;
    _status = FavoriteStatus.initial;
    _lastLoadedUserId = null;
    notifyListeners();
  }
}
