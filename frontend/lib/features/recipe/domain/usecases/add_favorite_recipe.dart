// lib/features/recipe/domain/usecases/add_favorite_recipe.dart
import 'package:frontend/features/recipe/domain/entities/recipe.dart';
import 'package:frontend/features/recipe/domain/repositories/recipe_interaction_repository.dart';

class AddFavoriteRecipe {
  final RecipeInteractionRepository repository;

  AddFavoriteRecipe(this.repository);

  Future<void> call({
    required String userId,
    int? spoonacularId, // <-- GEÄNDERT: Jetzt nullable
    required Recipe recipe,
  }) async {
    return await repository.addFavoriteRecipe(
      userId,
      spoonacularId, // <-- Hier als nullable übergeben
      recipe,
    );
  }
}