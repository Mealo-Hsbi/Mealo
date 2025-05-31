// lib/features/search/domain/usecases/search_recipes.dart

import 'package:frontend/common/models/ingredient.dart';
import 'package:frontend/common/models/recipe.dart';
import 'package:frontend/features/search/domain/repositories/recipe_repository.dart';

class SearchRecipes {
  final RecipeRepository _repository;

  SearchRecipes(this._repository);

  Future<List<Recipe>> call({
    required String query,
    required List<Ingredient> selectedIngredients,
    int offset = 0, // NEW: Add offset with a default value of 0
    int number = 10, // NEW: Add number (limit) with a default value of 10
    // Add other optional parameters like filters, sortBy, sortDirection here if your API supports them
    // Map<String, dynamic>? filters,
    // String? sortBy,
    // String? sortDirection,
  }) async {
    return _repository.searchRecipes(
      query: query,
      ingredients: selectedIngredients.map((i) => i.name).toList(),
      offset: offset, // Pass offset to the repository
      number: number, // Pass number to the repository
      // filters: filters,
      // sortBy: sortBy,
      // sortDirection: sortDirection,
    );
  }
}