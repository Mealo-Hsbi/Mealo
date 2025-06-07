// lib/common/models/recipe.dart

import 'package:flutter/foundation.dart'; // Für debugPrint, falls du es weiter verwenden willst

class Recipe {
  final int id; // Eindeutige ID von Spoonacular (wichtig!)
  final String name; // Wird von 'title' aus Spoonacular befüllt (Backend sendet 'name')
  final String? place; // Von sourceName (Backend sendet 'place')
  final String imageUrl; // Bild-URL von Spoonacular (Backend sendet 'imageUrl')

  // Bestehende optionale Felder
  final int? servings; // Anzahl der Portionen
  final int? readyInMinutes; // Zubereitungszeit in Minuten

  // NEUE, optionale Felder für Nährwerte und Zutaten-Zähler
  // Wichtig: Datentypen auf double? lassen, da Kalorien etc. oft Dezimalwerte sind.
  final double? calories; // Kalorien (vom Backend, das sie von Spoonacular bekommt)
  final double? protein; // Protein in Gramm
  final double? fat;     // Fett in Gramm
  final double? carbs;   // Kohlenhydrate in Gramm
  final double? sugar;   // Zucker in Gramm
  final int? healthScore; // Healthiness Score (vom Backend, das ihn von Spoonacular bekommt)

  // Diese kommen vom Backend, nicht direkt von Spoonacular
  final int? matchingIngredientsCount; // Anzahl passender Zutaten
  final int? missingIngredientsCount;  // Anzahl fehlender Zutaten

  const Recipe({
    required this.id,
    required this.name,
    this.place,
    required this.imageUrl, // imageUrl sollte required sein, da Rezepte fast immer ein Bild haben
    this.servings,
    this.readyInMinutes,
    // imageType entfernen, da es im Backend nicht mehr gemappt wird und von hier nicht benötigt wird
    this.calories,
    this.protein,
    this.fat,
    this.carbs,
    this.sugar,
    this.healthScore,
    this.matchingIngredientsCount,
    this.missingIngredientsCount,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    // Wenn du debugPrints hier noch brauchst, lass sie drin.
    // debugPrint('--- Flutter Recipe.fromJson - Incoming JSON for Recipe ID ${json['id']}: ---');
    // debugPrint(json.toString());

    return Recipe(
      id: json['id'] as int,
      name: (json['name'] as String?) ?? 'Unnamed Recipe', // Backend sendet jetzt 'name'
      imageUrl: (json['imageUrl'] as String?) ?? '', // Backend sendet 'imageUrl', als String? falls null, dann ''
      place: json['place'] as String?, // Backend sendet 'place' (was sourceName war)
      readyInMinutes: json['readyInMinutes'] as int?,
      servings: json['servings'] as int?,
      // imageType wird nicht mehr gemappt, da es vom Backend nicht gesendet wird
      
      // Direkte Zuweisung der Nährwerte, wie sie vom Backend kommen
      // Hier ist es entscheidend, dass sie als num geparst und dann zu double konvertiert werden.
      calories: (json['calories'] as num?)?.toDouble(),
      protein: (json['protein'] as num?)?.toDouble(),
      fat: (json['fat'] as num?)?.toDouble(),
      carbs: (json['carbs'] as num?)?.toDouble(),
      sugar: (json['sugar'] as num?)?.toDouble(),
      healthScore: json['healthScore'] as int?,

      // Direkte Zuweisung der Zähler
      matchingIngredientsCount: json['matchingIngredientsCount'] as int?,
      missingIngredientsCount: json['missingIngredientsCount'] as int?,
    );
  }

  @override
  String toString() {
    return 'Recipe(id: $id, name: $name, readyInMinutes: $readyInMinutes, calories: $calories)';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Recipe &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}