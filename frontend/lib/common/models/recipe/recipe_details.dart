// lib/common/models/recipe/recipe_details.dart

import 'package:flutter/foundation.dart';
import 'package:html_unescape/html_unescape.dart';

import 'package:frontend/common/models/nutrition/nutrition.dart';
import 'package:frontend/common/models/recipe/extended_ingredient.dart';
import 'package:frontend/common/models/recipe/analyzed_instruction_set.dart';
import 'package:frontend/features/recipe/domain/entities/recipe.dart';
import 'package:frontend/features/recipe/data/models/recipe_rating_model.dart'; // NEU: Import für RecipeRatingModel

class RecipeDetails {
  final int? spoonacularId; // <--- HIER WICHTIGE ÄNDERUNG: Jetzt nullable!
  final String? id; // Interne DB-ID (UUID), kommt jetzt als 'internalRecipeId'
  final String title;
  final String? image; // kann null sein
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

  final RecipeRatingModel? userRating;
  final double? averageRating;
  final int? ratingCount;

  const RecipeDetails({
    this.spoonacularId, // <--- HIER WICHTIGE ÄNDERUNG: Nicht mehr required!
    this.id, // Interne ID
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
    this.userRating,
    this.averageRating,
    this.ratingCount,
  });

  factory RecipeDetails.fromJson(Map<String, dynamic> json) {
    final String? rawSummary = json['summary'] as String?;
    String? cleanSummary;
    if (rawSummary != null) {
      String filteredSummary = rawSummary.replaceAll(RegExp(r'<a[^>]*>.*?</a>'), '');
      filteredSummary = filteredSummary.replaceAll(RegExp(r'<img[^>]*>'), '');
      cleanSummary = HtmlUnescape().convert(filteredSummary);
    }

    Nutrition? parsedNutrition;
    if (json['nutrition'] is Map<String, dynamic>) {
      try {
        parsedNutrition = Nutrition.fromJson(json['nutrition'] as Map<String, dynamic>);
      } catch (e, st) {
        debugPrint('Error parsing detailed Nutrition object for Recipe ID ${json['id']}: $e\nStack: $st');
      }
    }

    RecipeRatingModel? parsedUserRating;
    if (json['userRating'] != null) {
      try {
        parsedUserRating = RecipeRatingModel.fromJson(json['userRating'] as Map<String, dynamic>);
      } catch (e, st) {
        debugPrint('Error parsing userRating for Recipe ID ${json['id']}: $e\nStack: $st');
      }
    }

    try {
      return RecipeDetails(
        spoonacularId: json['spoonacularId'] is int
            ? json['spoonacularId']
            : int.tryParse(json['spoonacularId']?.toString() ?? ''),
        id: json['internalRecipeId']?.toString() ?? json['id']?.toString(),
        title: json['title'] as String,
        image: json['image'] as String? ?? json['imageUrl'] as String?,
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
        averageRating: (json['averageRating'] as num?)?.toDouble(),
        ratingCount: json['ratingCount'] as int?,
        userRating: parsedUserRating,
      );
    } catch (e, st) {
      debugPrint('ERROR: Failed to create RecipeDetails instance from JSON for Recipe ID ${json['id']}: $e\nStack: $st');
      debugPrint('Problematic JSON (truncated): ${json.toString().substring(0, json.toString().length > 500 ? 500 : json.toString().length)}...');
      rethrow;
    }
  }

  static List<String>? _parseStringList(dynamic jsonList) {
    if (jsonList is List) {
      return jsonList.map((item) => item.toString()).toList();
    }
    return null;
  }

  static List<T>? _parseList<T>(dynamic jsonList, T Function(Map<String, dynamic>) fromJsonT) {
    if (jsonList is List) {
      return jsonList
          .whereType<Map<String, dynamic>>()
          .map(fromJsonT)
          .toList();
    }
    return null;
  }

  Recipe toRecipe() {
    return Recipe(
      id: id,
      spoonacularId: spoonacularId, // <--- HIER AUCH ANPASSEN, wenn Recipe Entity angepasst wird
      title: title,
      imageUrl: image ?? '',
    );
  }

  RecipeDetails copyWith({
    String? id,
    int? spoonacularId, // <--- HIER AUCH ÄNDERUNG: Nun nullable!
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
    RecipeRatingModel? userRating,
    double? averageRating,
    int? ratingCount,
  }) {
    return RecipeDetails(
      id: id ?? this.id,
      spoonacularId: spoonacularId ?? this.spoonacularId, // <--- HIER AUCH ANPASSEN
      title: title ?? this.title,
      image: image ?? this.image,
      imageType: imageType ?? this.imageType,
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
      userRating: userRating ?? this.userRating,
      averageRating: averageRating ?? this.averageRating,
      ratingCount: ratingCount ?? this.ratingCount,
    );
  }

  @override
  String toString() {
    final double? currentCalories = calories ?? nutrition?.nutrients.firstWhere(
      (n) => n.name == 'Calories',
      orElse: () => const Nutrient(name: 'Calories', amount: 0, unit: 'kcal', percentOfDailyNeeds: 0),
    ).amount;

    return 'RecipeDetails(spoonacularId: $spoonacularId, internalId: $id, title: $title, readyInMinutes: $readyInMinutes, '
        'ingredients: ${extendedIngredients?.length ?? 0}, '
        'calories: ${currentCalories?.toStringAsFixed(0) ?? 'N/A'} kcal, '
        'userRating: ${userRating?.score ?? 'N/A'}, averageRating: ${averageRating?.toStringAsFixed(1) ?? 'N/A'}, ratingCount: ${ratingCount ?? 0})';
  }
}