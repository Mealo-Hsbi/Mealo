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

  final Map<String, bool> _recipeFavoritedStatus = {};
  final Map<String, String?> _recipeFavoriteIds = {};
  final Map<String, bool> _recipeLoadingStatus = {};

  bool isRecipeCurrentlyFavorited(String recipeId) => _recipeFavoritedStatus[recipeId] ?? false;
  String? getFavoriteIdForRecipe(String recipeId) => _recipeFavoriteIds[recipeId];
  bool isRecipeCheckingFavoriteStatus(String recipeId) => _recipeLoadingStatus[recipeId] ?? false;
  bool isRecipeStatusInCache(String recipeId) => _recipeFavoritedStatus.containsKey(recipeId);

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

      _recipeFavoritedStatus.clear();
      _recipeFavoriteIds.clear();

      for (var fav in favorites) {
        final id = fav.recipe.id;
        if (id != null) {
          _recipeFavoritedStatus[id] = true;
          _recipeFavoriteIds[id] = fav.id;
        }
      }

      _setStatus(FavoriteStatus.loaded);
    } on Failure catch (e) {
      _setError(e.message);
    } catch (e) {
      _setError('Ein unerwarteter Fehler ist aufgetreten: $e');
      _recipeFavoritedStatus.clear();
      _recipeFavoriteIds.clear();
    }
  }

  Future<void> toggleFavorite({
    required String userId,
    required int? spoonacularId,
    required Recipe recipe,
  }) async {
    final recipeId = recipe.id?.toString();
    if (recipeId == null) {
      _setError("Rezept-ID fehlt.");
      return;
    }

    _recipeLoadingStatus[recipeId] = true;
    notifyListeners();

    try {
      if (isRecipeCurrentlyFavorited(recipeId)) {
        final favoriteId = _recipeFavoriteIds[recipeId];
        if (favoriteId == null) {
          _setError('Favorite-ID fehlt. Bitte Seite neu laden.');
          _recipeLoadingStatus.remove(recipeId);
          notifyListeners();
          return;
        }

        await removeFavoriteRecipeUseCase(userId: userId, favoriteId: favoriteId);
        _recipeFavoritedStatus[recipeId] = false;
        _recipeFavoriteIds.remove(recipeId);
        _favoriteRecipes.removeWhere((fav) => fav.id == favoriteId);
      } else {
        final newFavorite = await addFavoriteRecipeUseCase(
          userId: userId,
          spoonacularId: spoonacularId,
          recipe: recipe,
        );
        _recipeFavoritedStatus[recipeId] = true;
        _recipeFavoriteIds[recipeId] = newFavorite.id;
        _favoriteRecipes.add(newFavorite);
      }
    } on Failure catch (e) {
      await fetchFavoriteRecipes(userId);
      _setError(e.message);
    } catch (e) {
      _setError('Fehler beim Ändern des Favoritenstatus: $e');
    } finally {
      _recipeLoadingStatus.remove(recipeId);
      notifyListeners();
    }
  }

  void reset() {
    _favoriteRecipes = [];
    _recipeFavoritedStatus.clear();
    _recipeFavoriteIds.clear();
    _recipeLoadingStatus.clear();
    _isLoadingGlobal = false;
    _errorMessage = null;
    _status = FavoriteStatus.initial;
    _lastLoadedUserId = null;
    notifyListeners();
  }
}
