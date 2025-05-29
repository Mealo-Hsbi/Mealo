// lib/features/search/data/repositories/recipe_repository_impl.dart

import 'package:frontend/common/models/ingredient.dart';
import 'package:frontend/common/models/recipe.dart';
import 'package:frontend/common/models/recipe_details.dart';
import 'package:frontend/features/search/data/datasources/recipe_api_data_source.dart';
import 'package:frontend/features/search/domain/repositories/recipe_repository.dart'; // Das Interface!

/// Konkrete Implementierung des RecipeRepository Interfaces.
/// Sie ist für die Interaktion mit der Datenquelle (DataSource) verantwortlich.
class RecipeRepositoryImpl implements RecipeRepository {
  final RecipeApiDataSource dataSource;

  RecipeRepositoryImpl(this.dataSource);

  @override
  Future<List<Recipe>> searchRecipes({
    required String query,
    List<Ingredient>? selectedIngredients,
    Map<String, dynamic>? filters,
    String? sortBy,
    String? sortDirection,
  }) async {
    // Konvertiere die Liste der Ingredient-Objekte in eine Liste von Namen (Strings),
    // da die API/das Backend Strings erwartet.
    final ingredientNames = selectedIngredients?.map((i) => i.name.toLowerCase()).toList();

    return await dataSource.searchRecipes(
      query: query,
      ingredients: ingredientNames,
      filters: filters,
      sortBy: sortBy,
      sortDirection: sortDirection,
    );
  }

  @override
  Future<RecipeDetails> getRecipeDetails(int recipeId) async {
    return await dataSource.getRecipeDetails(recipeId);
  }
}