import '../repositories/mealplan_repository.dart';
import 'package:frontend/common/models/mealplan.dart';

class GetCurrentMealplan {
  final MealplanRepository repository;

  GetCurrentMealplan(this.repository);

  Future<Mealplan> call() => repository.getCurrentMealplan();
} 