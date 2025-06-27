// lib/features/recipe/presentation/provider/rating_notifier.dart

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:frontend/core/error/failures.dart'; // Importieren Sie Ihre Failure-Klassen
import 'package:frontend/features/recipe/domain/entities/recipe.dart'; // NEU: Import für Recipe Entity
import 'package:frontend/features/recipe/domain/entities/recipe_rating.dart'; // NEU: Import für RecipeRating Entity
import 'package:frontend/features/recipe/domain/usecases/add_or_update_recipe_rating.dart';
import 'package:frontend/features/recipe/domain/usecases/get_user_recipe_rating.dart';

class RatingNotifier extends ChangeNotifier {
  final AddOrUpdateRecipeRating addOrUpdateRecipeRatingUseCase;
  final GetUserRecipeRating getUserRecipeRatingUseCase;

  // Statusvariablen für den Notifier
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  RatingNotifier({
    required this.addOrUpdateRecipeRatingUseCase,
    required this.getUserRecipeRatingUseCase,
  });

  // Methode zum Hinzufügen oder Aktualisieren einer Bewertung
  Future<void> addOrUpdateRecipeRating({
    required String userId,
    required int? spoonacularId,
    required int score,
    required Recipe recipe, // Verwenden Sie Recipe Entity, nicht RecipeModel
    String? comment,
  }) async {
    _setLoading(true);
    _clearError();

    // KORREKTUR: Parameter direkt an den Use Case übergeben
    final result = await addOrUpdateRecipeRatingUseCase(
      userId: userId,
      spoonacularId: spoonacularId,
      score: score,
      recipe: recipe,
      comment: comment,
    );

    // Der Use Case gibt direkt die RecipeRating-Entität zurück, nicht Either<Failure, RecipeRating>
    // Da keine Either-Klasse verwendet wird, müssen wir Fehler in der Catch-Klausel behandeln
    // (Diese Methode ist nicht ideal, wenn der Use Case keine Left/Right-Struktur verwendet)
    // Wenn addOrUpdateRecipeRatingUseCase eine Exception wirft, wird diese hier gefangen.
    try {
      // Wenn der Use Case direkt das Ergebnis zurückgibt und bei Fehlern eine Exception wirft.
      await addOrUpdateRecipeRatingUseCase(
        userId: userId,
        spoonacularId: spoonacularId,
        score: score,
        recipe: recipe,
        comment: comment,
      );
      debugPrint('Rating added/updated successfully.');
    } catch (e) {
      // Annahme: Alle Fehler von addOrUpdateRecipeRatingUseCase sind Failures.
      // Dies erfordert, dass Ihr Use Case selbst Failures wirft oder in ein Failure umwandelt.
      _setError(_mapExceptionToFailure(e)); // Hilfsmethode, um Exception in Failure umzuwandeln
    } finally {
      _setLoading(false);
    }
  }

  // Methode zum Abrufen der Benutzerbewertung
  // Annahme: getUserRecipeRating ebenfalls mit direkten benannten Parametern
  Future<RecipeRating?> getUserRecipeRating({
    required String userId,
    required String recipeId, // Hier ist es die DB-ID des Rezepts
  }) async {
    _setLoading(true);
    _clearError();

    RecipeRating? rating;
    try {
      // KORREKTUR: Parameter direkt an den Use Case übergeben
      rating = await getUserRecipeRatingUseCase(
        userId: userId,
        recipeId: recipeId,
      );
    } catch (e) {
      _setError(_mapExceptionToFailure(e));
      rating = null;
    } finally {
      _setLoading(false);
    }
    return rating;
  }

  // Hilfsmethode zur Umwandlung von Exceptions in Failures (falls Ihr Use Case Exceptions wirft)
  Failure _mapExceptionToFailure(Object e) {
    if (e is Failure) {
      return e; // Ist bereits eine Failure
    } else if (e is DioException) {
      // Hier können Sie spezifische DioException-Typen mappen
      if (e.type == DioExceptionType.connectionTimeout) {
        return TimeoutFailure(message: 'Connection timed out. Please try again later.');
      } else if (e.response != null) {
        return ServerFailure(message: 'Server error: ${e.response?.statusMessage ?? e.message}');
      }
      return ServerFailure(message: 'Network error: ${e.message}');
    }
    return ServerFailure(message: 'An unexpected error occurred: ${e.toString()}');
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(Failure failure) {
    if (failure is ServerFailure) {
      _errorMessage = failure.message;
    } else if (failure is CacheFailure) {
      _errorMessage = failure.message;
    } else if (failure is TimeoutFailure) {
      _errorMessage = 'The connection to the server timed out. Please try again later.';
    } else if (failure is CancelledFailure) {
      _errorMessage = 'Request was cancelled.';
    } else {
      _errorMessage = 'An unexpected error occurred: ${failure.toString()}';
    }
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}