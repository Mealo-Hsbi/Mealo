// lib/features/recipeList/domain/entities/recipe.dart

import 'dart:convert';

/// Diese Klasse stellt exakt die Felder bereit, 
/// die in deinem UI-Code (z.B. parallax_recipes.dart) erwartet werden:
///  • name          (String, non-nullable)
///  • place         (String, non-nullable)
///  • imageUrl      (String, non-nullable)
/// 
/// Zusätzlich beinhaltet sie alle Felder, die dein Prisma-Schema enthält,
/// damit du später auch auf ID, servings, readyInMinutes, summary etc. zugreifen kannst.

class Recipe {
  /// UUID aus der Datenbank (prisma: id @db.Uuid)
  final String id;

  /// Der Nutzer, der das Rezept angelegt hat (nullable)
  final String? createdById;

  /// Falls von Spoonacular importiert: die dortige numeric-ID (nullable)
  final int? spoonacularId;

  /// Der Titel / Name des Rezepts (wird intern aus "title" gemappt).
  final String name;

  /// In deinem alten Code wurde "place" erwartet. 
  /// Wir mappen es hier auf json['source'] oder default "Spoonacular".
  final String place;

  /// URL zum Bild. In deinem ursprünglichen Modell war imageUrl non-nullable.
  final String imageUrl;

  /// Portionen (z. B. 4) – nullable
  final int? servings;

  /// Zubereitungszeit in Minuten – nullable
  final int? readyInMinutes;

  /// Kochzeit in Minuten – nullable
  final int? cookingMinutes;

  /// Vorbereitung in Minuten – nullable
  final int? preparationMinutes;

  /// DishTypes als Liste von Strings (z. B. ["dinner","italian"]) – nullable
  final List<String>? dishTypes;

  /// Zusammenfassung (Beschreibung) – nullable
  final String? summary;

  /// Kochanleitung / Schritte – nullable
  final String? instructions;

  /// Health Score (float) – nullable
  final double? healthScore;

  /// Spoonacular Score (float) – nullable
  final double? spoonacularScore;

  /// Preis pro Portion (float) – nullable
  final double? pricePerServing;

  /// Vegan/Vegetarisch/GlutenFree/DairyFree (default false, non-nullable)
  final bool vegan;
  final bool vegetarian;
  final bool glutenFree;
  final bool dairyFree;

  /// Weight Watcher Punkte – nullable
  final int? weightWatcherPoints;

  /// Wann das Rezept angelegt wurde – non-nullable
  final DateTime createdAt;

  const Recipe({
    required this.id,
    this.createdById,
    this.spoonacularId,
    required this.name,
    required this.place,
    required this.imageUrl,
    this.servings,
    this.readyInMinutes,
    this.cookingMinutes,
    this.preparationMinutes,
    this.dishTypes,
    this.summary,
    this.instructions,
    this.healthScore,
    this.spoonacularScore,
    this.pricePerServing,
    required this.vegan,
    required this.vegetarian,
    required this.glutenFree,
    required this.dairyFree,
    this.weightWatcherPoints,
    required this.createdAt,
  });

  /// Factory-Methode, um ein Recipe aus einem JSON-Map zu erzeugen.
  /// Wichtig: Wir mappen hier:
  ///  • json['title'] → name
  ///  • json['image_url'] → imageUrl
  ///  • json['source'] (falls vorhanden) → place, ansonsten Default "Spoonacular"
  ///  • Alle anderen Felder analog zu deinem Prisma-Schema
  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['id'] as String,
      createdById: json['created_by_id'] as String?,
      spoonacularId: json['spoonacular_id'] != null
          ? (json['spoonacular_id'] as num).toInt()
          : null,
      // "name" kommt aus "title" in deinem Prisma-Schema
      name: (json['title'] as String?)?.trim() ?? 'Unknown Recipe',
      // "place" war in deinem alten Modell fest auf "Spoonacular" gesetzt,
      // falls du später eine JSON-Eigenschaft "source" lieferst, wird diese genommen.
      place: (json['source'] as String?)?.trim() ?? 'Spoonacular',
      // Mache imageUrl non-nullable, falls null -> leerer String
      imageUrl: (json['image_url'] as String?) ?? '',
      servings: json['servings'] != null ? (json['servings'] as num).toInt() : null,
      readyInMinutes:
          json['ready_in_minutes'] != null ? (json['ready_in_minutes'] as num).toInt() : null,
      cookingMinutes:
          json['cooking_minutes'] != null ? (json['cooking_minutes'] as num).toInt() : null,
      preparationMinutes: json['preparation_minutes'] != null
          ? (json['preparation_minutes'] as num).toInt()
          : null,
      dishTypes: json['dish_types'] != null
          ? List<String>.from(json['dish_types'] as List<dynamic>)
          : null,
      summary: json['summary'] as String?,
      instructions: json['instructions'] as String?,
      healthScore: json['health_score'] != null
          ? (json['health_score'] as num).toDouble()
          : null,
      spoonacularScore: json['spoonacular_score'] != null
          ? (json['spoonacular_score'] as num).toDouble()
          : null,
      pricePerServing: json['price_per_serving'] != null
          ? (json['price_per_serving'] as num).toDouble()
          : null,
      vegan: json['vegan'] as bool? ?? false,
      vegetarian: json['vegetarian'] as bool? ?? false,
      glutenFree: json['gluten_free'] as bool? ?? false,
      dairyFree: json['dairy_free'] as bool? ?? false,
      weightWatcherPoints: json['weight_watcher_points'] != null
          ? (json['weight_watcher_points'] as num).toInt()
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  /// Falls du irgendwo ein Recipe als JSON an deinen Server zurückschicken willst:
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_by_id': createdById,
      'spoonacular_id': spoonacularId,
      'title': name,
      'source': place,
      'image_url': imageUrl,
      'servings': servings,
      'ready_in_minutes': readyInMinutes,
      'cooking_minutes': cookingMinutes,
      'preparation_minutes': preparationMinutes,
      'dish_types': dishTypes,
      'summary': summary,
      'instructions': instructions,
      'health_score': healthScore,
      'spoonacular_score': spoonacularScore,
      'price_per_serving': pricePerServing,
      'vegan': vegan,
      'vegetarian': vegetarian,
      'gluten_free': glutenFree,
      'dairy_free': dairyFree,
      'weight_watcher_points': weightWatcherPoints,
      'created_at': createdAt.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'Recipe(id: $id, name: $name)';
  }
}
