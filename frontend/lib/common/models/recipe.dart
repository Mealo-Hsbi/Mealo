// lib/common/models/recipe.dart (FINAL & PRAGMATISCHE VERSION)

import 'package:flutter/foundation.dart';
import 'package:frontend/common/models/ingredient.dart'; // Importiere dein Ingredient-Modell

class Recipe {
  final int? id; // <--- Jetzt nullable: Spoonacular ID
  final String? internalId; // <--- NEU: Interne UUID (String)
  final bool isInternal; // <--- NEU: Flag, ob es ein internes Rezept ist (Required!)

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

  final double? averageRating;
  final int? ratingCount;
  final bool? containsUserAllergens;
  final List<String>? matchedAllergens;

  const Recipe({
    this.id, // Kann null sein, wenn isInternal true ist
    this.internalId, // Kann null sein, wenn isInternal false ist
    required this.isInternal, // Muss immer gesetzt werden
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
    this.averageRating,
    this.ratingCount,
    this.containsUserAllergens,
    this.matchedAllergens,
  }) : assert(id != null || internalId != null, 'Either Spoonacular ID or internal ID must be provided.');


  factory Recipe.fromJson(Map<String, dynamic> json) {
    List<Ingredient>? parseIngredientList(List<dynamic>? list) {
      if (list == null) return null;
      return list.map((e) => Ingredient.fromJson(e as Map<String, dynamic>)).toList();
    }

    // ACHTUNG: Hier ist die Logik, um zu erkennen, ob es eine int-ID (Spoonacular) oder eine String-ID (intern) ist.
    // Dies hängt stark davon ab, wie dein Backend und die Spoonacular-API die IDs in den JSONs benennen/darstellen.
    int? parsedId;
    String? parsedInternalId;
    bool parsedIsInternal;

    // Annahme: Wenn 'spoonacularId' im JSON vorhanden ist, ist es primär ein Spoonacular-Rezept.
    // Wenn 'id' ein String ist, ist es primär ein internes Rezept.
    if (json['spoonacularId'] is int) { // Prüfe zuerst auf eine dedizierte Spoonacular ID im JSON
      parsedId = json['spoonacularId'] as int;
      parsedInternalId = json['id'] is String ? (json['id'] as String) : null; // Backend könnte auch interne ID mitschicken
      parsedIsInternal = false; // Standardmäßig extern, wenn Spoonacular-ID vorhanden
    } else if (json['id'] is String) { // Wenn die Haupt-ID ein String ist, dann ist es intern
      parsedInternalId = json['id'] as String;
      parsedId = null; // Keine Spoonacular ID, wenn es rein intern ist
      parsedIsInternal = true;
    } else if (json['id'] is int) { // Fallback: Wenn 'id' ein int ist, aber keine dedizierte 'spoonacularId'
      parsedId = json['id'] as int;
      parsedInternalId = null;
      parsedIsInternal = false;
    } else {
      // Sehr unwahrscheinlicher Fehlerfall
      debugPrint('Warning: Recipe JSON has no valid ID. Raw JSON: $json');
      parsedId = null;
      parsedInternalId = null;
      parsedIsInternal = false; // Standard auf extern
    }

    // Optional: Wenn dein Backend ein explizites 'isInternal' Feld liefert
    // parsedIsInternal = json['isInternal'] as bool? ?? parsedIsInternal;

    return Recipe(
      id: parsedId,
      internalId: parsedInternalId,
      isInternal: parsedIsInternal,
      name: (json['name'] as String?) ?? (json['title'] as String?) ?? 'Unnamed Recipe',
      imageUrl: (json['imageUrl'] as String?) ?? (json['image'] as String?) ?? '',
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
      averageRating: (json['averageRating'] as num?)?.toDouble(),
      ratingCount: json['ratingCount'] as int?,
      containsUserAllergens: json['containsUserAllergens'] as bool?,
      matchedAllergens: (json['matchedAllergens'] as List?)?.map((e) => e.toString()).toList(),
    );
  }

  // Ein Getter für eine eindeutige String-ID, nützlich für hashCode und ==
  // und für die Übergabe an Detail-Bildschirme, die einen String erwarten könnten.
  String get effectiveId {
    if (isInternal && internalId != null) return internalId!;
    if (!isInternal && id != null) return id.toString();
    // Dieser Fall sollte durch die Assertion im Konstruktor nicht eintreten.
    // Wenn er doch eintritt, ist es ein Datenproblem.
    debugPrint('Error: Recipe has no valid effective ID! isInternal: $isInternal, id: $id, internalId: $internalId');
    return 'invalid-id-for-recipe-$hashCode';
  }

  @override
  String toString() {
    return 'Recipe(id: $id, internalId: $internalId, isInternal: $isInternal, name: $name)';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Recipe &&
          runtimeType == other.runtimeType &&
          effectiveId == other.effectiveId; // Vergleich über die effektive ID

  @override
  int get hashCode => effectiveId.hashCode;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'internalId': internalId,
      'isInternal': isInternal,
      'name': name,
      'imageUrl': imageUrl,
      'place': place,
      'readyInMinutes': readyInMinutes,
      'servings': servings,
      'calories': calories,
      'protein': protein,
      'fat': fat,
      'carbs': carbs,
      'sugar': sugar,
      'healthScore': healthScore,
      'usedIngredientCount': usedIngredientCount,
      'missedIngredientCount': missedIngredientCount,
      'usedIngredients': usedIngredients?.map((e) => e.toJson()).toList(),
      'missedIngredients': missedIngredients?.map((e) => e.toJson()).toList(),
      'averageRating': averageRating,
      'ratingCount': ratingCount,
      'containsUserAllergens': containsUserAllergens,
      'matchedAllergens': matchedAllergens,
    };
  }
}