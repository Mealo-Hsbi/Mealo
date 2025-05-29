// lib/features/search/domain/usecases/search_recipes.dart

import 'package:frontend/common/models/ingredient.dart';
import 'package:frontend/common/models/recipe.dart';
import 'package:frontend/features/search/domain/repositories/recipe_repository.dart'; // Wichtig: Das abstrakte Repository-Interface!

/// Ein Usecase, der für die Logik der Rezeptsuche verantwortlich ist.
/// Er interagiert mit dem [RecipeRepository], um Rezepte zu suchen.
class SearchRecipes {
  final RecipeRepository repository; // Abhängigkeit zum abstrakten Repository

  SearchRecipes(this.repository);

  /// Führt die Rezeptsuche aus.
  ///
  /// [query]: Der Hauptsuchbegriff (z.B. "chicken pasta").
  /// [selectedIngredients]: Eine Liste von Zutaten, die im Rezept enthalten sein sollen.
  /// [filters]: Optionale Filter (z.B. {'minCalories': 300, 'diet': 'vegetarian'}).
  /// [sortBy]: Feld, nach dem sortiert werden soll (z.B. 'calories').
  /// [sortDirection]: Sortierrichtung ('asc' oder 'desc').
  ///
  /// Gibt eine Future zurück, die eine Liste von [Recipe]-Objekten enthält.
  Future<List<Recipe>> call({ // Die 'call'-Methode macht die Instanz direkt aufrufbar
    required String query,
    List<Ingredient>? selectedIngredients,
    Map<String, dynamic>? filters,
    String? sortBy,
    String? sortDirection,
  }) async {
    // Hier könnte weitere Geschäftslogik stehen, BEVOR das Repository aufgerufen wird.
    // Z.B. Validierungen, Logik zur Kombination von Query und Zutaten, etc.
    // Für unser Beispiel rufen wir das Repository direkt auf.

    // Wenn der Query leer ist und keine Zutaten ausgewählt sind,
    // können wir hier entscheiden, keine Suche durchzuführen und eine leere Liste zurückzugeben.
    // Das ist eine Geschäftsregel, die im Usecase sitzt.
    if (query.isEmpty && (selectedIngredients == null || selectedIngredients.isEmpty)) {
      return [];
    }

    // Übergibt die Anfrage an das Repository
    return await repository.searchRecipes(
      query: query,
      selectedIngredients: selectedIngredients,
      filters: filters,
      sortBy: sortBy,
      sortDirection: sortDirection,
    );
  }
}