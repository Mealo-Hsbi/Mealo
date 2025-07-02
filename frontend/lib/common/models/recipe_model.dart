// lib/common/models/recipe_model.dart (UPDATED)

import 'package:frontend/common/models/recipe.dart'; // Ensure this is the correct import for your common Recipe entity
import 'package:flutter/foundation.dart';
import 'package:frontend/common/models/ingredient.dart';

class RecipeModel {
  final int? id; // Now nullable to align with common/models/recipe.dart (Spoonacular ID)
  final String? internalId; // NEW: Internal UUID (String)
  final bool isInternal; // NEW: Flag to indicate if it's an internal recipe

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

  final int? usedIngredientCount;
  final int? missedIngredientCount;

  final List<Ingredient>? usedIngredients;
  final List<Ingredient>? missedIngredients;

  final double? averageRating;
  final int? ratingCount;

  final bool? containsUserAllergens;
  final List<String>? matchedAllergens;

  RecipeModel({
    this.id, // Now nullable
    this.internalId, // Add this to the constructor
    required this.isInternal, // Add this to the constructor
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
    this.usedIngredientCount,
    this.missedIngredientCount,
    this.usedIngredients,
    this.missedIngredients,
    this.averageRating,
    this.ratingCount,
    this.containsUserAllergens,
    this.matchedAllergens,
  }) : assert(id != null || internalId != null, 'Either Spoonacular ID or internal ID must be provided.');


  factory RecipeModel.fromJson(Map<String, dynamic> json) {
    List<Ingredient>? parseIngredientList(List<dynamic>? list) {
      if (list == null) return null;
      return list.map((e) => Ingredient.fromJson(e as Map<String, dynamic>)).toList();
    }

    // Logic to determine ID type and isInternal flag
    int? parsedId;
    String? parsedInternalId;
    bool parsedIsInternal;

    // This logic should match what you defined in common/models/recipe.dart's fromJson
    // to ensure consistency when parsing incoming data.
    if (json['spoonacularId'] is int) {
      parsedId = json['spoonacularId'] as int;
      parsedInternalId = json['id'] is String ? (json['id'] as String) : null;
      parsedIsInternal = false;
    } else if (json['id'] is String) {
      parsedInternalId = json['id'] as String;
      parsedId = null;
      parsedIsInternal = true;
    } else if (json['id'] is int) { // Fallback if 'id' is int but no 'spoonacularId' key
      parsedId = json['id'] as int;
      parsedInternalId = null;
      parsedIsInternal = false;
    } else {
      debugPrint('Warning: Recipe JSON has no valid ID for RecipeModel. Raw JSON: $json');
      parsedId = null;
      parsedInternalId = null;
      parsedIsInternal = false;
    }

    // If your backend explicitly sends an 'isInternal' flag, you might use it here:
    // parsedIsInternal = json['isInternal'] as bool? ?? parsedIsInternal;


    return RecipeModel(
      id: parsedId, // Use the parsed Spoonacular ID
      internalId: parsedInternalId, // Use the parsed internal ID
      isInternal: parsedIsInternal, // Use the parsed isInternal flag
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

  // WICHTIG: Die toEntity() Methode muss ebenfalls die neuen Felder übergeben!
  Recipe toEntity() {
    return Recipe(
      id: id,             // Pass the Spoonacular ID
      internalId: internalId, // Pass the internal ID
      isInternal: isInternal, // Pass the isInternal flag
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
      usedIngredientCount: usedIngredientCount,
      missedIngredientCount: missedIngredientCount,
      usedIngredients: usedIngredients,
      missedIngredients: missedIngredients,
      averageRating: averageRating,
      ratingCount: ratingCount,
      containsUserAllergens: containsUserAllergens,
      matchedAllergens: matchedAllergens,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'spoonacularId': id,
      if (internalId != null) 'id': internalId,
      'isInternal': isInternal,
      'name': name,
      'title': name,
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