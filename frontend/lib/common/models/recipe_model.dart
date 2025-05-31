// lib/common/models/recipe_model.dart
import 'package:frontend/common/models/recipe.dart';

class RecipeModel {
  final int id;
  final String name; // <--- Keep 'name' as non-nullable String
  final String? imageUrl;
  final String? place;
  final int? readyInMinutes;
  final int? servings;

  RecipeModel({
    required this.id,
    required this.name,
    this.imageUrl,
    this.place,
    this.readyInMinutes,
    this.servings,
  });

  factory RecipeModel.fromJson(Map<String, dynamic> json) {
    return RecipeModel(
      id: json['id'] as int,
      // HIER IST DIE WICHTIGE ÄNDERUNG: json['name'] statt json['title']
      name: (json['name'] as String?) ?? 'Unnamed Recipe', // <-- liest jetzt den 'name'-Key
      imageUrl: json['imageUrl'] as String?, // <-- Auch hier json['imageUrl'] statt json['image']
      // Da place, readyInMinutes, servings im Backend undefined waren,
      // sind sie hier null. Wir behandeln sie als nullable String/int.
      place: json['place'] as String?, // <-- Liest den 'place'-Key
      readyInMinutes: json['readyInMinutes'] as int?, // <-- Liest den 'readyInMinutes'-Key
      servings: json['servings'] as int?, // <-- Liest den 'servings'-Key
    );
  }

  Recipe toEntity() {
    return Recipe(
      id: id,
      name: name,
      imageUrl: imageUrl ?? '', // Füge hier einen Fallback hinzu, falls imageUrl null ist
      place: place ?? '', // Füge hier einen Fallback hinzu, falls place null ist
      readyInMinutes: readyInMinutes,
      servings: servings,
    );
  }
}