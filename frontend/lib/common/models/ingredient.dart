class Ingredient {
  final String id;           // z.B. eindeutiger Name oder ID
  final String name;         // z.B. "Tomate"
  final String? imageUrl;    // URL für Bild (kann leer sein)
  final List<String>? aliases;

  Ingredient({
    required this.id,
    required this.name,
    this.imageUrl,
    this.aliases,
  });

  @override
  String toString() {
    return 'Ingredient(id: $id, name: $name, imageUrl: $imageUrl, aliases: $aliases)';
  }
}
