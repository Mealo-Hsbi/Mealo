// lib/common/models/recipe_details.dart

import 'package:flutter/foundation.dart'; // For debugPrint in dev mode
import 'package:html_unescape/html_unescape.dart'; // For HTML unescaping

// Importe deine anderen Modelle
import 'package:frontend/common/models/nutrition.dart'; // Angenommen, dies ist eine separate Datei
// import 'package:frontend/common/models/recipe.dart'; // Unnötig, da RecipeDetails detaillierter ist

class RecipeDetails {
  final int id;
  final String title;
  final String? image; // Changed from imageUrl to image based on JSON
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

  // NEU: Direkte Makro-Felder, basierend auf der aktuellen API-Antwort
  final double? calories;
  final double? protein;
  final double? fat;
  final double? carbs;
  final double? sugar;

  // Behalten wir das `nutrition` Objekt, falls andere Endpunkte es noch senden
  // oder für detailliertere Nährwerte, die nicht direkt oben liegen.
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
    this.calories, // Hinzugefügt
    this.protein, // Hinzugefügt
    this.fat, // Hinzugefügt
    this.carbs, // Hinzugefügt
    this.sugar, // Hinzugefügt
    this.nutrition,
  });

  factory RecipeDetails.fromJson(Map<String, dynamic> json) {
    // Helper for parsing simple list of strings
    List<String>? parseStringList(dynamic jsonList) {
      if (jsonList is List) {
        return jsonList.map((item) => item.toString()).toList();
      }
      return null;
    }

    // Helper for parsing list of ExtendedIngredient
    List<ExtendedIngredient>? parseExtendedIngredients(dynamic jsonList) {
      if (jsonList is List) {
        return jsonList
            .whereType<Map<String, dynamic>>() // Only take valid maps
            .map(ExtendedIngredient.fromJson)
            .toList();
      }
      return null;
    }

    // Helper for parsing list of AnalyzedInstructionSet
    List<AnalyzedInstructionSet>? parseAnalyzedInstructionSets(dynamic jsonList) {
      if (jsonList is List) {
        return jsonList
            .whereType<Map<String, dynamic>>() // Only take valid maps
            .map(AnalyzedInstructionSet.fromJson)
            .toList();
      }
      return null;
    }

    Nutrition? parsedNutrition;
    // Attempt to parse 'nutrition' field if it exists and is a Map
    if (json['nutrition'] is Map<String, dynamic>) {
      try {
        parsedNutrition = Nutrition.fromJson(json['nutrition'] as Map<String, dynamic>);
      } catch (e, st) {
        // Log the error if parsing detailed nutrition fails, but don't rethrow
        // as the main macros are now directly on RecipeDetails.
        debugPrint('Error parsing detailed Nutrition object: $e\nStack: $st. Raw JSON for nutrition: ${json['nutrition']}');
      }
    }

    // Clean up summary HTML
    final String? rawSummary = json['summary'] as String?;
    final String? cleanSummary = rawSummary != null
        ? HtmlUnescape().convert(rawSummary.replaceAll(RegExp(r'<[^>]*>'), ''))
        : null;

    try {
      return RecipeDetails(
        id: json['id'] as int,
        title: json['title'] as String,
        image: json['image'] as String?, // Use 'image' as per JSON
        imageType: json['imageType'] as String?,
        servings: json['servings'] as int?,
        readyInMinutes: json['readyInMinutes'] as int?,
        sourceUrl: json['sourceUrl'] as String?,
        sourceName: json['sourceName'] as String?,
        summary: cleanSummary,
        aggregateLikes: json['aggregateLikes'] as int?,
        healthScore: (json['healthScore'] as num?)?.toDouble(),
        pricePerServing: (json['pricePerServing'] as num?)?.toDouble(),

        dishTypes: parseStringList(json['dishTypes']),
        diets: parseStringList(json['diets']),
        intolerances: parseStringList(json['intolerances']), // Will be null if not present

        extendedIngredients: parseExtendedIngredients(json['extendedIngredients']),
        analyzedInstructions: parseAnalyzedInstructionSets(json['analyzedInstructions']),

        // Direct parsing of primary macros from the top level
        calories: (json['calories'] as num?)?.toDouble(),
        protein: (json['protein'] as num?)?.toDouble(),
        fat: (json['fat'] as num?)?.toDouble(),
        carbs: (json['carbs'] as num?)?.toDouble(),
        sugar: (json['sugar'] as num?)?.toDouble(),

        nutrition: parsedNutrition, // Assign the (potentially null) parsed Nutrition object
      );
    } catch (e, st) {
      debugPrint('ERROR: Failed to create RecipeDetails instance from JSON: $e\nStack: $st');
      debugPrint('Problematic JSON (truncated): ${json.toString().substring(0, json.toString().length > 500 ? 500 : json.toString().length)}...');
      rethrow; // Rethrow to propagate parsing errors
    }
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
    );
  }

  @override
  String toString() {
    // For `toString`, use the direct macro fields first, fallback to Nutrition object if needed.
    // This makes the toString more robust to the JSON structure variations.
    final double? currentCalories = calories ?? nutrition?.nutrients.firstWhere(
      (n) => n.name == 'Calories',
      orElse: () => const Nutrient(name: '', amount: 0, unit: '', percentOfDailyNeeds: 0),
    )?.amount;

    return 'RecipeDetails(id: $id, title: $title, readyInMinutes: $readyInMinutes, '
        'ingredients: ${extendedIngredients?.length ?? 0}, '
        'calories: ${currentCalories?.toStringAsFixed(0) ?? 'N/A'} kcal)';
  }
}

/// --- ExtendedIngredient Model ---
class ExtendedIngredient {
  final int id;
  final String? aisle;
  final String? image;
  final String? consistency;
  final String name;
  final String original;
  final String? originalName;
  final double? amount;
  final String? unit;
  final List<String>? meta;
  final Measures? measures;

  const ExtendedIngredient({
    required this.id,
    this.aisle,
    this.image,
    this.consistency,
    required this.name,
    required this.original,
    this.originalName,
    this.amount,
    this.unit,
    this.meta,
    this.measures,
  });

  factory ExtendedIngredient.fromJson(Map<String, dynamic> json) {
    try {
      return ExtendedIngredient(
        id: json['id'] as int,
        aisle: json['aisle'] as String?,
        image: json['image'] as String?,
        consistency: json['consistency'] as String?,
        name: json['name'] as String? ?? '',
        original: json['original'] as String? ?? '',
        originalName: json['originalName'] as String?,
        amount: (json['amount'] as num?)?.toDouble(),
        unit: json['unit'] as String?,
        meta: (json['meta'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
        measures: json['measures'] is Map<String, dynamic>
            ? Measures.fromJson(json['measures'] as Map<String, dynamic>)
            : null,
      );
    } catch (e, st) {
      debugPrint('Error parsing ExtendedIngredient: $e\nStack: $st. Raw JSON: $json');
      rethrow;
    }
  }

  @override
  String toString() {
    return 'ExtendedIngredient(name: $name, amount: $amount ${unit ?? ''})';
  }
}

/// --- Measures Model ---
class Measures {
  final UnitMeasure? us;
  final UnitMeasure? metric;

  const Measures({
    this.us,
    this.metric,
  });

  factory Measures.fromJson(Map<String, dynamic> json) {
    try {
      return Measures(
        us: json['us'] is Map<String, dynamic>
            ? UnitMeasure.fromJson(json['us'] as Map<String, dynamic>)
            : null,
        metric: json['metric'] is Map<String, dynamic>
            ? UnitMeasure.fromJson(json['metric'] as Map<String, dynamic>)
            : null,
      );
    } catch (e, st) {
      debugPrint('Error parsing Measures: $e\nStack: $st. Raw JSON: $json');
      rethrow;
    }
  }
}

/// --- UnitMeasure Model ---
class UnitMeasure {
  final double? amount;
  final String? unitShort;
  final String? unitLong;

  const UnitMeasure({
    this.amount,
    this.unitShort,
    this.unitLong,
  });

  factory UnitMeasure.fromJson(Map<String, dynamic> json) {
    try {
      return UnitMeasure(
        amount: (json['amount'] as num?)?.toDouble(),
        unitShort: json['unitShort'] as String?,
        unitLong: json['unitLong'] as String?,
      );
    } catch (e, st) {
      debugPrint('Error parsing UnitMeasure: $e\nStack: $st. Raw JSON: $json');
      rethrow;
    }
  }
}

/// --- AnalyzedInstructionSet Model ---
class AnalyzedInstructionSet {
  final String? name;
  final List<InstructionStep> steps;

  const AnalyzedInstructionSet({
    this.name,
    required this.steps,
  });

  factory AnalyzedInstructionSet.fromJson(Map<String, dynamic> json) {
    List<InstructionStep> parseSteps(dynamic jsonList) {
      if (jsonList is List) {
        return jsonList
            .whereType<Map<String, dynamic>>() // Ensure items are maps
            .map(InstructionStep.fromJson)
            .toList();
      }
      return [];
    }

    try {
      return AnalyzedInstructionSet(
        name: json['name'] as String?,
        steps: parseSteps(json['steps']),
      );
    } catch (e, st) {
      debugPrint('Error parsing AnalyzedInstructionSet: $e\nStack: $st. Raw JSON: $json');
      rethrow;
    }
  }

  @override
  String toString() {
    return 'AnalyzedInstructionSet(name: $name, steps: ${steps.length})';
  }
}

/// --- InstructionStep Model ---
class InstructionStep {
  final int number;
  final String step; // Can contain HTML
  final List<String> ingredients; // Names of ingredients for this step
  final List<String> equipment; // Names of equipment for this step

  const InstructionStep({
    required this.number,
    required this.step,
    required this.ingredients,
    required this.equipment,
  });

  factory InstructionStep.fromJson(Map<String, dynamic> json) {
    // Helper to parse lists where items can be String or Map<String, dynamic> with 'name'
    List<String> parseNamedList(dynamic jsonList) {
      if (jsonList is List) {
        return jsonList.map((item) {
          if (item is String) {
            return item;
          } else if (item is Map<String, dynamic> && item.containsKey('name')) {
            return item['name'].toString();
          }
          return ''; // Return empty string for unparsable items
        }).where((item) => item.isNotEmpty).toList(); // Filter out empty strings
      }
      return [];
    }

    try {
      return InstructionStep(
        number: json['number'] as int,
        step: json['step'] as String? ?? '',
        ingredients: parseNamedList(json['ingredients']),
        equipment: parseNamedList(json['equipment']),
      );
    } catch (e, st) {
      debugPrint('Error parsing InstructionStep ${json['number']}: $e\nStack: $st. Raw JSON: $json');
      rethrow;
    }
  }

  @override
  String toString() {
    return 'InstructionStep(number: $number, step: $step)';
  }
}


/*
// --- MODELS TYPICALLY IN SEPARATE FILES ---

// lib/common/models/nutrition.dart
import 'package:flutter/foundation.dart'; // For debugPrint

class Nutrient {
  final String name;
  final double amount;
  final String unit;
  final double percentOfDailyNeeds;

  const Nutrient({
    required this.name,
    required this.amount,
    required this.unit,
    required this.percentOfDailyNeeds,
  });

  factory Nutrient.fromJson(Map<String, dynamic> json) {
    // debugPrint('Parsing Nutrient: ${json['name']}'); // Remove for cleaner console
    try {
      return Nutrient(
        name: json['name'] as String,
        amount: (json['amount'] as num).toDouble(),
        unit: json['unit'] as String,
        percentOfDailyNeeds: (json['percentOfDailyNeeds'] as num).toDouble(),
      );
    } catch (e, st) {
      debugPrint('Error parsing Nutrient ${json['name']}: $e\nStack: $st. Raw JSON for Nutrient: $json');
      rethrow;
    }
  }
}

class Nutrition {
  final List<Nutrient> nutrients;
  // Potentially add 'properties', 'flavonoids', 'ingredients', 'caloricBreakdown', 'weightPerServing' here

  const Nutrition({
    required this.nutrients,
  });

  factory Nutrition.fromJson(Map<String, dynamic> json) {
    // debugPrint('Parsing Nutrition object.'); // Remove for cleaner console
    try {
      return Nutrition(
        nutrients: (json['nutrients'] as List<dynamic>?)
                ?.whereType<Map<String, dynamic>>() // Ensure items are maps
                .map(Nutrient.fromJson)
                .toList() ??
            [],
      );
    } catch (e, st) {
      debugPrint('Error parsing Nutrition object: $e\nStack: $st. Raw JSON: $json');
      rethrow;
    }
  }
}
*/