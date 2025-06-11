// lib/common/models/recipe_model.dart

import 'package:frontend/common/models/recipe.dart';
import 'package:flutter/foundation.dart';
import 'package:frontend/common/models/ingredient.dart'; // NEU: Importiere Ingredient

class RecipeModel {
  final int id;
  final String name;
  final String? imageUrl;
  final String? place;
  final int? readyInMinutes;
  final int? servings;

  final double? calories;
  final double? protein;
  final double? fat;
  final double? carbs;
  final double? sugar;
  final int? healthScore;

  // Die alten Felder werden zu den neuen Namen gemappt,
  // da das Backend jetzt direkt von Spoonacular die Namen used/missedIngredientCount liefert.
  final int? usedIngredientCount; 
  final int? missedIngredientCount; 

  // NEU: Detaillierte Listen der verwendeten und fehlenden Zutaten
  final List<Ingredient>? usedIngredients;
  final List<Ingredient>? missedIngredients;


  RecipeModel({
    required this.id,
    required this.name,
    this.imageUrl,
    this.place,
    this.readyInMinutes,
    this.servings,
    this.calories,
    this.protein,
    this.fat,
    this.carbs,
    this.sugar,
    this.healthScore,
    this.usedIngredientCount, // Feldnamen im Konstruktor anpassen
    this.missedIngredientCount, // Feldnamen im Konstruktor anpassen
    this.usedIngredients, // NEU
    this.missedIngredients, // NEU
  });

  factory RecipeModel.fromJson(Map<String, dynamic> json) {
    List<Ingredient>? parseIngredientList(List<dynamic>? list) {
      if (list == null) return null;
      return list.map((e) => Ingredient.fromJson(e as Map<String, dynamic>)).toList();
    }

    return RecipeModel(
      id: json['id'] as int,
      name: (json['name'] as String?) ?? 'Unnamed Recipe',
      imageUrl: json['imageUrl'] as String?,
      place: json['place'] as String?,
      readyInMinutes: json['readyInMinutes'] as int?,
      servings: json['servings'] as int?,

      calories: (json['calories'] as num?)?.toDouble(),
      protein: (json['protein'] as num?)?.toDouble(),
      fat: (json['fat'] as num?)?.toDouble(),
      carbs: (json['carbs'] as num?)?.toDouble(),
      sugar: (json['sugar'] as num?)?.toDouble(),
      healthScore: json['healthScore'] as int?,

      // Die Zähler direkt übernehmen
      usedIngredientCount: json['usedIngredientCount'] as int?, // Angepasster JSON-Key
      missedIngredientCount: json['missedIngredientCount'] as int?, // Angepasster JSON-Key

      // NEU: Die detaillierten Listen parsen
      usedIngredients: parseIngredientList(json['usedIngredients'] as List?),
      missedIngredients: parseIngredientList(json['missedIngredients'] as List?),
    );
  }

  // WICHTIG: Die toEntity() Methode muss ebenfalls die neuen Felder übergeben!
  Recipe toEntity() {
    return Recipe(
      id: id,
      name: name,
      imageUrl: imageUrl ?? '',
      place: place,
      readyInMinutes: readyInMinutes,
      servings: servings,
      calories: calories,
      protein: protein,
      fat: fat,
      carbs: carbs,
      sugar: sugar,
      healthScore: healthScore,
      usedIngredientCount: usedIngredientCount, // Feldnamen anpassen
      missedIngredientCount: missedIngredientCount, // Feldnamen anpassen
      usedIngredients: usedIngredients, // NEU
      missedIngredients: missedIngredients, // NEU
    );
  }
}