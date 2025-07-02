// lib/features/recipe/domain/usecases/add_or_update_recipe_rating.dart

import 'package:frontend/features/recipe/domain/entities/recipe.dart';
import 'package:frontend/features/recipe/domain/repositories/recipe_interaction_repository.dart';
import 'package:frontend/features/recipe/data/models/recipe_rating_response_model.dart'; // Import the combined model

class AddOrUpdateRecipeRating {
  final RecipeInteractionRepository repository;

  AddOrUpdateRecipeRating(this.repository);

  // CHANGE RETURN TYPE: Now returns the combined response model
  Future<RecipeRatingResponseModel> call({
    required String userId,
    int? spoonacularId,
    required int score,
    required Recipe recipe,
    String? comment,
  }) async {
    // The repository method (which you've already updated) will return this combined model
    return await repository.addOrUpdateRecipeRating(
      userId,
      spoonacularId,
      score,
      recipe,
      comment: comment,
    );
  }
}