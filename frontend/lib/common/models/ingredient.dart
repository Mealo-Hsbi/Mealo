class Ingredient {
  final String id;        // z.B. eindeutiger Name oder ID (String)
  final String name;      // z.B. "Tomate"
  final String? imageUrl;  // URL für Bild (kann leer sein)
  final List<String>? aliases;

  // Zusätzliche Felder für die Rezepterstellung
  final String? category;
  final int? shelfLifeDays;
  final int? calories;
  final double? proteinGram;
  final double? carbsGram;
  final double? fatGram;

  final double? amount;    // Menge (z.B. 2.0)
  final String? unit;      // Einheit (z.B. "g", "ml", "Stück")
  final String? original;  // Originaltext (z.B. "2 red onions, chopped")

  Ingredient({
    required this.id,
    required this.name,
    this.imageUrl,
    this.aliases,
    this.category,
    this.shelfLifeDays,
    this.calories,
    this.proteinGram,
    this.carbsGram,
    this.fatGram,
    this.amount,
    this.unit,
    this.original,
  });

  // Factory-Methode zum Erstellen einer Ingredient aus einem JSON-Map
  factory Ingredient.fromJson(Map<String, dynamic> json) {
    return Ingredient(
      id: (json['id'] as dynamic)?.toString() ?? json['name'] as String, // ID kann int oder String sein, immer zu String konvertieren. Fallback auf name.
      name: json['name'] as String,
      imageUrl: json['image'] as String?, // Spoonacular verwendet 'image' für die URL
      aliases: (json['aliases'] as List?)?.map((e) => e as String).toList(),
      category: json['category'] as String?,
      shelfLifeDays: json['shelf_life_days'] as int?,
      calories: json['calories'] as int?,
      proteinGram: (json['protein_gram'] as num?)?.toDouble(),
      carbsGram: (json['carbs_gram'] as num?)?.toDouble(),
      fatGram: (json['fat_gram'] as num?)?.toDouble(),
      amount: _parseAmount(json['amount']),
      unit: json['unit'] as String?,
      original: json['original'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image': imageUrl,
      'aliases': aliases,
      'category': category,
      'shelf_life_days': shelfLifeDays,
      'calories': calories,
      'protein_gram': proteinGram,
      'carbs_gram': carbsGram,
      'fat_gram': fatGram,
      'amount': amount,
      'unit': unit,
      'original': original,
    };
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

  Ingredient copyWith({
    String? id,
    String? name,
    String? imageUrl,
    List<String>? aliases,
    String? category,
    int? shelfLifeDays,
    int? calories,
    double? proteinGram,
    double? carbsGram,
    double? fatGram,
    double? amount,
    String? unit,
    String? original,
  }) {
    return Ingredient(
      id: id ?? this.id,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      aliases: aliases ?? this.aliases,
      category: category ?? this.category,
      shelfLifeDays: shelfLifeDays ?? this.shelfLifeDays,
      calories: calories ?? this.calories,
      proteinGram: proteinGram ?? this.proteinGram,
      carbsGram: carbsGram ?? this.carbsGram,
      fatGram: fatGram ?? this.fatGram,
      amount: amount ?? this.amount,
      unit: unit ?? this.unit,
      original: original ?? this.original,
    );
  }

  // Hilfsmethode zum Parsen von amount (kann String oder num sein)
  static double? _parseAmount(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) {
      try {
        return double.parse(value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }
}