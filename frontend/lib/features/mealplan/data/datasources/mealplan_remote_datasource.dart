import 'package:frontend/common/models/mealplan.dart';
import 'package:frontend/services/api_client.dart';

class MealplanRemoteDatasource {
  final ApiClient apiClient;

  MealplanRemoteDatasource(this.apiClient);

  Future<Mealplan> getCurrentMealplan() async {
    final response = await apiClient.get('/mealplan/current');
    return Mealplan.fromJson(response.data);
  }

  Future<void> updateCurrentMealplan(Map<String, dynamic> payload) async {
    await apiClient.put('/mealplan/current', data: payload);
  }
} 