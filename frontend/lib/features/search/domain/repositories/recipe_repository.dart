// lib/features/search/domain/repositories/recipe_repository.dart

import 'package:frontend/common/models/recipe.dart'; // Your domain entity
import 'package:frontend/common/models/recipe_details.dart';

abstract class RecipeRepository {
  // This method should *return* domain entities (Recipe)
  // but it will internally deal with RecipeModel from the data source.
  Future<List<Recipe>> searchRecipes({ // Return type remains List<Recipe> here
    required String query,
    required List<String> ingredients,
    int offset,
    int number,
    // Map<String, dynamic>? filters,
    // String? sortBy,
    // String? sortDirection,
  });

  Future<RecipeDetails> getRecipeDetails(int recipeId);
}