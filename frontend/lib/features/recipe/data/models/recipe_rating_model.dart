// lib/features/recipe/data/models/recipe_rating_model.dart
import 'package:equatable/equatable.dart';
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
    return RecipeRatingModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      recipeId: json['recipeId'] as String,
      score: json['score'] as int,
      comment: json['comment'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
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
  // Nützlich, wenn Sie Bewertungen zum Backend senden (z.B. bei addOrUpdate)
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
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'recipeId': recipeId,
      'score': score,
      'comment': comment,
      'createdAt': createdAt.toIso8601String(),
    };
  }


  @override
  List<Object?> get props => [id, userId, recipeId, score, comment, createdAt];
}