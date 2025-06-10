// lib/features/search/data/repositories/recipe_repository_impl.dart

import 'package:frontend/common/models/recipe.dart';
import 'package:frontend/common/models/recipe/recipe_details.dart';
import 'package:frontend/core/error/failures.dart';
import 'package:frontend/features/search/data/datasources/recipe_api_data_source.dart';
import 'package:frontend/features/search/domain/repositories/recipe_repository.dart';
import 'package:frontend/core/error/exceptions.dart';

class RecipeRepositoryImpl implements RecipeRepository {
  final RecipeApiDataSource remoteDataSource;

  RecipeRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<Recipe>> searchRecipes({
    required String query,
    List<String>? ingredients,
    int offset = 0,
    int number = 10,
    String? sortBy,
    String? sortDirection,
    Map<String, dynamic>? filters,
    int? maxMissingIngredients, // **NEU:** Parameter entgegennehmen
  }) async {
    try {
      final remoteRecipes = await remoteDataSource.searchRecipes(
        query: query,
        ingredients: ingredients,
        offset: offset,
        number: number,
        sortBy: sortBy,
        sortDirection: sortDirection,
        filters: filters,
        maxMissingIngredients: maxMissingIngredients, // **NEU:** An die Datasource weiterleiten
      );
      // Die Datasource gibt bereits `List<Recipe>` zurück, daher keine weitere Konvertierung nötig.
      return remoteRecipes;
    } on ServerException catch (e) {
      throw ServerFailure(message: e.message);
    } on TimeoutException catch (e) {
      throw TimeoutFailure(message: e.message);
    } catch (e) {
      throw GeneralFailure(message: 'An unexpected error occurred: ${e.toString()}');
    }
  }

  @override
  Future<RecipeDetails> getRecipeDetails(int recipeId) async {
    try {
      return await remoteDataSource.getRecipeDetails(recipeId);
    } on ServerException catch (e) {
      throw ServerFailure(message: e.message);
    } on TimeoutException catch (e) {
      throw TimeoutFailure(message: e.message);
    } catch (e) {
      throw GeneralFailure(message: 'An unexpected error occurred: ${e.toString()}');
    }
  }
}