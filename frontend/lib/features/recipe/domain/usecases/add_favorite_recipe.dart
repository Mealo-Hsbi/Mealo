// lib/features/recipe/domain/usecases/add_favorite_recipe.dart
import 'package:frontend/features/recipe/domain/entities/favorite.dart'; // Import Favorite
import 'package:frontend/features/recipe/domain/entities/recipe.dart';
import 'package:frontend/features/recipe/domain/repositories/recipe_interaction_repository.dart';

class AddFavoriteRecipe {
  final RecipeInteractionRepository repository;

  AddFavoriteRecipe(this.repository);

  Future<Favorite> call({ // Change return type from void to Favorite
    required String userId,
    required int? spoonacularId,
    required Recipe recipe,
  }) async {
    return await repository.addFavoriteRecipe(
      userId,
      spoonacularId,
      recipe,
    );
  }
}