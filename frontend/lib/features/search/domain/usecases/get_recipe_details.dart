// lib/features/search/domain/usecases/get_recipe_details.dart (ANGEPASST)

import 'package:frontend/common/models/recipe/recipe_details.dart'; // Dein RecipeDetails Modell
import 'package:frontend/features/search/domain/repositories/recipe_repository.dart'; // Dein RecipeRepository

class GetRecipeDetails {
  final RecipeRepository _repository;

  GetRecipeDetails(this._repository);

  // Die 'call'-Methode akzeptiert jetzt beide ID-Typen und das isInternal-Flag
  Future<RecipeDetails> call({
    int? recipeId, // Für Spoonacular-ID (optional)
    String? internalRecipeId, // Für interne UUID (optional)
    required bool isInternal, // Muss angeben, welche Art von Rezept es ist
  }) async {
    if (isInternal) {
      if (internalRecipeId == null) {
        throw ArgumentError('internalRecipeId must not be null for internal recipes.');
      }
      // Hier muss dein Repository die Methode für interne IDs haben
      return await _repository.getInternalRecipeDetails(internalRecipeId);
    } else {
      if (recipeId == null) {
        throw ArgumentError('recipeId (Spoonacular ID) must not be null for external recipes.');
      }
      return await _repository.getRecipeDetails(recipeId);
    }
  }
}