import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:frontend/core/config/app_config.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../common/models/recipe.dart';

class RecipeService {
  static Future<List<Recipe>> fetchRandomRecipes({int number = 10}) async {
    final url = Uri.parse(
      '${AppConfig.spoonacularBaseUrl}/recipes/random?number=$number&apiKey=${AppConfig.spoonacularApiKey}',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> recipesJson = data['recipes'];

      return recipesJson
          .map((json) => Recipe.fromJson(json as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Fehler beim Laden der Rezepte: ${response.statusCode}');
    }
  }

  static Future<List<Recipe>> fetchUserRecipes(String jwtToken) async {
    final baseUrl = dotenv.env['API_BASE_URL']!;
    final url = Uri.parse('$baseUrl/recipes/mine');
    final response = await http.get(url, headers: {
      'Authorization': 'Bearer $jwtToken',
    });
    if (response.statusCode == 200) {
      final List<dynamic> recipesJson = json.decode(response.body);
      return recipesJson.map((json) => Recipe.fromJson(json)).toList();
    } else {
      throw Exception('Fehler beim Laden der eigenen Rezepte: \\${response.statusCode}');
    }
  }
}