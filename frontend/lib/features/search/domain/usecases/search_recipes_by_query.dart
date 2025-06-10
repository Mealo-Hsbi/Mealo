// lib/features/search/domain/usecases/search_recipes_by_query.dart

import 'package:frontend/common/models/recipe.dart';
import 'package:frontend/features/search/domain/repositories/recipe_repository.dart';

/// Use case for searching recipes based on a text query.
class SearchRecipesByQuery {
  final RecipeRepository repository;

  SearchRecipesByQuery(this.repository);

  Future<List<Recipe>> call({
    required String query,
    int offset = 0,
    int number = 10,
    String? sortBy,
    String? sortDirection,
    Map<String, dynamic>? filters,
  }) async {
    // Ruft die spezifische Methode des Repositories für die Query-Suche auf
    return await repository.searchRecipesByQuery(
      query: query,
      offset: offset,
      number: number,
      sortBy: sortBy,
      sortDirection: sortDirection,
      filters: filters,
    );
  }
}