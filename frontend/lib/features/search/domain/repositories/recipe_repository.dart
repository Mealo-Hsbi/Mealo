// lib/features/search/domain/repositories/recipe_repository.dart

import 'package:dio/dio.dart'; // Wichtig: Dio importieren für CancelToken
import 'package:frontend/common/models/recipe.dart';
import 'package:frontend/common/models/recipe/recipe_details.dart';
// import 'package:frontend/common/models/ingredient.dart'; // Nur beibehalten, wenn Ingredient Objekte hier direkt verwendet werden.
                                                           // Normalerweise wird hier nur mit einfachen Datentypen wie List<String> gearbeitet.


abstract class RecipeRepository {
  // NEW: Method for text-based recipe search
  Future<List<Recipe>> searchRecipesByQuery({
    required String query,
    int offset,
    int number,
    String? sortBy,
    String? sortDirection,
    Map<String, dynamic>? filters,
    CancelToken? cancelToken, // <--- Hinzufügen des optionalen CancelToken
  });

  // NEW: Method for ingredient-based recipe search
  Future<List<Recipe>> searchRecipesByIngredients({
    required List<String> ingredients,
    int offset,
    int number,
    int? maxMissingIngredients,
    CancelToken? cancelToken, // <--- Hinzufügen des optionalen CancelToken
  });

  Future<RecipeDetails> getRecipeDetails(int recipeId, {CancelToken? cancelToken}); // <--- Hinzufügen des optionalen CancelToken
}