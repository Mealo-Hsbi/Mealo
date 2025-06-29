import 'package:flutter/material.dart';
import 'package:frontend/core/error/failures.dart';
import 'package:frontend/features/recipe/domain/entities/favorite.dart';
import 'package:frontend/features/recipe/domain/entities/recipe.dart';
import 'package:frontend/features/recipe/domain/usecases/add_favorite_recipe.dart';
import 'package:frontend/features/recipe/domain/usecases/remove_favorite_recipe.dart';
import 'package:frontend/features/recipe/domain/usecases/get_favorite_recipes.dart';
import 'package:frontend/features/recipe/domain/usecases/is_recipe_favorited.dart';

enum FavoriteStatus { initial, loading, loaded, error }

class FavoriteNotifier extends ChangeNotifier {
  final AddFavoriteRecipe addFavoriteRecipeUseCase;
  final RemoveFavoriteRecipe removeFavoriteRecipeUseCase;
  final GetFavoriteRecipes getFavoriteRecipesUseCase;
  final IsRecipeFavorited isRecipeFavoritedUseCase;

  List<Favorite> _favoriteRecipes = [];
  List<Favorite> get favoriteRecipes => _favoriteRecipes;

  bool _isLoadingGlobal = false;
  bool get isLoading => _isLoadingGlobal;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  FavoriteStatus _status = FavoriteStatus.initial;
  FavoriteStatus get status => _status;

  final Map<String, bool> _recipeFavoritedStatus = {};
  bool isRecipeCurrentlyFavorited(String recipeId) => _recipeFavoritedStatus[recipeId] ?? false;

  final Map<String, String?> _recipeFavoriteIds = {};
  String? getFavoriteIdForRecipe(String recipeId) => _recipeFavoriteIds[recipeId];

  final Map<String, bool> _recipeLoadingStatus = {};
  bool isRecipeCheckingFavoriteStatus(String recipeId) => _recipeLoadingStatus[recipeId] ?? false;

  // NEU HINZUGEFÜGT: Die fehlende Methode!
  bool isRecipeStatusInCache(String recipeId) => _recipeFavoritedStatus.containsKey(recipeId);


  FavoriteNotifier({
    required this.addFavoriteRecipeUseCase,
    required this.removeFavoriteRecipeUseCase,
    required this.getFavoriteRecipesUseCase,
    required this.isRecipeFavoritedUseCase,
  });

  void _setLoadingGlobal() {
    _isLoadingGlobal = true;
    _errorMessage = null;
    _status = FavoriteStatus.loading;
    notifyListeners();
    debugPrint('[FavoriteNotifier] State: Loading Global, _isLoadingGlobal: true');
  }

  void _setError(String message) {
    _isLoadingGlobal = false;
    _errorMessage = message;
    _status = FavoriteStatus.error;
    notifyListeners();
    debugPrint('[FavoriteNotifier] State: Error, Message: $message');
  }

  void _setStatus(FavoriteStatus newStatus) {
    _isLoadingGlobal = false;
    _status = newStatus;
    if (newStatus == FavoriteStatus.loaded) {
      _errorMessage = null;
    }
    notifyListeners();
    debugPrint('[FavoriteNotifier] State: $newStatus, _isLoadingGlobal: false');
  }

  Future<void> toggleFavorite({
    required String userId,
    required int? spoonacularId,
    required Recipe recipe,
  }) async {
    if (recipe.id == null) {
      _setError("Recipe ID is missing for favoriting operation.");
      return;
    }

    final String recipeId = recipe.id!;
    _recipeLoadingStatus[recipeId] = true;
    notifyListeners();
    debugPrint('[FavoriteNotifier] toggleFavorite called for recipeId: $recipeId, current status: ${isRecipeCurrentlyFavorited(recipeId)}');

    try {
      if (isRecipeCurrentlyFavorited(recipeId)) {
        final String? favoriteId = _recipeFavoriteIds[recipeId];
        if (favoriteId == null) {
          _setError('Cannot unfavorite: Favorite ID for this recipe is missing locally. Please reload the page.');
          _recipeLoadingStatus.remove(recipeId);
          notifyListeners();
          return;
        }

        await removeFavoriteRecipeUseCase(
          userId: userId,
          favoriteId: favoriteId,
        );

        _recipeFavoritedStatus[recipeId] = false;
        _recipeFavoriteIds.remove(recipeId);
        _favoriteRecipes.removeWhere((fav) => fav.id == favoriteId);
        debugPrint('[FavoriteNotifier] Successfully unfavorited recipe: $recipeId');

      } else {
        final Favorite newFavorite = await addFavoriteRecipeUseCase(
          userId: userId,
          spoonacularId: spoonacularId,
          recipe: recipe,
        );

        _recipeFavoritedStatus[recipeId] = true;
        _recipeFavoriteIds[recipeId] = newFavorite.id;
        _favoriteRecipes.add(newFavorite);
        debugPrint('[FavoriteNotifier] Successfully favorited recipe: $recipeId with Favorite ID: ${newFavorite.id}');
      }
      _recipeLoadingStatus.remove(recipeId);
      notifyListeners();
      debugPrint('[FavoriteNotifier] After toggle, recipe $recipeId is now favorited: ${isRecipeCurrentlyFavorited(recipeId)}');
    } on Failure catch (e) {
      _setError(e.message);
      _recipeLoadingStatus.remove(recipeId);
      notifyListeners();
      debugPrint('[FavoriteNotifier] Error in toggleFavorite: ${e.message}');
    } catch (e) {
      _setError('An unexpected error occurred during toggle: ${e.toString()}');
      _recipeLoadingStatus.remove(recipeId);
      notifyListeners();
      debugPrint('[FavoriteNotifier] Unexpected error in toggleFavorite: $e');
    }
  }

  Future<void> checkAndLoadInitialFavoriteStatus({
    required String userId,
    required String recipeId,
  }) async {
    if ((_recipeFavoritedStatus.containsKey(recipeId) && !isRecipeCheckingFavoriteStatus(recipeId)) || _isLoadingGlobal) {
        debugPrint('[FavoriteNotifier] Initial status for $recipeId already known in cache or global fetch in progress. Skipping API call.');
        return;
    }
    
    _recipeLoadingStatus[recipeId] = true;
    notifyListeners();
    debugPrint('[FavoriteNotifier] checkAndLoadInitialFavoriteStatus called for recipeId: $recipeId');

    try {
      final Favorite? favorite = await isRecipeFavoritedUseCase(
        userId: userId,
        recipeId: recipeId,
      );

      if (favorite != null) {
        _recipeFavoritedStatus[recipeId] = true;
        _recipeFavoriteIds[recipeId] = favorite.id;
        if (!_favoriteRecipes.any((fav) => fav.id == favorite.id)) {
          _favoriteRecipes.add(favorite);
        }
        debugPrint('[FavoriteNotifier] Recipe $recipeId is FAVORITED (from API check). Favorite ID: ${favorite.id}');
      } else {
        _recipeFavoritedStatus[recipeId] = false;
        _recipeFavoriteIds[recipeId] = null;
        _favoriteRecipes.removeWhere((fav) => fav.recipe.id == recipeId);
        debugPrint('[FavoriteNotifier] Recipe $recipeId is NOT favorited (from API check).');
      }
      _recipeLoadingStatus.remove(recipeId);
      notifyListeners();
    } on Failure catch (e) {
      _setError(e.message);
      _recipeFavoritedStatus[recipeId] = false;
      _recipeFavoriteIds[recipeId] = null;
      _recipeLoadingStatus.remove(recipeId);
      notifyListeners();
      debugPrint('[FavoriteNotifier] Error checking initial favorite status for $recipeId: ${e.message}');
    } catch (e) {
      _setError('An unexpected error occurred during initial check: ${e.toString()}');
      _recipeFavoritedStatus[recipeId] = false;
      _recipeFavoriteIds[recipeId] = null;
      _recipeLoadingStatus.remove(recipeId);
      notifyListeners();
      debugPrint('[FavoriteNotifier] Unexpected error checking initial favorite status for $recipeId: $e');
    }
  }

  @override
  Future<void> fetchFavoriteRecipes(String userId) async {
    if (_isLoadingGlobal) {
        debugPrint('[FavoriteNotifier] Global fetch already in progress. Skipping redundant fetch.');
        return;
    }
    _setLoadingGlobal();
    debugPrint('[FavoriteNotifier] fetchFavoriteRecipes called for userId: $userId');
    try {
      final List<Favorite> favorites = await getFavoriteRecipesUseCase(
        userId: userId,
      );

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
      _setStatus(FavoriteStatus.loaded);
      debugPrint('[FavoriteNotifier] Successfully fetched ${favorites.length} favorite recipes. Current _recipeFavoritedStatus: $_recipeFavoritedStatus');
    } on Failure catch (e) {
      _setError(e.message);
      debugPrint('[FavoriteNotifier] Error fetching favorite recipes: ${e.message}');
    } catch (e) {
      _setError('An unexpected error occurred during fetching favorite recipes: ${e.toString()}');
      _recipeFavoritedStatus.clear();
      _recipeFavoriteIds.clear();
      debugPrint('[FavoriteNotifier] Unexpected error fetching favorite recipes: $e');
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
    notifyListeners();
    debugPrint('[FavoriteNotifier] State Reset.');
  }
}