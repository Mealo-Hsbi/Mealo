import 'package:dio/dio.dart';
import '../domain/entities/achievement.dart';
import '../../../services/api_client.dart';

class AchievementService {
  final ApiClient _apiClient = ApiClient();

  /// Holt alle Achievements vom Backend
  Future<List<Achievement>> getAllAchievements() async {
    try {
      final response = await _apiClient.get('/achievements');
      
      if (response.statusCode == 200) {
        final List<dynamic> achievementsJson = response.data as List<dynamic>;
        return achievementsJson
            .map((json) => Achievement.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Failed to load achievements: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('Error fetching achievements: ${e.message}');
      if (e.response?.statusCode == 401) {
        throw Exception('Authentication required');
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      print('Unexpected error fetching achievements: $e');
      throw Exception('Unexpected error: $e');
    }
  }

  /// Holt ein spezifisches Achievement nach ID
  Future<Achievement> getAchievementById(String id) async {
    try {
      final response = await _apiClient.get('/achievements/$id');
      
      if (response.statusCode == 200) {
        return Achievement.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception('Failed to load achievement: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('Error fetching achievement: ${e.message}');
      if (e.response?.statusCode == 404) {
        throw Exception('Achievement not found');
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      print('Unexpected error fetching achievement: $e');
      throw Exception('Unexpected error: $e');
    }
  }
} 