// lib/features/recipe/data/datasources/recipe_interaction_remote_datasource.dart
import 'package:dio/dio.dart';
import 'package:flutter/material.dart'; // Für debugPrint
import 'package:frontend/core/error/exceptions.dart'; // Ihre spezifischen Exceptions
import 'package:frontend/features/recipe/data/models/favorite_model.dart';
import 'package:frontend/features/recipe/data/models/recipe_model.dart';
import 'package:frontend/features/recipe/data/models/recipe_rating_model.dart';
import 'package:frontend/features/recipe/data/models/recipe_rating_response_model.dart';
import 'package:frontend/services/api_client.dart'; // Ihr ApiClient

// --- Abstrakte Schnittstelle (der "Vertrag") bleibt gleich ---
abstract class RecipeInteractionRemoteDataSource {
  Future<FavoriteModel> addFavoriteRecipe(String userId, int? spoonacularId, RecipeModel recipe);

  Future<void> removeFavoriteRecipe(String userId, String favoriteId);
  Future<List<FavoriteModel>> getFavoriteRecipes(String userId);

  // Der Rückgabetyp ist bereits FavoriteModel?
  Future<FavoriteModel?> isRecipeFavorited(String userId, String recipeId);

  Future<RecipeRatingResponseModel> addOrUpdateRecipeRating(
      String userId, int? spoonacularId, int score, RecipeModel recipe, {String? comment});
  Future<RecipeRatingModel?> getUserRecipeRating(
      String userId, String recipeId);
}

// --- Implementierung der Schnittstelle mit Ihrem ApiClient ---
class RecipeInteractionRemoteDataSourceImpl implements RecipeInteractionRemoteDataSource {
  final ApiClient _apiClient;

  RecipeInteractionRemoteDataSourceImpl(this._apiClient);

  // Hilfsmethode für die zentrale Fehlerbehandlung
  void _handleDioError(DioException e, String contextMessage) {
    if (e.type == DioExceptionType.cancel) {
      debugPrint('$contextMessage cancelled: ${e.message}');
      throw CancelledException('$contextMessage was cancelled.');
    }
    if (e.type == DioExceptionType.connectionTimeout || e.type == DioExceptionType.receiveTimeout || e.type == DioExceptionType.sendTimeout) {
      throw TimeoutException('The connection to the server timed out. Please try again later.');
    }
    if (e.response != null) {
      final errorData = e.response!.data;
      final errorMessage = errorData != null && errorData is Map && errorData.containsKey('message')
          ? errorData['message']
          : e.message;
      throw ServerException('$contextMessage: ${errorMessage ?? 'Unknown server error'}', statusCode: e.response!.statusCode); // statusCode hinzugefügt
    } else {
      throw ServerException('$contextMessage: Network error or server problem: ${e.message}');
    }
  }

  @override
  Future<FavoriteModel> addFavoriteRecipe(
      String userId, int? spoonacularId, RecipeModel recipe) async {
    try {
      final String endpoint = '/recipes/favorites';
      debugPrint('[Frontend Data] Calling POST $endpoint');

      final Response response = await _apiClient.post(
        endpoint,
        data: {
          'userId': userId,
          'spoonacularId': spoonacularId,
          'recipeData': recipe.toJson(),
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return FavoriteModel.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw ServerException('Unexpected status code: ${response.statusCode}');
      }
    } on DioException catch (e) {
      _handleDioError(e, 'Failed to add favorite');
      rethrow;
    } catch (e) {
      debugPrint('Unexpected error in RecipeInteractionRemoteDataSource.addFavoriteRecipe: $e');
      throw ServerException('An unexpected error occurred: ${e.toString()}');
    }
  }

  @override
  Future<void> removeFavoriteRecipe(String userId, String favoriteId) async {
    try {
      final String endpoint = '/recipes/favorites/$favoriteId';
      debugPrint('[Frontend Data] Calling DELETE $endpoint');

      final Response response = await _apiClient.delete(
        endpoint,
      );

      if (response.statusCode != 204) {
        throw ServerException('Failed to remove favorite: Unexpected status code ${response.statusCode}');
      }
    } on DioException catch (e) {
      _handleDioError(e, 'Failed to remove favorite');
      rethrow;
    } catch (e) {
      debugPrint('Unexpected error in RecipeInteractionRemoteDataSource.removeFavoriteRecipe: $e');
      throw ServerException('An unexpected error occurred: ${e.toString()}');
    }
  }

  @override
  Future<List<FavoriteModel>> getFavoriteRecipes(String userId) async {
    debugPrint('--- Entering getFavoriteRecipes for userId: $userId ---'); // NEU
    try {
      final String endpoint = '/recipes/favorites';
      debugPrint('[Frontend Data] Calling GET $endpoint');

      final Response response = await _apiClient.get(
        endpoint,
        // Hier könntest du bei Bedarf Query-Parameter hinzufügen
        queryParameters: {'userId': userId}, // Optional: Wenn dein Backend userId als Query-Parameter erwartet
      );

      debugPrint('*** RAW API Response for GET /recipes/favorites: ${response.data}');

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = response.data as List<dynamic>;
        return jsonList.map((json) => FavoriteModel.fromJson(json as Map<String, dynamic>)).toList();
      } else {
        throw ServerException('Failed to get favorite recipes: Unexpected status code ${response.statusCode}');
      }
    } on DioException catch (e) {
      debugPrint('!!! DioException in getFavoriteRecipes: ${e.response?.statusCode ?? 'No status'} - ${e.message}'); // NEU
      _handleDioError(e, 'Failed to get favorite recipes');
      rethrow;
    } catch (e) {
      debugPrint('!!! Unexpected error in RecipeInteractionRemoteDataSource.getFavoriteRecipes: $e'); // NEU
      throw ServerException('An unexpected error occurred: ${e.toString()}');
    } finally { // NEU: Fängt immer einen Print ab
      debugPrint('--- Exiting getFavoriteRecipes ---');
    }
  }

  @override
  Future<FavoriteModel?> isRecipeFavorited(String userId, String recipeId) async {
    debugPrint('--- Entering isRecipeFavorited for recipeId: $recipeId and userId: $userId ---'); // NEU
    try {
      final String endpoint = '/recipes/$recipeId/isFavorited';
      debugPrint('[Frontend Data] Calling GET $endpoint');

      final Response response = await _apiClient.get(
        endpoint,
        // Optional: Wenn dein Backend userId als Query-Parameter erwartet
        queryParameters: {'userId': userId},
      );

      debugPrint('*** RAW API Response for GET /recipes/$recipeId/isFavorited: ${response.data}');

      if (response.statusCode == 200) {
        if (response.data != null && response.data is Map<String, dynamic>) {
            return FavoriteModel.fromJson(response.data as Map<String, dynamic>);
        } else {
            throw ServerException('Expected FavoriteModel data, but got null or wrong type with status 200.');
        }
      } else {
        throw ServerException('Unexpected status code: ${response.statusCode}');
      }
    } on DioException catch (e) {
      debugPrint('!!! DioException in isRecipeFavorited: ${e.response?.statusCode ?? 'No status'} - ${e.message}'); // NEU
      if (e.response?.statusCode == 404) {
        debugPrint('Recipe $recipeId not favorited for user $userId (404 Not Found). Returning null.');
        return null;
      }
      _handleDioError(e, 'Failed to check if recipe is favorited');
      rethrow;
    } catch (e) {
      debugPrint('!!! Unexpected error in RecipeInteractionRemoteDataSource.isRecipeFavorited: $e'); // NEU
      throw ServerException('An unexpected error occurred: ${e.toString()}');
    } finally { // NEU: Fängt immer einen Print ab
      debugPrint('--- Exiting isRecipeFavorited ---');
    }
  }

  @override
  Future<RecipeRatingResponseModel> addOrUpdateRecipeRating(
      String userId, int? spoonacularId, int score, RecipeModel recipe, {String? comment}) async {
    try {
      final String endpoint = '/recipes/ratings';
      debugPrint('[Frontend Data] Calling POST $endpoint');

      final Response response = await _apiClient.post(
        endpoint,
        data: {
          'spoonacularId': spoonacularId,
          'rating': score,
          'comment': comment,
          'recipeData': recipe.toJson(),
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('--- RAW API Response Data for addOrUpdateRecipeRating ---');
        debugPrint('Type of response.data: ${response.data.runtimeType}');
        debugPrint('Content of response.data: ${response.data}');

        final Map<String, dynamic> responseData = response.data as Map<String, dynamic>;
        return RecipeRatingResponseModel.fromJson(responseData);
      } else {
        throw ServerException('Unexpected status code: ${response.statusCode}');
      }
    } on DioException catch (e) {
      _handleDioError(e, 'Failed to add or update recipe rating');
      rethrow;
    } catch (e) {
      debugPrint('Unexpected error in RecipeInteractionRemoteDataSource.addOrUpdateRecipeRating: $e');
      throw ServerException('An unexpected error occurred: ${e.toString()}');
    }
  }

  @override
  Future<RecipeRatingModel?> getUserRecipeRating(
      String userId, String recipeId) async {
    try {
      final String endpoint = '/recipes/$recipeId/rating';
      debugPrint('[Frontend Data] Calling GET $endpoint');

      final Response response = await _apiClient.get(
        endpoint,
      );

      if (response.statusCode == 200) {
        if (response.data == null || !(response.data is Map<String, dynamic>)) {
          return null; // Return null if the data is null or not in the expected format
        }
        return RecipeRatingModel.fromJson(response.data as Map<String, dynamic>);
      } else if (response.statusCode == 404) {
        debugPrint('No rating found for recipe $recipeId by user $userId (404 Not Found).');
        return null;
      } else {
        throw ServerException('Failed to get user recipe rating: Unexpected status code ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return null;
      }
      _handleDioError(e, 'Failed to get user recipe rating');
      rethrow;
    } catch (e) {
      debugPrint('Unexpected error in RecipeInteractionRemoteDataSource.getUserRecipeRating: $e');
      throw ServerException('An unexpected error occurred: ${e.toString()}');
    }
  }
}