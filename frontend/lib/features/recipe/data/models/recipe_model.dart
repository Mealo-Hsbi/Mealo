// lib/features/recipe/data/models/recipe_model.dart (ADJUSTED)

import 'package:equatable/equatable.dart';
import 'package:frontend/features/recipe/domain/entities/recipe.dart'; // Unsere Domain-Entität

class RecipeModel extends Equatable {
  final String? id; // UUID des Rezepts in IHRER Datenbank
  final int? spoonacularId; // Spoonacular ID (optional)

  final String title;
  final String? imageUrl;
  final int? servings;
  final int? readyInMinutes;
  final String? summary;
  final double? healthScore;

  final List<String>? dishTypes;
  final List<String>? diets;
  final List<String>? intolerances;

  final bool? isVegan;
  final bool? isVegetarian;
  final bool? isGlutenFree;
  final bool? isDairyFree;

  const RecipeModel({
    this.id,
    this.spoonacularId,
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

  // Factory-Methode zum Erstellen eines RecipeModel aus JSON (von Ihrem Backend)
  factory RecipeModel.fromJson(Map<String, dynamic> json) {
    // --- ADD DEBUG PRINT HERE TO SEE INCOMING JSON FOR RECIPEMODEL ---
    print('[RecipeModel.fromJson] Processing JSON: $json');

    return RecipeModel(
      id: json['id'] as String?, // This seems to be correct for your internal ID (UUID)
      spoonacularId: json['spoonacular_id'] as int?, // <-- Change to snake_case
      title: json['title'] as String, // This is already correct
      imageUrl: json['image_url'] as String?, // <-- Change to snake_case
      servings: json['servings'] as int?, // This is already correct
      readyInMinutes: json['ready_in_minutes'] as int?, // <-- Change to snake_case
      summary: json['summary'] as String?, // This is already correct
      healthScore: (json['health_score'] as num?)?.toDouble(), // <-- Change to snake_case
      
      // For lists, ensure the parsing is robust for nulls
      dishTypes: (json['dish_types'] as List<dynamic>?)?.map((e) => e as String).toList(), // <-- Change to snake_case
      diets: (json['diets'] as List<dynamic>?)?.map((e) => e as String).toList(), // <-- Change to snake_case
      intolerances: (json['intolerances'] as List<dynamic>?)?.map((e) => e as String).toList(), // <-- Change to snake_case

      isVegan: json['vegan'] as bool?, // <-- Change to snake_case
      isVegetarian: json['vegetarian'] as bool?, // <-- Change to snake_case
      isGlutenFree: json['gluten_free'] as bool?, // <-- Change to snake_case
      isDairyFree: json['dairy_free'] as bool?, // <-- Change to snake_case
    );
  }

  // Rest of the class (toEntity, fromEntity, toJson, props) remains the same
  // as it's already using the camelCase properties of the Dart class.

  Recipe toEntity() {
    return Recipe(
      id: id,
      spoonacularId: spoonacularId,
      title: title,
      imageUrl: imageUrl,
      servings: servings,
      readyInMinutes: readyInMinutes,
      summary: summary,
      healthScore: healthScore,
      dishTypes: dishTypes,
      diets: diets,
      intolerances: intolerances,
      isVegan: isVegan,
      isVegetarian: isVegetarian,
      isGlutenFree: isGlutenFree,
      isDairyFree: isDairyFree,
    );
  }

  factory RecipeModel.fromEntity(Recipe entity) {
    return RecipeModel(
      id: entity.id,
      spoonacularId: entity.spoonacularId,
      title: entity.title,
      imageUrl: entity.imageUrl,
      servings: entity.servings,
      readyInMinutes: entity.readyInMinutes,
      summary: entity.summary,
      healthScore: entity.healthScore,
      dishTypes: entity.dishTypes,
      diets: entity.diets,
      intolerances: entity.intolerances,
      isVegan: entity.isVegan,
      isVegetarian: entity.isVegetarian,
      isGlutenFree: entity.isGlutenFree,
      isDairyFree: entity.isDairyFree,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'spoonacularId': spoonacularId, // Keep camelCase for toJson if that's what backend expects for sending
      'title': title,
      'imageUrl': imageUrl,
      'servings': servings,
      'readyInMinutes': readyInMinutes,
      'summary': summary,
      'healthScore': healthScore,
      'dishTypes': dishTypes,
      'diets': diets,
      'intolerances': intolerances,
      'isVegan': isVegan,
      'isVegetarian': isVegetarian,
      'isGlutenFree': isGlutenFree,
      'isDairyFree': isDairyFree,
    };
  }

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