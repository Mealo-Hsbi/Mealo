// // lib/features/search/domain/usecases/search_recipes.dart

// import 'package:frontend/common/models/recipe.dart';
// // import 'package:frontend/common/models/ingredient.dart'; // Diese Zeile kann entfernt werden, da wir List<String> verwenden
// import 'package:frontend/features/search/domain/repositories/recipe_repository.dart';

// class SearchRecipes {
//   final RecipeRepository repository;

//   SearchRecipes(this.repository);

//   Future<List<Recipe>> call({
//     required String query,
//     // **Korrektur:** ingredients erwartet jetzt List<String>
//     List<String>? ingredients, // VORHER war das List<Ingredient> in meinem vorherigen Vorschlag, jetzt ist es String!
//     int offset = 0,
//     int number = 10,
//     String? sortBy,
//     String? sortDirection,
//     Map<String, dynamic>? filters,
//     int? maxMissingIngredients, // Dieser Parameter ist bereits korrekt
//   }) async {
//     return await repository.searchRecipes(
//       query: query,
//       ingredients: ingredients, // Hier einfach die übergebene Liste weiterleiten
//       offset: offset,
//       number: number,
//       sortBy: sortBy,
//       sortDirection: sortDirection,
//       filters: filters,
//       maxMissingIngredients: maxMissingIngredients,
//     );
//   }
// }