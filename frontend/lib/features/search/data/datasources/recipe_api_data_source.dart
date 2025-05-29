// lib/features/search/data/datasources/recipe_api_data_source.dart
import 'dart:async'; // Für TimeoutException, falls euer ApiClient diese wirft
import 'dart:convert'; // Für jsonDecode
import 'package:dio/dio.dart'; // Für DioException und Response
import 'package:frontend/common/models/recipe.dart';
import 'package:frontend/common/models/recipe_details.dart'; // Wichtig für getRecipeDetails
import 'package:frontend/services/api_client.dart'; // Importiere deinen ApiClient

class RecipeApiDataSource {
  final ApiClient _apiClient; // Abhängigkeit zum ApiClient

  // Konstruktor für Dependency Injection
  RecipeApiDataSource(this._apiClient);

  /// Führt eine Rezeptsuche über das Backend durch.
  /// Nutzt die POST-Route für die Suche.
  Future<List<Recipe>> searchRecipes({
    required String query,
    List<String>? ingredients,
    Map<String, dynamic>? filters,
    String? sortBy,
    String? sortDirection,
  }) async {
    try {
      final String endpoint = '/recipes/search'; // Die Backend-Route für die Suche

      final Response response = await _apiClient.post(
        endpoint,
        data: { // Der Body für die POST-Anfrage
          'query': query,
          'ingredients': ingredients,
          'filters': filters,
          'sortBy': sortBy,
          'sortDirection': sortDirection,
        },
        options: Options(
          // Optional: Setze spezifische Timeouts für diese Anfrage, falls nötig
          sendTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 30),
        ),
      );

      if (response.statusCode == 200) {
        // response.data sollte bereits ein List<dynamic> sein,
        // da Dio das JSON automatisch parst, wenn der Content-Type passt.
        final List<dynamic> jsonList = response.data;
        return jsonList.map((json) => Recipe.fromJson(json)).toList();
      } else {
        // Dio wirft bei Nicht-2xx Statuscodes standardmäßig eine DioException.
        // Diese Zeile würde nur erreicht, wenn Dio bei 200 ist, aber die Daten unerwartet sind.
        // Bessere Fehlerbehandlung findet in der DioException catch block statt.
        throw Exception('Unerwarteter Statuscode: ${response.statusCode}');
      }
    } on DioException catch (e) {
      // Behandle verschiedene Arten von Dio-Fehlern
      if (e.type == DioExceptionType.connectionTimeout || e.type == DioExceptionType.receiveTimeout) {
        throw TimeoutException('Die Verbindung zum Server ist abgelaufen. Bitte versuche es später erneut.');
      }
      if (e.response != null) {
        // Wenn der Server eine Antwort gesendet hat (z.B. 400, 404, 500)
        final errorData = e.response!.data;
        throw Exception('Fehler bei der Rezeptsuche: ${errorData['message'] ?? e.message}');
      } else {
        // Netzwerkfehler oder andere Probleme
        throw Exception('Netzwerkfehler oder Serverproblem: ${e.message}');
      }
    } catch (e) {
      // Fange alle anderen unerwarteten Fehler ab
      print('Unerwarteter Fehler in RecipeApiDataSource.searchRecipes: $e');
      rethrow; // Leite die Ausnahme weiter
    }
  }

  /// Ruft detaillierte Informationen für ein spezifisches Rezept ab.
  /// Nutzt die GET-Route für Rezeptdetails.
  Future<RecipeDetails> getRecipeDetails(int recipeId) async {
    try {
      final String endpoint = '/api/recipes/$recipeId/details'; // Die Backend-Route für Details

      final Response response = await _apiClient.get(
        endpoint,
        options: Options(
          sendTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 20),
        ),
      );

      if (response.statusCode == 200) {
        // response.data sollte bereits ein Map<String, dynamic> sein
        final Map<String, dynamic> json = response.data;
        return RecipeDetails.fromJson(json);
      } else {
        throw Exception('Unerwarteter Statuscode: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout || e.type == DioExceptionType.receiveTimeout) {
        throw TimeoutException('Die Verbindung zum Server ist abgelaufen. Bitte versuche es später erneut.');
      }
      if (e.response != null) {
        final errorData = e.response!.data;
        throw Exception('Fehler beim Laden der Rezeptdetails: ${errorData['message'] ?? e.message}');
      } else {
        throw Exception('Netzwerkfehler oder Serverproblem: ${e.message}');
      }
    } catch (e) {
      print('Unerwarteter Fehler in RecipeApiDataSource.getRecipeDetails: $e');
      rethrow;
    }
  }
}