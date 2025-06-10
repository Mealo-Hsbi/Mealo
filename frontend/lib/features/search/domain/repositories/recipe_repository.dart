// lib/features/search/domain/repositories/recipe_repository.dart

import 'package:frontend/common/models/recipe.dart';
import 'package:frontend/common/models/recipe/recipe_details.dart';
import 'package:frontend/common/models/ingredient.dart'; // Keep if you use Ingredient objects elsewhere, otherwise can remove.

abstract class RecipeRepository {
  // NEW: Method for text-based recipe search
  Future<List<Recipe>> searchRecipesByQuery({
    required String query,
    int offset,
    int number,
    String? sortBy,
    String? sortDirection,
    Map<String, dynamic>? filters,
  });

  // NEW: Method for ingredient-based recipe search
  Future<List<Recipe>> searchRecipesByIngredients({
    required List<String> ingredients,
    int offset,
    int number,
    int? maxMissingIngredients,
  });

  Future<RecipeDetails> getRecipeDetails(int recipeId);
}