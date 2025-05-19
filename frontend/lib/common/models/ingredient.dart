class Ingredient {
  final String id;           // z.B. eindeutiger Name oder ID
  final String name;         // z.B. "Tomate"
  final String? imageUrl;    // URL für Bild (kann leer sein)

  Ingredient({
    required this.id,
    required this.name,
    this.imageUrl,
  });
}
