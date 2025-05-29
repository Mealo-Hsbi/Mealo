// lib/features/search/domain/repositories/recipe_repository.dart

import 'package:frontend/common/models/ingredient.dart';
import 'package:frontend/common/models/recipe.dart';
import 'package:frontend/common/models/recipe_details.dart'; // Für zukünftige Details

/// Abstrakte Klasse, die den Vertrag für die Rezeptdaten-Operationen definiert.
/// Die Domain-Schicht (z.B. Usecases oder UI) wird nur dieses Interface kennen.
abstract class RecipeRepository {
  /// Sucht nach Rezepten basierend auf einem Suchbegriff und ausgewählten Zutaten.
  /// Gibt eine Liste von grundlegenden Rezept-Objekten zurück.
  Future<List<Recipe>> searchRecipes({
    required String query,
    List<Ingredient>? selectedIngredients,
    Map<String, dynamic>? filters,
    String? sortBy,
    String? sortDirection,
  });

  /// Ruft detaillierte Informationen für ein spezifisches Rezept ab.
  /// Gibt ein detailliertes Rezept-Objekt zurück.
  Future<RecipeDetails> getRecipeDetails(int recipeId);
}