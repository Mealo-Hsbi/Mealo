// lib/features/search/data/repositories/recipe_repository_impl.dart

import 'package:frontend/common/models/recipe.dart';
import 'package:frontend/common/models/recipe/recipe_details.dart';
import 'package:frontend/common/models/recipe_model.dart';
import 'package:frontend/features/search/data/datasources/recipe_api_data_source.dart';
import 'package:frontend/features/search/domain/repositories/recipe_repository.dart';

class RecipeRepositoryImpl implements RecipeRepository {
  final RecipeApiDataSource _dataSource;

  RecipeRepositoryImpl(this._dataSource);

  @override
  Future<List<Recipe>> searchRecipes({
    required String query,
    required List<String> ingredients,
    int offset = 0,
    int number = 10,
    String? sortBy, // NEU: Sortierparameter
    String? sortDirection, // NEU: Sortierparameter
    // Map<String, dynamic>? filters,
  }) async {
    try {
      final List<RecipeModel> recipeModels = await _dataSource.searchRecipes(
        query: query,
        ingredients: ingredients,
        offset: offset,
        number: number,
        sortBy: sortBy, // NEU: An DataSource übergeben
        sortDirection: sortDirection, // NEU: An DataSource übergeben
        // filters: filters,
      );
      return recipeModels.map((model) => model.toEntity()).toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<RecipeDetails> getRecipeDetails(int recipeId) async {
    try {
      return await _dataSource.getRecipeDetails(recipeId);
    } catch (e) {
      rethrow;
    }
  }
}