// lib/features/recipe/data/repositories/recipe_interaction_repository_impl.dart

import 'package:frontend/core/error/exceptions.dart'; // Ihre Exceptions
import 'package:frontend/core/error/failures.dart'; // Ihre Failures
import 'package:frontend/features/recipe/data/datasources/recipe_interaction_remote_datasource.dart';
import 'package:frontend/features/recipe/data/models/recipe_model.dart';
import 'package:frontend/features/recipe/data/models/favorite_model.dart'; // Hinzugefügt, da wir FavoriteModel erwarten
import 'package:frontend/features/recipe/data/models/recipe_rating_response_model.dart';
import 'package:frontend/features/recipe/domain/entities/favorite.dart';
import 'package:frontend/features/recipe/domain/entities/recipe.dart';
import 'package:frontend/features/recipe/domain/entities/recipe_rating.dart';
import 'package:frontend/features/recipe/domain/repositories/recipe_interaction_repository.dart';

class RecipeInteractionRepositoryImpl implements RecipeInteractionRepository {
  final RecipeInteractionRemoteDataSource remoteDataSource;

  RecipeInteractionRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<Favorite> addFavoriteRecipe(
      String userId, int? spoonacularId, Recipe recipe) async {
    try {
      final recipeModel = RecipeModel.fromEntity(recipe);
      final favoriteModel = await remoteDataSource.addFavoriteRecipe(
          userId, spoonacularId, recipeModel);
      return favoriteModel.toEntity();
    } on ServerException catch (e) {
      throw ServerFailure(message: e.message);
    } on TimeoutException catch (e) {
      throw TimeoutFailure(message: e.message);
    } catch (e) {
      throw GeneralFailure(message: 'An unexpected error occurred: ${e.toString()}');
    }
  }

  @override
  Future<void> removeFavoriteRecipe(
      String userId, String favoriteId) async {
    try {
      await remoteDataSource.removeFavoriteRecipe(userId, favoriteId);
    } on ServerException catch (e) {
      throw ServerFailure(message: e.message);
    } on TimeoutException catch (e) {
      throw TimeoutFailure(message: e.message);
    } catch (e) {
      throw GeneralFailure(message: 'An unexpected error occurred: ${e.toString()}');
    }
  }

  @override
  Future<List<Favorite>> getFavoriteRecipes(String userId) async {
    try {
      final favoriteModels = await remoteDataSource.getFavoriteRecipes(userId);
      return favoriteModels.map((model) => model.toEntity()).toList();
    } on ServerException catch (e) {
      throw ServerFailure(message: e.message);
    } on TimeoutException catch (e) {
      throw TimeoutFailure(message: e.message);
    } on CancelledException catch (e) {
      throw CancelledFailure(message: e.message);
    } catch (e) {
      throw GeneralFailure(message: 'An unexpected error occurred: ${e.toString()}');
    }
  }

  @override
  // === WICHTIGE ÄNDERUNG HIER ===
  // Rückgabetyp ist jetzt Favorite?
  Future<Favorite?> isRecipeFavorited(
      String userId, String recipeId) async {
    try {
      // Annahme: remoteDataSource.isRecipeFavorited gibt jetzt FavoriteModel? zurück
      final favoriteModel = await remoteDataSource.isRecipeFavorited(userId, recipeId);
      
      // Wenn ein FavoriteModel zurückkommt, konvertiere es zur Entity
      if (favoriteModel != null) {
        return favoriteModel.toEntity();
      } else {
        // Wenn remoteDataSource.isRecipeFavorited null zurückgibt (nicht favorisiert),
        // geben wir auch null zurück.
        return null;
      }
    } on ServerException catch (e) {
      // Wenn der Server einen 404 Fehler wirft, interpretieren wir das als "nicht favorisiert"
      if (e.statusCode == 404) {
        return null; // Explizit null zurückgeben für 404 (nicht gefunden)
      }
      throw ServerFailure(message: e.message); // Andere Serverfehler als Failure weiterleiten
    } on TimeoutException catch (e) {
      throw TimeoutFailure(message: e.message);
    } catch (e) {
      throw GeneralFailure(message: 'An unexpected error occurred: ${e.toString()}');
    }
  }

  @override
  Future<RecipeRatingResponseModel> addOrUpdateRecipeRating(
      String userId, int? spoonacularId, int score, Recipe recipe, {String? comment}) async {
    try {
      final recipeModel = RecipeModel.fromEntity(recipe);
      final ratingResponseModel = await remoteDataSource.addOrUpdateRecipeRating(
          userId, spoonacularId, score, recipeModel,
          comment: comment);
      return ratingResponseModel;
    } on ServerException catch (e) {
      throw ServerFailure(message: e.message);
    } on TimeoutException catch (e) {
      throw TimeoutFailure(message: e.message);
    } catch (e) {
      throw GeneralFailure(message: 'An unexpected error occurred: ${e.toString()}');
    }
  }

  @override
  Future<RecipeRating?> getUserRecipeRating(
      String userId, String recipeId) async {
    try {
      final ratingModel =
          await remoteDataSource.getUserRecipeRating(userId, recipeId);
      return ratingModel?.toEntity();
    } on ServerException catch (e) {
      throw ServerFailure(message: e.message);
    } on TimeoutException catch (e) {
      throw TimeoutFailure(message: e.message);
    } catch (e) {
      throw GeneralFailure(message: 'An unexpected error occurred: ${e.toString()}');
    }
  }
}