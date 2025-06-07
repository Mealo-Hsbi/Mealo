// lib/common/models/nutrition.dart

class Nutrient {
  final String name;
  final double amount;
  final String unit;
  final double percentOfDailyNeeds;

  const Nutrient({
    required this.name,
    required this.amount,
    required this.unit,
    required this.percentOfDailyNeeds,
  });

  factory Nutrient.fromJson(Map<String, dynamic> json) {
    return Nutrient(
      name: json['name'] as String,
      amount: (json['amount'] as num).toDouble(),
      unit: json['unit'] as String,
      percentOfDailyNeeds: (json['percentOfDailyNeeds'] as num).toDouble(),
    );
  }
}

class Nutrition {
  final List<Nutrient> nutrients;
  // Hier könnten auch 'properties', 'flavonoids', 'ingredients', 'caloricBreakdown', 'weightPerServing' hinzugefügt werden,
  // aber für den Anfang konzentrieren wir uns auf die nötigen.

  const Nutrition({
    required this.nutrients,
  });

  factory Nutrition.fromJson(Map<String, dynamic> json) {
    return Nutrition(
      nutrients: (json['nutrients'] as List<dynamic>?)
              ?.where((item) => item is Map<String, dynamic>)
              .map((item) => Nutrient.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}