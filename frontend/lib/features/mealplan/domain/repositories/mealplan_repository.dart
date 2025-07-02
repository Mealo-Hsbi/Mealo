import 'package:frontend/common/models/mealplan.dart';

abstract class MealplanRepository {
  Future<Mealplan> getCurrentMealplan();
  Future<void> updateCurrentMealplan(Map<String, dynamic> payload);
} 