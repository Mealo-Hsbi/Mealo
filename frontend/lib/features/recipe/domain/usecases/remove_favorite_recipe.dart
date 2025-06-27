// lib/features/recipe/domain/usecases/remove_favorite_recipe.dart
import 'package:frontend/features/recipe/domain/repositories/recipe_interaction_repository.dart'; // <-- HIER IST DAS NEUE REPO!

class RemoveFavoriteRecipe {
  final RecipeInteractionRepository repository;

  RemoveFavoriteRecipe(this.repository);

  Future<void> call({
    required String userId,
    required String favoriteId, // Dies ist die UUID des Favoriteneintrags in IHRER DB
  }) async {
    return await repository.removeFavoriteRecipe(
      userId,
      favoriteId,
    );
  }
}