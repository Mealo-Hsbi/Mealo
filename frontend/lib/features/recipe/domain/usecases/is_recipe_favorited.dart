// lib/features/recipe/domain/usecases/is_recipe_favorited.dart
import 'package:frontend/features/recipe/domain/repositories/recipe_interaction_repository.dart'; // <-- HIER IST DAS NEUE REPO!

class IsRecipeFavorited {
  final RecipeInteractionRepository repository;

  IsRecipeFavorited(this.repository);

  Future<bool> call({
    required String userId,
    required String recipeId, // UUID des Rezepts in IHRER DB
  }) async {
    return await repository.isRecipeFavorited(
      userId,
      recipeId,
    );
  }
}