import '../repositories/mealplan_repository.dart';
import 'package:frontend/common/models/mealplan.dart';

class UpdateCurrentMealplan {
  final MealplanRepository repository;

  UpdateCurrentMealplan(this.repository);

  Future<void> call(Map<String, dynamic> payload) => repository.updateCurrentMealplan(payload);
} 