// lib/common/models/recipe_details.dart
import 'package:frontend/common/models/recipe.dart'; // Importiere dein Basis-Recipe-Model

class RecipeDetails {
  final int id;
  final String title;
  final String? image;
  final String? imageType;
  final int? servings;
  final int? readyInMinutes;
  final String? sourceUrl; // URL zum Originalrezept
  final String? summary; // Kurze Zusammenfassung
  final String? instructions; // Schritt-für-Schritt-Anleitung
  final int? aggregateLikes; // Anzahl der Likes
  final double? healthScore; // Gesundheits-Score
  final double? pricePerServing; // Preis pro Portion in Cent
  final List<String>? dishTypes; // Z.B. "main course", "dessert"
  final List<String>? diets; // Z.B. "vegetarian", "gluten free"
  final List<String>? intolerances; // Z.B. "gluten", "dairy"
  final List<ExtendedIngredient>? extendedIngredients; // Detaillierte Zutatenliste

  // Optional: Für Nährwertangaben, wenn includeNutrition=true im Backend gesetzt ist
  // final Map<String, dynamic>? nutrition; // Dies könnte ein eigenes Model werden, wenn komplex

  const RecipeDetails({
    required this.id,
    required this.title,
    this.image,
    this.imageType,
    this.servings,
    this.readyInMinutes,
    this.sourceUrl,
    this.summary,
    this.instructions,
    this.aggregateLikes,
    this.healthScore,
    this.pricePerServing,
    this.dishTypes,
    this.diets,
    this.intolerances,
    this.extendedIngredients,
    // this.nutrition,
  });

  factory RecipeDetails.fromJson(Map<String, dynamic> json) {
    // Hilfsfunktion zum Parsen von Listen von Strings
    List<String>? parseStringList(dynamic jsonList) {
      if (jsonList is List) {
        return jsonList.map((item) => item.toString()).toList();
      }
      return null;
    }

    // Hilfsfunktion zum Parsen von extendedIngredients
    List<ExtendedIngredient>? parseExtendedIngredients(dynamic jsonList) {
      if (jsonList is List) {
        return jsonList.map((item) => ExtendedIngredient.fromJson(item)).toList();
      }
      return null;
    }

    return RecipeDetails(
      id: json['id'] as int,
      title: json['title'] as String,
      image: json['image'] as String?,
      imageType: json['imageType'] as String?,
      servings: json['servings'] as int?,
      readyInMinutes: json['readyInMinutes'] as int?,
      sourceUrl: json['sourceUrl'] as String?,
      summary: json['summary'] as String?,
      instructions: json['instructions'] as String?,
      aggregateLikes: json['aggregateLikes'] as int?,
      healthScore: (json['healthScore'] as num?)?.toDouble(), // num zu double casten
      pricePerServing: (json['pricePerServing'] as num?)?.toDouble(),
      dishTypes: parseStringList(json['dishTypes']),
      diets: parseStringList(json['diets']),
      intolerances: parseStringList(json['intolerances']),
      extendedIngredients: parseExtendedIngredients(json['extendedIngredients']),
      // nutrition: json['nutrition'] as Map<String, dynamic>?, // Wenn du das unparsed speichern möchtest
    );
  }

  // Optional: Kopierfunktion, nützlich für immutable Objekte
  RecipeDetails copyWith({
    int? id,
    String? title,
    String? image,
    String? imageType,
    int? servings,
    int? readyInMinutes,
    String? sourceUrl,
    String? summary,
    String? instructions,
    int? aggregateLikes,
    double? healthScore,
    double? pricePerServing,
    List<String>? dishTypes,
    List<String>? diets,
    List<String>? intolerances,
    List<ExtendedIngredient>? extendedIngredients,
    // Map<String, dynamic>? nutrition,
  }) {
    return RecipeDetails(
      id: id ?? this.id,
      title: title ?? this.title,
      image: image ?? this.image,
      imageType: imageType ?? this.imageType,
      servings: servings ?? this.servings,
      readyInMinutes: readyInMinutes ?? this.readyInMinutes,
      sourceUrl: sourceUrl ?? this.sourceUrl,
      summary: summary ?? this.summary,
      instructions: instructions ?? this.instructions,
      aggregateLikes: aggregateLikes ?? this.aggregateLikes,
      healthScore: healthScore ?? this.healthScore,
      pricePerServing: pricePerServing ?? this.pricePerServing,
      dishTypes: dishTypes ?? this.dishTypes,
      diets: diets ?? this.diets,
      intolerances: intolerances ?? this.intolerances,
      extendedIngredients: extendedIngredients ?? this.extendedIngredients,
      // nutrition: nutrition ?? this.nutrition,
    );
  }

  @override
  String toString() {
    return 'RecipeDetails(id: $id, title: $title, readyInMinutes: $readyInMinutes, ingredients: ${extendedIngredients?.length})';
  }
}

// Dies ist ein separates Modell für die detaillierten Zutaten,
// da Spoonacular hier viele Informationen liefert (Menge, Einheit, Name etc.).
class ExtendedIngredient {
  final int id;
  final String aisle; // Z.B. "produce", "spices"
  final String image; // Bild der Zutat
  final String consistency; // Z.B. "solid", "liquid"
  final String name; // Zutatennamen
  final String original; // Originaltext der Zutat
  final String originalName; // Originaler Zutatenname
  final double amount; // Menge
  final String unit; // Einheit (z.B. "g", "cup")
  final List<String> meta; // Zusätzliche Beschreibungen (z.B. "chopped", "fresh")

  const ExtendedIngredient({
    required this.id,
    required this.aisle,
    required this.image,
    required this.consistency,
    required this.name,
    required this.original,
    required this.originalName,
    required this.amount,
    required this.unit,
    required this.meta,
  });

  factory ExtendedIngredient.fromJson(Map<String, dynamic> json) {
    return ExtendedIngredient(
      id: json['id'] as int,
      aisle: json['aisle'] as String? ?? '',
      image: json['image'] as String? ?? '',
      consistency: json['consistency'] as String? ?? '',
      name: json['name'] as String? ?? '',
      original: json['original'] as String? ?? '',
      originalName: json['originalName'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0, // Wichtig: num zu double
      unit: json['unit'] as String? ?? '',
      meta: (json['meta'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    );
  }

  @override
  String toString() {
    return 'ExtendedIngredient(name: $name, amount: $amount ${unit.isEmpty ? '' : unit})';
  }
}