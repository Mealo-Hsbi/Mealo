// lib/features/search/data/repositories/recipe_repository_impl.dart

import 'package:frontend/common/models/recipe.dart';
import 'package:frontend/common/models/recipe_details.dart';
import 'package:frontend/common/models/recipe_model.dart';
import 'package:frontend/features/search/data/datasources/recipe_api_data_source.dart';
import 'package:frontend/features/search/domain/repositories/recipe_repository.dart'; // NEW: Import RecipeModel

class RecipeRepositoryImpl implements RecipeRepository {
  final RecipeApiDataSource _dataSource;

  RecipeRepositoryImpl(this._dataSource);

  @override
  Future<List<Recipe>> searchRecipes({
    required String query,
    required List<String> ingredients,
    int offset = 0,
    int number = 10,
    // Map<String, dynamic>? filters,
    // String? sortBy,
    // String? sortDirection,
  }) async {
    try {
      // The dataSource now returns List<RecipeModel>
      final List<RecipeModel> recipeModels = await _dataSource.searchRecipes( // CHANGE TYPE
        query: query,
        ingredients: ingredients,
        offset: offset,
        number: number,
        // filters: filters,
        // sortBy: sortBy,
        // sortDirection: sortDirection,
      );
      // Now, you can correctly call toEntity() on each RecipeModel to convert to Recipe
      return recipeModels.map((model) => model.toEntity()).toList(); // THIS LINE IS NOW CORRECT
    } catch (e) {
      // It's best to rethrow custom exceptions directly, or wrap generic ones.
      // Assuming exceptions from dataSource are already custom exceptions:
      rethrow; // Re-throw the exception from the data source
    }
  }

  @override
  Future<RecipeDetails> getRecipeDetails(int recipeId) async {
    // getRecipeDetails might also benefit from a RecipeDetailsModel if structure differs
    // but for simplicity, if RecipeDetails is directly from API, this is okay.
    try {
      return await _dataSource.getRecipeDetails(recipeId);
    } catch (e) {
      rethrow; // Re-throw any exceptions from the data source
    }
  }
}