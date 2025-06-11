// lib/features/search/domain/usecases/search_recipes_by_ingredients.dart

import 'package:dio/dio.dart'; // Wichtig: Dio importieren für CancelToken
import 'package:frontend/common/models/recipe.dart';
import 'package:frontend/features/search/domain/repositories/recipe_repository.dart';

/// Use case for searching recipes based on available ingredients.
class SearchRecipesByIngredients {
  final RecipeRepository repository;

  SearchRecipesByIngredients(this.repository);

  Future<List<Recipe>> call({
    required List<String> ingredients, // Erwartet eine Liste von Zutatennamen
    int offset = 0,
    int number = 10,
    int? maxMissingIngredients,
    CancelToken? cancelToken, // <--- Hinzufügen des optionalen CancelToken
  }) async {
    // Ruft die spezifische Methode des Repositories für die Zutatensuche auf
    return await repository.searchRecipesByIngredients(
      ingredients: ingredients,
      offset: offset,
      number: number,
      maxMissingIngredients: maxMissingIngredients,
      cancelToken: cancelToken, // <--- Wichtig: CancelToken hier weitergeben!
    );
  }
}