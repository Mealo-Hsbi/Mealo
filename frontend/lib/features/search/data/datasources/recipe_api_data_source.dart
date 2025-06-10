// lib/features/search/data/datasources/recipe_api_data_source.dart

import 'dart:async'; // Bleibt
import 'package:dio/dio.dart'; // Bleibt
import 'package:flutter/material.dart'; // Bleibt (für debugPrint)
import 'package:frontend/common/models/recipe.dart'; // WICHTIG: Recipe Entity
import 'package:frontend/common/models/recipe/recipe_details.dart'; // Bleibt
import 'package:frontend/services/api_client.dart'; // Bleibt
import 'package:frontend/core/error/exceptions.dart'; // Bleibt
import 'package:frontend/common/models/recipe_model.dart'; // WICHTIG: RecipeModel für Parsing

abstract class RecipeApiDataSource {
  // ÄNDERUNG: Rückgabetyp ist jetzt List<Recipe> (die Domain Entity)
  Future<List<Recipe>> searchRecipes({
    required String query,
    List<String>? ingredients,
    int offset,
    int number,
    String? sortBy,
    String? sortDirection,
    Map<String, dynamic>? filters,
    int? maxMissingIngredients, // NEU: maxMissingIngredients hinzufügen
  });

  Future<RecipeDetails> getRecipeDetails(int recipeId);
}

class RecipeApiDataSourceImpl implements RecipeApiDataSource {
  final ApiClient _apiClient;

  RecipeApiDataSourceImpl(this._apiClient);

  @override
  Future<List<Recipe>> searchRecipes({ // ÄNDERUNG: Rückgabetyp
    required String query,
    List<String>? ingredients,
    int offset = 0,
    int number = 10,
    String? sortBy,
    String? sortDirection,
    Map<String, dynamic>? filters,
    int? maxMissingIngredients, // NEU: Parameter in der Implementierung
  }) async {
    try {
      final requestedData = {
        'query': query,
        'ingredients': ingredients ?? [],
        'offset': offset,
        'number': number,
        'sortBy': sortBy,
        'sortDirection': sortDirection,
        'filters': filters ?? {},
        'maxMissingIngredients': maxMissingIngredients, // NEU: Hier in den Request Body aufnehmen
      };

      final String endpoint = '/recipes/search'; // WICHTIG: Korrekter Backend-Endpoint, sollte '/recipe/search' sein (Sie hatten '/recipes/search' im alten Code, aber das Backend zeigt '/recipe/search'). Bitte verifizieren Sie dies.

      final Response response = await _apiClient.post(
        endpoint,
        data: {
          'query': query,
          'ingredients': ingredients,
          'offset': offset,
          'number': number,
          'sortBy': sortBy,
          'sortDirection': sortDirection,
          'filters': filters,
          'maxMissingIngredients': maxMissingIngredients, // NEU: Hier in den Request Body aufnehmen
        },
        options: Options(
          sendTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 30),
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = response.data;
        // ÄNDERUNG: Hier konvertieren wir von RecipeModel zu Recipe
        var result = jsonList.map((json) => RecipeModel.fromJson(json).toEntity()).toList();
        return result;
      } else {
        throw ServerException('Unexpected status code: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout || e.type == DioExceptionType.receiveTimeout) {
        throw TimeoutException('The connection to the server timed out. Please try again later.');
      }
      if (e.response != null) {
        final errorData = e.response!.data;
        throw ServerException('Error during recipe search: ${errorData['message'] ?? e.message}');
      } else {
        throw ServerException('Network error or server problem: ${e.message}');
      }
    } catch (e) {
      print('Unexpected error in RecipeApiDataSource.searchRecipes: $e');
      throw ServerException('An unexpected error occurred: ${e.toString()}');
    }
  }

  @override
  Future<RecipeDetails> getRecipeDetails(int recipeId) async {
    try {
      final String endpoint = '/recipes/$recipeId'; // WICHTIG: Korrekter Backend-Endpoint, sollte '/recipe/$recipeId' sein.

      final Response response = await _apiClient.get(
        endpoint,
        options: Options(
          sendTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 20),
        ),
      );

      debugPrint('DEBUG API Response for recipe ID $recipeId: ${response.data}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = response.data;
        return RecipeDetails.fromJson(json); // Hier war der Typ schon korrekt
      } else {
        throw ServerException('Unexpected status code: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout || e.type == DioExceptionType.receiveTimeout) {
        throw TimeoutException('The connection to the server timed out. Please try again later.');
      }
      if (e.response != null) {
        final errorData = e.response!.data;
        throw ServerException('Error loading recipe details: ${errorData['message'] ?? e.message}');
      } else {
        throw ServerException('Network error or server problem: ${e.message}');
      }
    } catch (e) {
      print('Unexpected error in RecipeApiDataSource.getRecipeDetails: $e');
      throw ServerException('An unexpected error occurred: ${e.toString()}');
    }
  }
}