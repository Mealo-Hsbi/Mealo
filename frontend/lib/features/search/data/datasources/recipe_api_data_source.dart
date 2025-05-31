// lib/features/search/data/datasources/recipe_api_data_source.dart
import 'dart:async'; // For TimeoutException, in case your ApiClient throws it
import 'dart:convert'; // For jsonDecode (though Dio usually handles this automatically)
import 'package:dio/dio.dart'; // For DioException and Response
import 'package:frontend/common/models/recipe.dart';
import 'package:frontend/common/models/recipe_details.dart'; // Important for getRecipeDetails
import 'package:frontend/services/api_client.dart'; // Import your ApiClient
import 'package:frontend/core/error/exceptions.dart'; // Assuming you have custom exceptions like ServerException

import 'package:frontend/common/models/recipe_model.dart'; // NEW: Import RecipeModel

abstract class RecipeApiDataSource {
  Future<List<RecipeModel>> searchRecipes({ // CHANGE RETURN TYPE
    required String query,
    List<String>? ingredients,
    int offset,
    int number,
    Map<String, dynamic>? filters,
    String? sortBy,
    String? sortDirection,
  });

  Future<RecipeDetails> getRecipeDetails(int recipeId);
}

class RecipeApiDataSourceImpl implements RecipeApiDataSource {
  final ApiClient _apiClient;

  RecipeApiDataSourceImpl(this._apiClient);

  @override
  Future<List<RecipeModel>> searchRecipes({ // CHANGE RETURN TYPE
    required String query,
    List<String>? ingredients,
    int offset = 0,
    int number = 10,
    Map<String, dynamic>? filters,
    String? sortBy,
    String? sortDirection,
  }) async {
    try {
      final String endpoint = '/recipes/search';

      final Response response = await _apiClient.post(
        endpoint,
        data: {
          'query': query,
          'ingredients': ingredients,
          'offset': offset,
          'number': number,
          'filters': filters,
          'sortBy': sortBy,
          'sortDirection': sortDirection,
        },
        options: Options(
          sendTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 30),
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = response.data;
        // CHANGE: Map to RecipeModel.fromJson
        
        var result = jsonList.map((json) => RecipeModel.fromJson(json)).toList();
        
        return result; // Return List<RecipeModel>
      } else {
        throw ServerException('Unexpected status code: ${response.statusCode}');
      }
    } on DioException catch (e) {
      // Handle various types of Dio errors
      if (e.type == DioExceptionType.connectionTimeout || e.type == DioExceptionType.receiveTimeout) {
        throw TimeoutException('The connection to the server timed out. Please try again later.');
      }
      if (e.response != null) {
        // If the server sent a response (e.g., 400, 404, 500)
        final errorData = e.response!.data; // Assuming error response is JSON
        throw ServerException('Error during recipe search: ${errorData['message'] ?? e.message}');
      } else {
        // Network error or other issues
        throw ServerException('Network error or server problem: ${e.message}');
      }
    } catch (e) {
      // Catch all other unexpected errors
      print('Unexpected error in RecipeApiDataSource.searchRecipes: $e');
      throw ServerException('An unexpected error occurred: ${e.toString()}'); // Wrap in custom exception
    }
  }

  /// Fetches detailed information for a specific recipe.
  /// Uses the GET route for recipe details.
  @override // Important to add @override
  Future<RecipeDetails> getRecipeDetails(int recipeId) async {
    try {
      final String endpoint = '/api/recipes/$recipeId/details'; // The backend route for details

      final Response response = await _apiClient.get(
        endpoint,
        options: Options(
          sendTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 20),
        ),
      );

      if (response.statusCode == 200) {
        // response.data should already be a Map<String, dynamic>
        final Map<String, dynamic> json = response.data;
        return RecipeDetails.fromJson(json);
      } else {
        throw ServerException('Unexpected status code: ${response.statusCode}'); // Use custom exception
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
      throw ServerException('An unexpected error occurred: ${e.toString()}'); // Wrap in custom exception
    }
  }
}