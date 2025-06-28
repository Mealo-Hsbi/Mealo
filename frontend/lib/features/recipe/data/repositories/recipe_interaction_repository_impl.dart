// lib/features/recipe/data/repositories/recipe_interaction_repository_impl.dart

import 'package:frontend/core/error/exceptions.dart'; // Ihre Exceptions
import 'package:frontend/core/error/failures.dart'; // Ihre Failures
import 'package:frontend/features/recipe/data/datasources/recipe_interaction_remote_datasource.dart';
import 'package:frontend/features/recipe/data/models/recipe_model.dart';
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
  Future<void> addFavoriteRecipe(
      String userId, int? spoonacularId, Recipe recipe) async {
    try {
      final recipeModel = RecipeModel.fromEntity(recipe);
      await remoteDataSource.addFavoriteRecipe(
          userId, spoonacularId, recipeModel);
      // Bei Erfolg: einfach zurückkehren, da die Methode void ist
    } on ServerException catch (e) {
      throw ServerFailure(message: e.message); // Wirft Failure
    } on TimeoutException catch (e) {
      throw TimeoutFailure(message: e.message); // Wirft Failure
    } catch (e) {
      throw GeneralFailure(message: 'An unexpected error occurred: ${e.toString()}'); // Wirft Failure
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
  Future<List<Favorite>> getFavoriteRecipes(
      String userId) async {
    try {
      final favoriteModels =
          await remoteDataSource.getFavoriteRecipes(userId);
      return favoriteModels.map((model) => model.toEntity()).toList();
    } on ServerException catch (e) {
      throw ServerFailure(message: e.message);
    } on TimeoutException catch (e) {
      throw TimeoutFailure(message: e.message);
    } catch (e) {
      throw GeneralFailure(message: 'An unexpected error occurred: ${e.toString()}');
    }
  }

  @override
  Future<bool> isRecipeFavorited(
      String userId, String recipeId) async {
    try {
      return await remoteDataSource.isRecipeFavorited(userId, recipeId);
    } on ServerException catch (e) {
      throw ServerFailure(message: e.message);
    } on TimeoutException catch (e) {
      throw TimeoutFailure(message: e.message);
    } catch (e) {
      throw GeneralFailure(message: 'An unexpected error occurred: ${e.toString()}');
    }
  }

@override
  Future<RecipeRatingResponseModel> addOrUpdateRecipeRating( // CHANGED RETURN TYPE
      String userId, int? spoonacularId, int score, Recipe recipe, {String? comment}) async {
    try {
      final recipeModel = RecipeModel.fromEntity(recipe);
      final ratingResponseModel = await remoteDataSource.addOrUpdateRecipeRating(
          userId, spoonacularId, score, recipeModel,
          comment: comment);
      
      // We now return the full response model, which contains the userRating, averageRating, and ratingCount.
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