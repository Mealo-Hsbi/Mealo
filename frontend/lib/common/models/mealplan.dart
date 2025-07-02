import 'package:frontend/common/models/recipe_model.dart';
import 'package:intl/intl.dart';

class Mealplan {
  final String? id; // Backend UUID, kann null sein für neuen Plan
  final Map<String, Map<String, RecipeModel?>> days; // z.B. {'Mon': {'Breakfast': RecipeModel, ...}, ...}

  Mealplan({this.id, required this.days});

  factory Mealplan.empty() {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    const mealNames = ['Breakfast', 'Lunch', 'Dinner'];
    return Mealplan(
      days: {
        for (var i = 0; i < 7; i++)
          DateFormat('yyyy-MM-dd').format(monday.add(Duration(days: i))):
            {for (var meal in mealNames) meal: null},
      },
    );
  }

  factory Mealplan.fromJson(Map<String, dynamic> json) {
    final daysJson = json['days'] as Map<String, dynamic>? ?? {};
    print('[Mealplan.fromJson] Eingehendes JSON:');
    print(json);
    return Mealplan(
      id: json['id']?.toString(),
      days: daysJson.map((day, meals) => MapEntry(
        day,
        (meals as Map<String, dynamic>).map((meal, recipe) => MapEntry(
          meal,
          recipe != null ? RecipeModel.fromJson(recipe as Map<String, dynamic>) : null,
        )),
      )),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'days': days.map((day, meals) => MapEntry(
        day,
        meals.map((meal, recipe) => MapEntry(
          meal,
          recipe?.toJson(),
        )),
      )),
    };
  }
} 