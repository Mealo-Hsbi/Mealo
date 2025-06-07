import 'package:frontend/common/models/recipe/recipe_details.dart'; // Dein RecipeDetails Modell
import 'package:frontend/features/search/domain/repositories/recipe_repository.dart'; // Dein RecipeRepository

class GetRecipeDetails {
  final RecipeRepository _repository;

  GetRecipeDetails(this._repository);

  // Die 'call'-Methode macht die Use-Case-Instanz aufrufbar wie eine Funktion.
  Future<RecipeDetails> call(int recipeId) async {
    return await _repository.getRecipeDetails(recipeId);
  }
}