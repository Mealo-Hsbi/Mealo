// lib/features/recipe/data/models/recipe_model.dart
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
    return RecipeModel(
      id: json['id'] as String?, // Kann null sein, wenn neu erstellt
      spoonacularId: json['spoonacularId'] as int?,
      title: json['title'] as String,
      imageUrl: json['imageUrl'] as String?,
      servings: json['servings'] as int?,
      readyInMinutes: json['readyInMinutes'] as int?,
      summary: json['summary'] as String?,
      healthScore: (json['healthScore'] as num?)?.toDouble(),
      dishTypes: (json['dishTypes'] as List<dynamic>?)?.map((e) => e as String).toList(),
      diets: (json['diets'] as List<dynamic>?)?.map((e) => e as String).toList(),
      intolerances: (json['intolerances'] as List<dynamic>?)?.map((e) => e as String).toList(),
      isVegan: json['isVegan'] as bool?,
      isVegetarian: json['isVegetarian'] as bool?,
      isGlutenFree: json['isGlutenFree'] as bool?,
      isDairyFree: json['isDairyFree'] as bool?,
    );
  }

  // Methode zur Umwandlung des RecipeModel in die Recipe Domain-Entität
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

  // Factory-Methode zur Umwandlung der Recipe Domain-Entität in ein RecipeModel
  // Nützlich, wenn Sie ein Recipe an Ihr Backend senden müssen (z.B. beim Hinzufügen als Favorit)
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

  // Methode, um dieses Modell in ein JSON-Objekt für den Backend-Aufruf umzuwandeln
  // Wichtig, wenn Sie Rezepte an Ihr Backend senden (z.B. für eigene Rezepte oder als Teil eines Favoriten)
  Map<String, dynamic> toJson() {
    return {
      'id': id, // Wird vom Backend generiert, wenn es ein neues Rezept ist
      'spoonacularId': spoonacularId,
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