// lib/features/recipe/domain/usecases/add_or_update_recipe_rating.dart
import 'package:frontend/features/recipe/domain/entities/recipe.dart';
import 'package:frontend/features/recipe/domain/entities/recipe_rating.dart';
import 'package:frontend/features/recipe/domain/repositories/recipe_interaction_repository.dart';

class AddOrUpdateRecipeRating {
  final RecipeInteractionRepository repository;

  AddOrUpdateRecipeRating(this.repository);

  Future<RecipeRating> call({
    required String userId,
    int? spoonacularId, // <-- GEÄNDERT: Jetzt nullable
    required int score,
    required Recipe recipe,
    String? comment,
  }) async {
    return await repository.addOrUpdateRecipeRating(
      userId,
      spoonacularId, // <-- Hier als nullable übergeben
      score,
      recipe,
      comment: comment,
    );
  }
}