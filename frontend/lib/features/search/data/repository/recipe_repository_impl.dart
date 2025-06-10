// lib/features/search/data/repository/recipe_repository_impl.dart

// Importiere das abstrakte RecipeRepository Interface, das diese Klasse implementiert.
import 'package:frontend/features/search/domain/repositories/recipe_repository.dart';

// Importiere die RecipeApiDataSource Schnittstelle.
// Dies ist der *einzige* benötigte Import von deiner DataSource-Datei hier.
import 'package:frontend/features/search/data/datasources/recipe_api_data_source.dart';

// Importiere deine Modelle und Exception-Klassen
import 'package:frontend/common/models/recipe.dart';
import 'package:frontend/common/models/recipe/recipe_details.dart';
import 'package:frontend/core/error/exceptions.dart'; // Für ServerException, TimeoutException, ClientException

class RecipeRepositoryImpl implements RecipeRepository {
  final RecipeApiDataSource remoteDataSource;

  RecipeRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<Recipe>> searchRecipesByQuery({
    required String query,
    int offset = 0,
    int number = 10,
    String? sortBy,
    String? sortDirection,
    Map<String, dynamic>? filters,
  }) async {
    // Das Repository ruft einfach die entsprechende Methode der DataSource auf
    // und wirft eventuelle Exceptions direkt weiter.
    return await remoteDataSource.searchRecipesByQuery(
      query: query,
      offset: offset,
      number: number,
      sortBy: sortBy,
      sortDirection: sortDirection,
      filters: filters,
    );
  }

  @override
  Future<List<Recipe>> searchRecipesByIngredients({
    required List<String> ingredients,
    int offset = 0,
    int number = 10,
    int? maxMissingIngredients,
  }) async {
    // Auch hier: Ruft die DataSource auf und wirft Exceptions weiter.
    return await remoteDataSource.searchRecipesByIngredients(
      ingredients: ingredients,
      offset: offset,
      number: number,
      maxMissingIngredients: maxMissingIngredients,
    );
  }

  @override
  Future<RecipeDetails> getRecipeDetails(int recipeId) async {
    // Ruft die DataSource auf und wirft Exceptions weiter.
    return await remoteDataSource.getRecipeDetails(recipeId);
  }
}