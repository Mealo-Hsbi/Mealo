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
    int offset = 0,
    int number = 10,
    String? sortBy, // NEU: Sortierparameter
    String? sortDirection, // NEU: Sortierparameter
    // Map<String, dynamic>? filters, // Filters bleiben hier
  }) async {
    return _repository.searchRecipes(
      query: query,
      ingredients: selectedIngredients.map((i) => i.name).toList(),
      offset: offset,
      number: number,
      sortBy: sortBy, // NEU: An Repository übergeben
      sortDirection: sortDirection, // NEU: An Repository übergeben
      // filters: filters,
    );
  }
}