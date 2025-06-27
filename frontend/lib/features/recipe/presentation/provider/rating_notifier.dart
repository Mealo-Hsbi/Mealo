// lib/features/recipe/presentation/provider/rating_notifier.dart

import 'package:flutter/material.dart';
import 'package:frontend/core/error/failures.dart'; // Ihre Failure-Klassen
import 'package:frontend/features/recipe/domain/entities/recipe.dart';
import 'package:frontend/features/recipe/domain/entities/recipe_rating.dart';
import 'package:frontend/features/recipe/domain/usecases/add_or_update_recipe_rating.dart';
import 'package:frontend/features/recipe/domain/usecases/get_user_recipe_rating.dart';

// Enum für den Zustand der Bewertung
enum RatingStatus { initial, loading, loaded, error }

class RatingNotifier extends ChangeNotifier {
  // Use Cases, die über den Konstruktor injiziert werden
  final AddOrUpdateRecipeRating addOrUpdateRecipeRatingUseCase;
  final GetUserRecipeRating getUserRecipeRatingUseCase;

  // Zustand der Bewertung
  RecipeRating? _currentRating; // Die Bewertung des aktuell angezeigten Rezepts durch den Nutzer
  RecipeRating? get currentRating => _currentRating;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  RatingStatus _status = RatingStatus.initial;
  RatingStatus get status => _status;

  // Map, um Bewertungen für verschiedene Rezepte zu cachen (optional, aber nützlich)
  final Map<String, RecipeRating> _cachedRatings = {};

  RatingNotifier({
    required this.addOrUpdateRecipeRatingUseCase,
    required this.getUserRecipeRatingUseCase,
  });

  // --- Methoden für Bewertungen ---

  Future<void> addOrUpdateRating(String userId, int? spoonacularId, int score, Recipe recipe, {String? comment}) async {
    _setLoading();
    try {
      // KORRIGIERTER AUFRUF: explizit benannte Parameter verwenden
      final updatedRating = await addOrUpdateRecipeRatingUseCase(
        userId: userId,
        spoonacularId: spoonacularId,
        score: score,
        recipe: recipe,
        comment: comment,
      );
      _currentRating = updatedRating;
      if (recipe.id != null) {
        _cachedRatings[recipe.id!] = updatedRating; // Cache aktualisieren
      }
      _setStatus(RatingStatus.loaded);
    } on Failure catch (e) {
      _setError(e.message);
    }
  }

  Future<void> fetchUserRecipeRating(String userId, String recipeId) async {
    // Zuerst im Cache nachschauen
    if (_cachedRatings.containsKey(recipeId)) {
      _currentRating = _cachedRatings[recipeId];
      _setStatus(RatingStatus.loaded);
      return;
    }

    _setLoading();
    try {
      // KORRIGIERTER AUFRUF
      _currentRating = await getUserRecipeRatingUseCase(
        userId: userId,
        recipeId: recipeId,
      );
      if (_currentRating != null) {
        _cachedRatings[recipeId] = _currentRating!; // Zum Cache hinzufügen
      }
      _setStatus(RatingStatus.loaded);
    } on Failure catch (e) {
      _setError(e.message);
    }
  }

  // Setzt die aktuell angezeigte Bewertung zurück, z.B. beim Wechsel des Rezepts
  void clearCurrentRating() {
    _currentRating = null;
    _status = RatingStatus.initial;
    _errorMessage = null;
    notifyListeners();
  }

  // Diese Methode kann nützlich sein, wenn sich der User ändert oder ausgeloggt wird
  void reset() {
    _currentRating = null;
    _cachedRatings.clear();
    _isLoading = false;
    _errorMessage = null;
    _status = RatingStatus.initial;
    notifyListeners();
  }

  // --- Hilfsmethoden für den Zustand ---
  void _setLoading() {
    _isLoading = true;
    _errorMessage = null;
    _status = RatingStatus.loading;
    notifyListeners();
  }

  void _setError(String message) {
    _isLoading = false;
    _errorMessage = message;
    _status = RatingStatus.error;
    notifyListeners();
  }

  void _setStatus(RatingStatus newStatus) {
    _isLoading = false;
    _status = newStatus;
    if (newStatus == RatingStatus.loaded) {
      _errorMessage = null;
    }
    notifyListeners();
  }
}