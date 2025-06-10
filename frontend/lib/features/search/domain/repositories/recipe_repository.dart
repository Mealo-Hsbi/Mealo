// lib/features/search/domain/repositories/recipe_repository.dart

import 'package:frontend/common/models/recipe.dart';
import 'package:frontend/common/models/recipe/recipe_details.dart';
import 'package:frontend/common/models/ingredient.dart'; // Falls hier Ingredient-Objekte übergeben werden

abstract class RecipeRepository {
  Future<List<Recipe>> searchRecipes({
    required String query,
    List<String>? ingredients, // Hier bleiben es Strings (Namen)
    int offset,
    int number,
    String? sortBy,
    String? sortDirection,
    Map<String, dynamic>? filters,
    int? maxMissingIngredients, // **NEU:** Parameter hinzufügen
  });

  Future<RecipeDetails> getRecipeDetails(int recipeId);
}