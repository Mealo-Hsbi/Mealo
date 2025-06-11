// lib/common/models/ingredient.dart

class Ingredient {
  final String id;        // z.B. eindeutiger Name oder ID (String)
  final String name;      // z.B. "Tomate"
  final String? imageUrl;  // URL für Bild (kann leer sein)
  final List<String>? aliases;

  Ingredient({
    required this.id,
    required this.name,
    this.imageUrl,
    this.aliases,
  });

  // Factory-Methode zum Erstellen einer Ingredient aus einem JSON-Map
  factory Ingredient.fromJson(Map<String, dynamic> json) {
    return Ingredient(
      id: (json['id'] as dynamic)?.toString() ?? json['name'] as String, // ID kann int oder String sein, immer zu String konvertieren. Fallback auf name.
      name: json['name'] as String,
      imageUrl: json['image'] as String?, // Spoonacular verwendet 'image' für die URL
      aliases: (json['aliases'] as List?)?.map((e) => e as String).toList(),
    );
  }

  @override
  String toString() {
    return 'Ingredient(id: $id, name: $name, imageUrl: $imageUrl, aliases: $aliases)';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Ingredient &&
          runtimeType == other.runtimeType &&
          id == other.id; // Gleichheit basiert auf der ID

  @override
  int get hashCode => id.hashCode; // Hashcode basiert auf der ID
}