// lib/features/recipe/domain/entities/recipe.dart
import 'package:equatable/equatable.dart';
// Importiere hier KEINE spezifischen Modelle wie 'Ingredient' oder 'ExtendedIngredient',
// da dies Domain-Entitäten sein sollen.

class Recipe extends Equatable {
  // NEU: id ist die UUID des Rezepts aus IHRER EIGENEN Datenbank.
  // Optional, da ein Rezept existieren kann, ohne in Ihrer DB gespeichert zu sein.
  final String? id;

  // Die ursprüngliche ID von Spoonacular (int)
  final int? spoonacularId;

  final String title; // Entspricht 'name' in Ihrem common/models/recipe.dart
  final String? imageUrl; // Entspricht 'imageUrl' in beiden common/models
  final int? servings; // Entspricht 'servings' in beiden common/models
  final int? readyInMinutes; // Entspricht 'readyInMinutes' in beiden common/models
  final String? summary; // Kommt von common/models/recipe_details.dart
  final double? healthScore; // Entspricht 'healthScore' in beiden common/models

  // Mögliche weitere Felder aus RecipeDetails, die Sie im Domain-Layer brauchen:
  final List<String>? dishTypes;
  final List<String>? diets;
  final List<String>? intolerances;

  // Diese booleschen Felder kommen oft von Spoonacular oder Ihrer DB
  final bool? isVegan;
  final bool? isVegetarian;
  final bool? isGlutenFree;
  final bool? isDairyFree;

  const Recipe({
    this.id, // <-- NEU: Interne DB-ID
    this.spoonacularId, // <-- Umbennant von 'id'
    required this.title,
    this.imageUrl,
    this.servings,
    this.readyInMinutes,
    this.summary,
    this.healthScore,
    this.dishTypes,
    this.diets,
    this.intolerances,
    this.isVegan,
    this.isVegetarian,
    this.isGlutenFree,
    this.isDairyFree,
  });

  @override
  List<Object?> get props => [
        id,
        spoonacularId,
        title,
        imageUrl,
        servings,
        readyInMinutes,
        summary,
        healthScore,
        dishTypes,
        diets,
        intolerances,
        isVegan,
        isVegetarian,
        isGlutenFree,
        isDairyFree,
      ];
}