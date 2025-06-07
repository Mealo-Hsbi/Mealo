// lib/common/models/recipe_details.dart

import 'package:flutter/foundation.dart'; // For debugPrint in dev mode
import 'package:html_unescape/html_unescape.dart'; // For HTML unescaping

// Importiere deine ausgelagerten Modelle
import 'package:frontend/common/models/nutrition/nutrition.dart';
import 'package:frontend/common/models/recipe/extended_ingredient.dart';
import 'package:frontend/common/models/recipe/analyzed_instruction_set.dart';
// InstructionStep wird über AnalyzedInstructionSet importiert

class RecipeDetails {
  final int id;
  final String title;
  final String? image;
  final String? imageType;
  final int? servings;
  final int? readyInMinutes;
  final String? sourceUrl;
  final String? sourceName;
  final String? summary;
  final int? aggregateLikes;
  final double? healthScore;
  final double? pricePerServing;
  final List<String>? dishTypes;
  final List<String>? diets;
  final List<String>? intolerances;
  final List<ExtendedIngredient>? extendedIngredients;
  final List<AnalyzedInstructionSet>? analyzedInstructions;

  final double? calories;
  final double? protein;
  final double? fat;
  final double? carbs;
  final double? sugar;

  final Nutrition? nutrition;

  const RecipeDetails({
    required this.id,
    required this.title,
    this.image,
    this.imageType,
    this.servings,
    this.readyInMinutes,
    this.sourceUrl,
    this.sourceName,
    this.summary,
    this.aggregateLikes,
    this.healthScore,
    this.pricePerServing,
    this.dishTypes,
    this.diets,
    this.intolerances,
    this.extendedIngredients,
    this.analyzedInstructions,
    this.calories,
    this.protein,
    this.fat,
    this.carbs,
    this.sugar,
    this.nutrition,
  });

  factory RecipeDetails.fromJson(Map<String, dynamic> json) {
    // Clean up summary HTML
    final String? rawSummary = json['summary'] as String?;
    final String? cleanSummary = rawSummary != null
        ? HtmlUnescape().convert(rawSummary.replaceAll(RegExp(r'<[^>]*>'), ''))
        : null;

    Nutrition? parsedNutrition;
    if (json['nutrition'] is Map<String, dynamic>) {
      try {
        parsedNutrition = Nutrition.fromJson(json['nutrition'] as Map<String, dynamic>);
      } catch (e, st) {
        debugPrint('Error parsing detailed Nutrition object for Recipe ID ${json['id']}: $e\nStack: $st');
        // raw JSON for nutrition is already logged by Nutrition.fromJson
      }
    }

    try {
      return RecipeDetails(
        id: json['id'] as int,
        title: json['title'] as String,
        image: json['image'] as String?,
        imageType: json['imageType'] as String?,
        servings: json['servings'] as int?,
        readyInMinutes: json['readyInMinutes'] as int?,
        sourceUrl: json['sourceUrl'] as String?,
        sourceName: json['sourceName'] as String?,
        summary: cleanSummary,
        aggregateLikes: json['aggregateLikes'] as int?,
        healthScore: (json['healthScore'] as num?)?.toDouble(),
        pricePerServing: (json['pricePerServing'] as num?)?.toDouble(),

        dishTypes: _parseStringList(json['dishTypes']),
        diets: _parseStringList(json['diets']),
        intolerances: _parseStringList(json['intolerances']),

        extendedIngredients: _parseList(json['extendedIngredients'], ExtendedIngredient.fromJson),
        analyzedInstructions: _parseList(json['analyzedInstructions'], AnalyzedInstructionSet.fromJson),

        calories: (json['calories'] as num?)?.toDouble(),
        protein: (json['protein'] as num?)?.toDouble(),
        fat: (json['fat'] as num?)?.toDouble(),
        carbs: (json['carbs'] as num?)?.toDouble(),
        sugar: (json['sugar'] as num?)?.toDouble(),

        nutrition: parsedNutrition,
      );
    } catch (e, st) {
      debugPrint('ERROR: Failed to create RecipeDetails instance from JSON for ID ${json['id']}: $e\nStack: $st');
      debugPrint('Problematic JSON (truncated): ${json.toString().substring(0, json.toString().length > 500 ? 500 : json.toString().length)}...');
      rethrow;
    }
  }

  // Private helper for parsing simple string lists
  static List<String>? _parseStringList(dynamic jsonList) {
    if (jsonList is List) {
      return jsonList.map((item) => item.toString()).toList();
    }
    return null;
  }

  // Generic private helper for parsing lists of models
  static List<T>? _parseList<T>(dynamic jsonList, T Function(Map<String, dynamic>) fromJsonT) {
    if (jsonList is List) {
      return jsonList
          .whereType<Map<String, dynamic>>() // Only take valid maps
          .map(fromJsonT)
          .toList();
    }
    return null;
  }

  RecipeDetails copyWith({
    int? id,
    String? title,
    String? image,
    String? imageType,
    int? servings,
    int? readyInMinutes,
    String? sourceUrl,
    String? sourceName,
    String? summary,
    int? aggregateLikes,
    double? healthScore,
    double? pricePerServing,
    List<String>? dishTypes,
    List<String>? diets,
    List<String>? intolerances,
    List<ExtendedIngredient>? extendedIngredients,
    List<AnalyzedInstructionSet>? analyzedInstructions,
    double? calories,
    double? protein,
    double? fat,
    double? carbs,
    double? sugar,
    Nutrition? nutrition,
  }) {
    return RecipeDetails(
      id: id ?? this.id,
      title: title ?? this.title,
      image: image ?? this.image,
      imageType: image ?? this.imageType,
      servings: servings ?? this.servings,
      readyInMinutes: readyInMinutes ?? this.readyInMinutes,
      sourceUrl: sourceUrl ?? this.sourceUrl,
      sourceName: sourceName ?? this.sourceName,
      summary: summary ?? this.summary,
      aggregateLikes: aggregateLikes ?? this.aggregateLikes,
      healthScore: healthScore ?? this.healthScore,
      pricePerServing: pricePerServing ?? this.pricePerServing,
      dishTypes: dishTypes ?? this.dishTypes,
      diets: diets ?? this.diets,
      intolerances: intolerances ?? this.intolerances,
      extendedIngredients: extendedIngredients ?? this.extendedIngredients,
      analyzedInstructions: analyzedInstructions ?? this.analyzedInstructions,
      calories: calories ?? this.calories,
      protein: protein ?? this.protein,
      fat: fat ?? this.fat,
      carbs: carbs ?? this.carbs,
      sugar: sugar ?? this.sugar,
      nutrition: nutrition ?? this.nutrition,
    );
  }

  @override
  String toString() {
    final double? currentCalories = calories ?? nutrition?.nutrients.firstWhere(
      (n) => n.name == 'Calories',
      orElse: () => const Nutrient(name: 'Calories', amount: 0, unit: 'kcal', percentOfDailyNeeds: 0), // Provide a valid default Nutrient
    ).amount; // Access amount on the found orElse Nutrient

    return 'RecipeDetails(id: $id, title: $title, readyInMinutes: $readyInMinutes, '
        'ingredients: ${extendedIngredients?.length ?? 0}, '
        'calories: ${currentCalories?.toStringAsFixed(0) ?? 'N/A'} kcal)';
  }
}