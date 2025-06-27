// lib/features/recipe/domain/usecases/get_favorite_recipes.dart
import 'package:frontend/features/recipe/domain/entities/favorite.dart';
import 'package:frontend/features/recipe/domain/repositories/recipe_interaction_repository.dart'; // <-- HIER IST DAS NEUE REPO!

class GetFavoriteRecipes {
  final RecipeInteractionRepository repository;

  GetFavoriteRecipes(this.repository);

  Future<List<Favorite>> call({
    required String userId,
  }) async {
    return await repository.getFavoriteRecipes(
      userId,
    );
  }
}