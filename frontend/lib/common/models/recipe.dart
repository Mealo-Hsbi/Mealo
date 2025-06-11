// lib/common/models/recipe.dart

import 'package:flutter/foundation.dart';
import 'package:frontend/common/models/ingredient.dart'; // Importiere dein Ingredient-Modell

class Recipe {
  final int id; // Die ID des Rezepts ist immer noch ein int von Spoonacular
  final String name;
  final String imageUrl;
  final String? place;
  final int? readyInMinutes;
  final int? servings;

  final double? calories;
  final double? protein;
  final double? fat;
  final double? carbs;
  final double? sugar;
  final int? healthScore;

  final int? usedIngredientCount;
  final int? missedIngredientCount;
  final List<Ingredient>? usedIngredients;
  final List<Ingredient>? missedIngredients;

  const Recipe({
    required this.id,
    required this.name,
    required this.imageUrl,
    this.place,
    this.readyInMinutes,
    this.servings,
    this.calories,
    this.protein,
    this.fat,
    this.carbs,
    this.sugar,
    this.healthScore,
    this.usedIngredientCount,
    this.missedIngredientCount,
    this.usedIngredients,
    this.missedIngredients,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    // Helper-Funktion zum Parsen einer Liste von Ingredients
    List<Ingredient>? parseIngredientList(List<dynamic>? list) {
      if (list == null) return null;
      return list.map((e) => Ingredient.fromJson(e as Map<String, dynamic>)).toList();
    }

    return Recipe(
      id: json['id'] as int,
      name: (json['name'] as String?) ?? 'Unnamed Recipe',
      imageUrl: (json['imageUrl'] as String?) ?? '',
      place: json['place'] as String?,
      readyInMinutes: json['readyInMinutes'] as int?,
      servings: json['servings'] as int?,
      calories: (json['calories'] as num?)?.toDouble(),
      protein: (json['protein'] as num?)?.toDouble(),
      fat: (json['fat'] as num?)?.toDouble(),
      carbs: (json['carbs'] as num?)?.toDouble(),
      sugar: (json['sugar'] as num?)?.toDouble(),
      healthScore: json['healthScore'] as int?,
      usedIngredientCount: json['usedIngredientCount'] as int?,
      missedIngredientCount: json['missedIngredientCount'] as int?,
      usedIngredients: parseIngredientList(json['usedIngredients'] as List?),
      missedIngredients: parseIngredientList(json['missedIngredients'] as List?),
    );
  }

  @override
  String toString() {
    return 'Recipe(id: $id, name: $name, used: $usedIngredientCount, missed: $missedIngredientCount)';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Recipe &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}