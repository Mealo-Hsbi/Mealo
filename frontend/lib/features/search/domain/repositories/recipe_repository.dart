// lib/features/search/domain/repositories/recipe_repository.dart

import 'package:frontend/common/models/recipe.dart';
import 'package:frontend/common/models/recipe/recipe_details.dart'; // Für getRecipeDetails

abstract class RecipeRepository {
  Future<List<Recipe>> searchRecipes({
    required String query,
    required List<String> ingredients,
    int offset,
    int number,
    String? sortBy, // NEU: Sortierparameter
    String? sortDirection, // NEU: Sortierparameter
    // Map<String, dynamic>? filters,
  });

  Future<RecipeDetails> getRecipeDetails(int recipeId);
}