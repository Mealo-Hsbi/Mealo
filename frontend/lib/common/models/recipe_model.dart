// lib/common/models/recipe_model.dart

import 'package:frontend/common/models/recipe.dart';
import 'package:flutter/foundation.dart'; // Make sure this import is present for debugPrint

class RecipeModel {
  final int id;
  final String name;
  final String? imageUrl;
  final String? place;
  final int? readyInMinutes;
  final int? servings;

  // ANPASSUNG HIER:
  // Alle Nährwertfelder auf double? ändern
  final double? calories; // WAR VORHER int?, ist jetzt double?
  final double? protein;
  final double? fat;
  final double? carbs;
  final double? sugar;
  final int? healthScore; // HealthScore ist oft eine ganze Zahl, bleibt int?
  final int? matchingIngredientsCount;
  final int? missingIngredientsCount;

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
    this.matchingIngredientsCount,
    this.missingIngredientsCount,
  });

  factory RecipeModel.fromJson(Map<String, dynamic> json) {
    debugPrint('--- Flutter RecipeModel.fromJson - Incoming JSON for Recipe ID ${json['id']}: ---');
    debugPrint(json.toString()); // Print the full JSON received by Flutter for this recipe

    return RecipeModel(
      id: json['id'] as int,
      name: (json['name'] as String?) ?? 'Unnamed Recipe',
      imageUrl: json['imageUrl'] as String?,
      place: json['place'] as String?,
      readyInMinutes: json['readyInMinutes'] as int?,
      servings: json['servings'] as int?,
      // ANPASSUNG HIER BEIM PARSEN:
      // Verwende .toDouble() für num-Werte, die Double sein könnten.
      // json['calories'] as num? holt den Wert als num (Oberklasse von int und double)
      // .toDouble() konvertiert ihn dann sicher zu double.
      calories: (json['calories'] as num?)?.toDouble(), // <-- HIER
      protein: (json['protein'] as num?)?.toDouble(),
      fat: (json['fat'] as num?)?.toDouble(),
      carbs: (json['carbs'] as num?)?.toDouble(),
      sugar: (json['sugar'] as num?)?.toDouble(),
      healthScore: json['healthScore'] as int?, // Bleibt int
      matchingIngredientsCount: json['matchingIngredientsCount'] as int?,
      missingIngredientsCount: json['missingIngredientsCount'] as int?,
    );
  }

  // WICHTIG: Wenn du eine seperate Recipe-Entity hast, muss diese auch angepasst werden!
  Recipe toEntity() {
    return Recipe(
      id: id,
      name: name,
      imageUrl: imageUrl ?? '',
      place: place,
      readyInMinutes: readyInMinutes,
      servings: servings,
      calories: calories, // Wenn calories in Recipe auch double ist, ist das OK
      protein: protein,
      fat: fat,
      carbs: carbs,
      sugar: sugar,
      healthScore: healthScore,
      matchingIngredientsCount: matchingIngredientsCount,
      missingIngredientsCount: missingIngredientsCount,
    );
  }
}