// lib/features/search/data/datasources/recipe_api_data_source.dart

import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart'; // For debugPrint
import 'package:frontend/common/models/recipe.dart'; // Recipe Entity
import 'package:frontend/common/models/recipe/recipe_details.dart'; // RecipeDetails (for getRecipeDetails)
import 'package:frontend/services/api_client.dart';
import 'package:frontend/core/error/exceptions.dart'; // For ServerException, TimeoutException, ClientException, CancelledException
import 'package:frontend/common/models/recipe_model.dart'; // RecipeModel for parsing

abstract class RecipeApiDataSource {
  Future<List<Recipe>> searchRecipesByQuery({
    required String query,
    int offset,
    int number,
    String? sortBy,
    String? sortDirection,
    Map<String, dynamic>? filters,
    CancelToken? cancelToken, // Optional cancel token for request cancellation
  });

  Future<List<Recipe>> searchRecipesByIngredients({
    required List<String> ingredients, // Ingredients are required here
    int offset,
    int number,
    int? maxMissingIngredients,
    CancelToken? cancelToken, // Optional cancel token for request cancellation
  });

  Future<RecipeDetails> getRecipeDetails(int recipeId, {CancelToken? cancelToken}); // Optional cancel token for request cancellation
}

class RecipeApiDataSourceImpl implements RecipeApiDataSource {
  final ApiClient _apiClient;

  RecipeApiDataSourceImpl(this._apiClient);

  // --- IMPLEMENTATION FOR searchRecipesByQuery ---
  @override
  Future<List<Recipe>> searchRecipesByQuery({
    required String query,
    int offset = 0,
    int number = 10,
    String? sortBy,
    String? sortDirection,
    Map<String, dynamic>? filters,
    CancelToken? cancelToken, // Optional cancel token for request cancellation
  }) async {
    try {
      final Map<String, dynamic> queryParams = {
        'query': query,
        'offset': offset,
        'number': number,
      };

      // Add optional parameters if they exist
      if (sortBy != null) queryParams['sortBy'] = sortBy;
      if (sortDirection != null) queryParams['sortDirection'] = sortDirection;
      if (filters != null) {
        queryParams.addAll(filters); // Add filter parameters directly (e.g., minCalories)
      }

      final String endpoint = '/recipes/search/query';

      debugPrint('[Frontend Data] Calling GET $endpoint with params: $queryParams');

      final Response response = await _apiClient.get(
        endpoint,
        queryParameters: queryParams,
        options: Options(
          sendTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 30),
        ),
        cancelToken: cancelToken, // Pass the optional cancel token
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = response.data;
        var result = jsonList.map((json) => RecipeModel.fromJson(json).toEntity()).toList();
        return result;
      } else {
        throw ServerException('Unexpected status code: ${response.statusCode}');
      }
    } on DioException catch (e) {
      // **NEU:** Prüfe, ob es ein Abbruchfehler war
      if (e.type == DioExceptionType.cancel) {
        debugPrint('Query search cancelled: ${e.message}');
        throw CancelledException('Search was cancelled.'); // Wirf deine eigene CancelledException
      }
      if (e.type == DioExceptionType.connectionTimeout || e.type == DioExceptionType.receiveTimeout) {
        throw TimeoutException('The connection to the server timed out. Please try again later.');
      }
      if (e.response != null) {
        final errorData = e.response!.data;
        throw ServerException('Error during query recipe search: ${errorData['message'] ?? e.message}');
      } else {
        throw ServerException('Network error or server problem: ${e.message}');
      }
    } catch (e) {
      debugPrint('Unexpected error in RecipeApiDataSource.searchRecipesByQuery: $e');
      throw ServerException('An unexpected error occurred: ${e.toString()}');
    }
  }

  // --- IMPLEMENTATION FOR searchRecipesByIngredients ---
  @override
  Future<List<Recipe>> searchRecipesByIngredients({
    required List<String> ingredients,
    int offset = 0,
    int number = 10,
    int? maxMissingIngredients,
    CancelToken? cancelToken, // Optional cancel token for request cancellation
  }) async {
    try {
      if (ingredients.isEmpty) {
        throw ClientException('Ingredients list cannot be empty for ingredient search.');
      }

      final Map<String, dynamic> queryParams = {
        'ingredients': ingredients.join(','), // Join list to comma-separated string
        'offset': offset,
        'number': number,
      };

      if (maxMissingIngredients != null) {
        queryParams['maxMissingIngredients'] = maxMissingIngredients;
      }

      final String endpoint = '/recipes/search/ingredients';

      debugPrint('[Frontend Data] Calling GET $endpoint with params: $queryParams');

      final Response response = await _apiClient.get(
        endpoint,
        queryParameters: queryParams,
        options: Options(
          sendTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 30),
        ),
        cancelToken: cancelToken, // Pass the optional cancel token
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = response.data;
        var result = jsonList.map((json) => RecipeModel.fromJson(json).toEntity()).toList();
        return result;
      } else {
        throw ServerException('Unexpected status code: ${response.statusCode}');
      }
    } on DioException catch (e) {
      // **NEU:** Prüfe, ob es ein Abbruchfehler war
      if (e.type == DioExceptionType.cancel) {
        debugPrint('Ingredient search cancelled: ${e.message}');
        throw CancelledException('Search was cancelled.'); // Wirf deine eigene CancelledException
      }
      if (e.type == DioExceptionType.connectionTimeout || e.type == DioExceptionType.receiveTimeout) {
        throw TimeoutException('The connection to the server timed out. Please try again later.');
      }
      if (e.response != null) {
        final errorData = e.response!.data;
        throw ServerException('Error during ingredient recipe search: ${errorData['message'] ?? e.message}');
      } else {
        throw ServerException('Network error or server problem: ${e.message}');
      }
    } catch (e) {
      debugPrint('Unexpected error in RecipeApiDataSource.searchRecipesByIngredients: $e');
      throw ServerException('An unexpected error occurred: ${e.toString()}');
    }
  }

  // --- IMPLEMENTATION FOR getRecipeDetails ---
  @override
  Future<RecipeDetails> getRecipeDetails(int recipeId, {CancelToken? cancelToken}) async {
    try {
      final String endpoint = '/recipes/$recipeId';

      debugPrint('[Frontend Data] Calling GET $endpoint');

      final Response response = await _apiClient.get(
        endpoint,
        options: Options(
          sendTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 20),
        ),
        cancelToken: cancelToken, // Pass the optional cancel token
      );

      debugPrint('DEBUG API Response for recipe ID $recipeId: ${response.data}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = response.data;
        return RecipeDetails.fromJson(json);
      } else {
        throw ServerException('Unexpected status code: ${response.statusCode}');
      }
    } on DioException catch (e) {
      // **NEU:** Prüfe, ob es ein Abbruchfehler war
      if (e.type == DioExceptionType.cancel) {
        debugPrint('Recipe details fetch cancelled: ${e.message}');
        throw CancelledException('Details fetch was cancelled.'); // Wirf deine eigene CancelledException
      }
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
      debugPrint('Unexpected error in RecipeApiDataSource.getRecipeDetails: $e');
      throw ServerException('An unexpected error occurred: ${e.toString()}');
    }
  }
}