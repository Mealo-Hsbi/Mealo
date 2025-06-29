// lib/features/recipe/domain/usecases/is_recipe_favorited.dart (ANGENOMMENE NEUE SIGNATUR)
import 'package:frontend/features/recipe/domain/entities/favorite.dart';
import 'package:frontend/core/error/failures.dart';
import 'package:frontend/features/recipe/domain/repositories/recipe_interaction_repository.dart'; // Oder woher auch immer Failure kommt

class IsRecipeFavorited {
  final RecipeInteractionRepository repository; // Oder welches Repo du verwendest

  IsRecipeFavorited(this.repository);

  // Muss Favorite? zurückgeben
  Future<Favorite?> call({
    required String userId,
    required String recipeId,
  }) async {
    try {
      final favorite = await repository.isRecipeFavorited(userId, recipeId);
      return favorite; // Sollte Favorite? zurückgeben
    } catch (e) {
      // Behandle hier, wenn das Repository einen Fehler wirft, wenn nicht gefunden
      if (e is ServerFailure && e.message.contains('404')) {
        return null; // Wenn 404 bedeutet "nicht gefunden"
      }
      rethrow; // Ansonsten Fehler weiterreichen
    }
  }
}