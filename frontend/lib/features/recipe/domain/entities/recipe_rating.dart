// lib/features/recipe/domain/entities/recipe_rating.dart
import 'package:equatable/equatable.dart';

class RecipeRating extends Equatable {
  final String id; // UUID des Rating-Eintrags in Ihrer DB
  final String userId; // UUID des Benutzers
  final String recipeId; // UUID des Rezepts aus IHRER DB (Verweis auf recipe.id)
  final int score; // Die Bewertung (z.B. 1-5 Sterne)
  final String? comment; // Optionaler Kommentar
  final DateTime createdAt;

  const RecipeRating({
    required this.id,
    required this.userId,
    required this.recipeId,
    required this.score,
    this.comment,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, userId, recipeId, score, comment, createdAt];
}