// lib/features/recipe/domain/entities/recipe.dart
import 'package:equatable/equatable.dart';

class Recipe extends Equatable {
  final String? id;
  final int? spoonacularId;
  final String title;
  final String? imageUrl; // <-- Hier ist es schon nullable!
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

  const Recipe({
    this.id,
    this.spoonacularId,
    required this.title,
    this.imageUrl, // <-- Hier ist es auch nullable im Constructor
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