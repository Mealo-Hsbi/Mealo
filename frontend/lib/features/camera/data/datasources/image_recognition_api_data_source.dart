import 'dart:async'; // Für TimeoutException
import 'package:camera/camera.dart'; // Für XFile
import 'package:dio/dio.dart'; // Für Dio und FormData/MultipartFile
import 'package:frontend/services/api_client.dart';

class ImageRecognitionApiDataSource {
  final ApiClient _apiClient; // Abhängigkeit zum ApiClient

  // Konstruktor für Dependency Injection
  ImageRecognitionApiDataSource(this._apiClient);

  Future<List<String>> recognizeIngredients(List<XFile> images) async {
    try {
      // Die korrekte Backend-Route
      final String endpoint = '/image-recognition/recognize';

      // Erstelle FormData für den Upload von Dateien
      final FormData formData = FormData.fromMap({
        'images': await Future.wait(images.map((img) async =>
            await MultipartFile.fromFile(img.path, filename: img.name))),
        // Optional: Füge hier weitere Daten hinzu, die euer Backend benötigt, z.B. eine User-ID
        // 'userId': 'some_user_id',
      });

      // Sende die POST-Anfrage über deinen ApiClient
      final Response response = await _apiClient.post(
        endpoint,
        data: formData,
        // Optional: Setze einen spezifischen Timeout nur für diese Anfrage
        options: Options(
          sendTimeout: const Duration(seconds: 30), // Sende-Timeout
          receiveTimeout: const Duration(seconds: 60), // Empfangs-Timeout
        ),
      );

      // Überprüfe den Statuscode der Antwort
      if (response.statusCode == 200) {
        // Da das Backend jetzt ein Array von Strings zurückgibt,
        // können wir response.data direkt als List<String> casten.
        return List<String>.from(response.data);
      } else {
        // Behandle Nicht-200-Statuscodes als Fehler
        throw Exception('Fehler vom Backend: Status ${response.statusCode}, Daten: ${response.data}');
      }

    } on DioException catch (e) { // DioException ist der Typ für Fehler von Dio
      if (e.type == DioExceptionType.connectionTimeout || e.type == DioExceptionType.receiveTimeout) {
        throw TimeoutException('Die Verbindung zum Server ist abgelaufen. Bitte versuche es später erneut.');
      }
      // Andere Dio-Fehler behandeln
      throw Exception('Netzwerkfehler oder Serverproblem: ${e.message}');
    } catch (e) {
      // Fange alle anderen unerwarteten Fehler ab
      print('Unerwarteter Fehler in ImageRecognitionApiDataSource: $e');
      rethrow; // Leite die Ausnahme weiter
    }
  }
}