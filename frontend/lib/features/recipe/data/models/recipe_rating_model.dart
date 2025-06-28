// lib/features/recipe/data/models/recipe_rating_model.dart
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart'; // Import für debugPrint
import 'package:frontend/features/recipe/domain/entities/recipe_rating.dart';

class RecipeRatingModel extends Equatable {
  final String id;
  final String userId;
  final String recipeId;
  final int score;
  final String? comment;
  final DateTime createdAt;

  const RecipeRatingModel({
    required this.id,
    required this.userId,
    required this.recipeId,
    required this.score,
    this.comment,
    required this.createdAt,
  });

  // Factory-Methode zum Erstellen eines RecipeRatingModel aus JSON (von Ihrem Backend)
  factory RecipeRatingModel.fromJson(Map<String, dynamic> json) {
    // Optional: Füge dies für erweiterte Debugging hinzu, um das eingehende JSON zu sehen
    debugPrint('RecipeRatingModel.fromJson received JSON: $json');

    return RecipeRatingModel(
      id: json['id'] as String,
      // KORREKTUR: Backend sendet 'user_id' (snake_case), nicht 'userId' (camelCase)
      userId: json['user_id'] as String,
      // KORREKTUR: Backend sendet 'recipe_id' (snake_case), nicht 'recipeId' (camelCase)
      recipeId: json['recipe_id'] as String,
      score: json['score'] as int,
      // 'comment' ist String? im Modell und im Backend nullable String.
      // 'as String?' ist korrekt, um null zu erlauben, wenn das Backend null sendet.
      comment: json['comment'] as String?,
      // KORREKTUR: Backend sendet 'created_at' (snake_case), nicht 'createdAt' (camelCase)
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  // Methode zur Umwandlung des RecipeRatingModel in die RecipeRating Domain-Entität
  RecipeRating toEntity() {
    return RecipeRating(
      id: id,
      userId: userId,
      recipeId: recipeId,
      score: score,
      comment: comment,
      createdAt: createdAt,
    );
  }

  // Methode zur Umwandlung der RecipeRating Domain-Entität in ein RecipeRatingModel
  factory RecipeRatingModel.fromEntity(RecipeRating entity) {
    return RecipeRatingModel(
      id: entity.id,
      userId: entity.userId,
      recipeId: entity.recipeId,
      score: entity.score,
      comment: entity.comment,
      createdAt: entity.createdAt,
    );
  }

  // Methode, um dieses Modell in ein JSON-Objekt für den Backend-Aufruf umzuwandeln
  // KORREKTUR: Sende auch hier konsistent snake_case, da das Backend dies erwartet.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,     // KORREKTUR: Sende 'user_id' an Backend
      'recipe_id': recipeId, // KORREKTUR: Sende 'recipe_id' an Backend
      'score': score,
      'comment': comment,
      'created_at': createdAt.toIso8601String(), // KORREKTUR: Sende 'created_at' an Backend
    };
  }


  @override
  List<Object?> get props => [id, userId, recipeId, score, comment, createdAt];
}
