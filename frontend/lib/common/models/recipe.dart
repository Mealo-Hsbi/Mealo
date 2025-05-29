class Recipe {
  final int id; // Eindeutige ID von Spoonacular (wichtig!)
  final String name; // Wird von 'title' aus Spoonacular befüllt
  final String place; // Immer 'Spoonacular' in diesem Kontext
  final String imageUrl; // Bild-URL von Spoonacular

  // Neue, optionale Felder von Spoonacular
  final int? servings; // Anzahl der Portionen
  final int? readyInMinutes; // Zubereitungszeit in Minuten
  final String? imageType; // Z.B. 'jpg', 'png'

  const Recipe({
    required this.id, // ID ist wichtig und sollte required sein
    required this.name,
    required this.place,
    required this.imageUrl,
    this.servings,
    this.readyInMinutes,
    this.imageType,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['id'] as int, // Spoonacular liefert eine int id
      name: json['title'] as String? ?? 'Unknown Recipe', // 'title' ist das Rezeptname
      place: 'Spoonacular', // Dieser Wert bleibt konstant für Spoonacular-Rezepte
      imageUrl: json['image'] as String? ?? '', // 'image' ist die URL
      servings: json['servings'] as int?,
      readyInMinutes: json['readyInMinutes'] as int?,
      imageType: json['imageType'] as String?,
    );
  }

  // Optional: Eine toString-Methode für besseres Debugging
  @override
  String toString() {
    return 'Recipe(id: $id, name: $name, servings: $servings, readyInMinutes: $readyInMinutes)';
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