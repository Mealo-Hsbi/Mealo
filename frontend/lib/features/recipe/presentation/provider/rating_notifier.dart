// lib/features/recipe/presentation/provider/rating_notifier.dart

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:frontend/core/error/failures.dart';
import 'package:frontend/features/recipe/domain/entities/recipe.dart';
import 'package:frontend/features/recipe/domain/entities/recipe_rating.dart';
import 'package:frontend/features/recipe/domain/usecases/add_or_update_recipe_rating.dart';
import 'package:frontend/features/recipe/domain/usecases/get_user_recipe_rating.dart';
import 'package:frontend/features/recipe/data/models/recipe_rating_response_model.dart'; // Ensure this is imported

class RatingNotifier extends ChangeNotifier {
  final AddOrUpdateRecipeRating addOrUpdateRecipeRatingUseCase;
  final GetUserRecipeRating getUserRecipeRatingUseCase;

  // Statusvariablen für den Notifier
  bool _isLoading = false;
  String? _errorMessage;
  // NEW: State for average rating and rating count
  double _averageRating = 0.0;
  int _ratingCount = 0;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  // NEW: Getters for average rating and rating count
  double get averageRating => _averageRating;
  int get ratingCount => _ratingCount;


  RatingNotifier({
    required this.addOrUpdateRecipeRatingUseCase,
    required this.getUserRecipeRatingUseCase,
  });

  // --- NEW METHODS TO ADD ---

  /// Sets the initial average rating from external data (e.g., RecipeDetails).
  void setInitialAverageRating(double avg) {
    if (_averageRating != avg) { // Only update if value truly changes to avoid unnecessary rebuilds
      _averageRating = avg;
      // No notifyListeners here for initial set; it's typically set during widget build/init.
      // If you find the UI doesn't update immediately on first load, you might need notifyListeners() here.
    }
  }

  /// Sets the initial rating count from external data (e.g., RecipeDetails).
  void setInitialRatingCount(int count) {
    if (_ratingCount != count) { // Only update if value truly changes
      _ratingCount = count;
      // No notifyListeners here for initial set.
    }
  }

  /// Manages the loading state and notifies listeners.
  void setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }

  // --- END OF NEW METHODS ---

  // Methode zum Hinzufügen oder Aktualisieren einer Bewertung
  Future<void> addOrUpdateRecipeRating({
    required String userId,
    required int? spoonacularId,
    required int score,
    required Recipe recipe,
    String? comment,
  }) async {
    setLoading(true); // Use the new setter
    _clearError();

    try {
      final response = await addOrUpdateRecipeRatingUseCase(
        userId: userId,
        spoonacularId: spoonacularId,
        score: score,
        recipe: recipe,
        comment: comment,
      );

      // UPDATE THE NEW STATE VARIABLES
      _averageRating = response.averageRating;
      _ratingCount = response.ratingCount;

      debugPrint('Rating added/updated successfully. New average: $_averageRating, count: $_ratingCount');
      notifyListeners(); // Notify listeners about changes in averageRating and ratingCount
    } catch (e) {
      _setError(_mapExceptionToFailure(e));
      rethrow;
    } finally {
      setLoading(false); // Use the new setter
    }
  }

  // Methode zum Abrufen der Benutzerbewertung
  Future<RecipeRating?> getUserRecipeRating({
    required String userId,
    required String recipeId,
  }) async {
    setLoading(true); // Use the new setter
    _clearError();

    RecipeRating? rating;
    try {
      rating = await getUserRecipeRatingUseCase(
        userId: userId,
        recipeId: recipeId,
      );
      // If getUserRecipeRating also returned average/count, you'd update them here too.
      // For now, it seems to only return the user's individual rating.
    } catch (e) {
      _setError(_mapExceptionToFailure(e));
      rating = null;
      rethrow;
    } finally {
      setLoading(false); // Use the new setter
    }
    return rating;
  }

  // Hilfsmethode zur Umwandlung von Exceptions in Failures
  Failure _mapExceptionToFailure(Object e) {
    if (e is Failure) {
      return e;
    } else if (e is DioException) {
      if (e.type == DioExceptionType.connectionTimeout) {
        return TimeoutFailure(message: 'Connection timed out. Please try again later.');
      } else if (e.response != null) {
        return ServerFailure(message: 'Server error: ${e.response?.statusMessage ?? e.message}');
      }
      return ServerFailure(message: 'Network error: ${e.message}');
    }
    return ServerFailure(message: 'An unexpected error occurred: ${e.toString()}');
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