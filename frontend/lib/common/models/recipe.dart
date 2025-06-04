class Recipe {
  final int id; // Eindeutige ID von Spoonacular (wichtig!)
  final String name; // Wird von 'title' aus Spoonacular befüllt
  final String? place; // Immer 'Spoonacular' in diesem Kontext (oder von sourceName)
  final String imageUrl; // Bild-URL von Spoonacular

  // Bestehende optionale Felder von Spoonacular
  final int? servings; // Anzahl der Portionen
  final int? readyInMinutes; // Zubereitungszeit in Minuten
  final String? imageType; // Z.B. 'jpg', 'png'

  // NEUE, optionale Felder für Nährwerte und Zutaten-Zähler
  final int? calories; // Kalorien (von Spoonacular nutrition)
  final double? protein; // Protein in Gramm (von Spoonacular nutrition)
  final double? fat;     // Fett in Gramm (von Spoonacular nutrition)
  final double? carbs;   // Kohlenhydrate in Gramm (von Spoonacular nutrition)
  final double? sugar;   // Zucker in Gramm (von Spoonacular nutrition)
  final int? healthScore; // Healthiness Score (von Spoonacular)
  
  // Diese kommen vom Backend, nicht direkt von Spoonacular
  final int? matchingIngredientsCount; // Anzahl passender Zutaten
  final int? missingIngredientsCount;  // Anzahl fehlender Zutaten

  const Recipe({
    required this.id, // ID ist wichtig und sollte required sein
    required this.name,
    this.place,
    required this.imageUrl,
    this.servings,
    this.readyInMinutes,
    this.imageType,
    this.calories, // NEU
    this.protein,  // NEU
    this.fat,      // NEU
    this.carbs,    // NEU
    this.sugar,    // NEU
    this.healthScore, // NEU
    this.matchingIngredientsCount, // NEU
    this.missingIngredientsCount,  // NEU
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {

    double? _findNutrientValue(List<dynamic>? nutrients, String title) {
      if (nutrients == null) return null;
      final nutrient = nutrients.firstWhere(
        (n) => n['title'] == title,
        orElse: () => null,
      );
      return (nutrient != null) ? (nutrient['amount'] as num?)?.toDouble() : null;
    }

    final List<dynamic>? nutrients = json['nutrition']?['nutrients'];

    return Recipe(
      id: json['id'] as int,
      name: (json['title'] as String?) ?? 'Unnamed Recipe', // Spoonacular verwendet 'title'
      imageUrl: json['image'] as String, // Spoonacular verwendet 'image'
      place: json['sourceName'] as String?, // Spoonacular verwendet 'sourceName'
      readyInMinutes: json['readyInMinutes'] as int?,
      servings: json['servings'] as int?,
      
      // Mapping der neuen Felder von Spoonaculars Antwort
      calories: _findNutrientValue(nutrients, 'Calories')?.toInt(), // Spoonacular liefert oft double, hier zu int konvertieren
      protein: _findNutrientValue(nutrients, 'Protein'),
      fat: _findNutrientValue(nutrients, 'Fat'),
      carbs: _findNutrientValue(nutrients, 'Carbohydrates'), // Achtung: Spoonacular nennt es 'Carbohydrates'
      sugar: _findNutrientValue(nutrients, 'Sugar'),
      healthScore: json['healthScore'] as int?, // Direktes Feld von Spoonacular
      
      // Diese Felder kommen vom Backend, NICHT direkt von Spoonacular.
      // Dein Backend muss sie berechnen und zum JSON hinzufügen.
      matchingIngredientsCount: json['matchingIngredientsCount'] as int?,
      missingIngredientsCount: json['missingIngredientsCount'] as int?,
    );
  }

  // Optional: Eine toString-Methode für besseres Debugging
  @override
  String toString() {
    return 'Recipe(id: $id, name: $name, readyInMinutes: $readyInMinutes, calories: $calories)';
  }

  // Optional: Equals und hashCode für bessere Listenvergleiche, falls benötigt
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Recipe &&
          runtimeType == other.runtimeType &&
          id == other.id; // Vergleich basiert auf der ID

  @override
  int get hashCode => id.hashCode;
}