// lib/features/recipe/domain/usecases/get_user_recipe_rating.dart
import 'package:frontend/features/recipe/domain/entities/recipe_rating.dart';
import 'package:frontend/features/recipe/domain/repositories/recipe_interaction_repository.dart'; // <-- HIER IST DAS NEUE REPO!

class GetUserRecipeRating {
  final RecipeInteractionRepository repository;

  GetUserRecipeRating(this.repository);

  Future<RecipeRating?> call({ // Kann null zurückgeben, wenn keine Bewertung existiert
    required String userId,
    required String recipeId, // UUID des Rezepts in IHRER DB
  }) async {
    return await repository.getUserRecipeRating(
      userId,
      recipeId,
    );
  }
}