import '../../domain/repositories/mealplan_repository.dart';
import 'package:frontend/common/models/mealplan.dart';
import '../datasources/mealplan_remote_datasource.dart';

class MealplanRepositoryImpl implements MealplanRepository {
  final MealplanRemoteDatasource remoteDatasource;

  MealplanRepositoryImpl(this.remoteDatasource);

  @override
  Future<Mealplan> getCurrentMealplan() => remoteDatasource.getCurrentMealplan();

  @override
  Future<void> updateCurrentMealplan(Map<String, dynamic> payload) =>
      remoteDatasource.updateCurrentMealplan(payload);
} 