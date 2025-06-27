// lib/features/recipe/domain/repositories/recipe_interaction_repository.dart
import 'package:frontend/core/error/failures.dart';
import 'package:frontend/features/recipe/domain/entities/recipe.dart';
import 'package:frontend/features/recipe/domain/entities/favorite.dart';
import 'package:frontend/features/recipe/domain/entities/recipe_rating.dart';

abstract class RecipeInteractionRepository {
  // --- METHODEN für Favoriten ---
  Future<void> addFavoriteRecipe(
      String userId,
      int? spoonacularId, // <-- GEÄNDERT: Jetzt nullable
      Recipe recipe);
  Future<void> removeFavoriteRecipe(
      String userId, String favoriteId);

  Future<List<Favorite>> getFavoriteRecipes(String userId);
  Future<bool> isRecipeFavorited(
      String userId, String recipeId);

  // --- METHODEN für Bewertungen ---
  Future<RecipeRating> addOrUpdateRecipeRating(
      String userId,
      int? spoonacularId, // <-- GEÄNDERT: Jetzt nullable
      int score,
      Recipe recipe,
      {String? comment});
  Future<RecipeRating?> getUserRecipeRating(
      String userId, String recipeId);
}