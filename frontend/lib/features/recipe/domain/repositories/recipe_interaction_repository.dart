// lib/features/recipe/domain/repositories/recipe_interaction_repository.dart
import 'package:frontend/core/error/failures.dart';
import 'package:frontend/features/recipe/data/models/recipe_rating_response_model.dart';
import 'package:frontend/features/recipe/domain/entities/recipe.dart';
import 'package:frontend/features/recipe/domain/entities/favorite.dart';
import 'package:frontend/features/recipe/domain/entities/recipe_rating.dart';

abstract class RecipeInteractionRepository {
  // --- METHODEN für Favoriten ---
  Future<Favorite> addFavoriteRecipe(String userId, int? spoonacularId, Recipe recipe); // Change from void to Favorite

  Future<void> removeFavoriteRecipe(
      String userId, String favoriteId);

  Future<List<Favorite>> getFavoriteRecipes(String userId);
  Future<Favorite?> isRecipeFavorited(
      String userId, String recipeId);

  // --- METHODEN für Bewertungen ---
  Future<RecipeRatingResponseModel> addOrUpdateRecipeRating(
      String userId, int? spoonacularId, int score, Recipe recipe, {String? comment});
  Future<RecipeRating?> getUserRecipeRating(String userId, String recipeId);
}