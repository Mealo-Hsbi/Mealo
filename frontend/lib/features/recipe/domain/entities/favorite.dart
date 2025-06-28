// lib/features/recipe/domain/entities/favorite.dart
import 'package:equatable/equatable.dart';
import 'package:frontend/features/recipe/domain/entities/recipe.dart';

class Favorite extends Equatable {
  final String? id; // Make ID nullable here too
  final String userId;
  final String recipeId;
  final DateTime createdAt;
  final Recipe recipe;

  const Favorite({
    this.id, // Nullable in constructor
    required this.userId,
    required this.recipeId,
    required this.createdAt,
    required this.recipe,
  });

  @override
  List<Object?> get props => [id, userId, recipeId, createdAt, recipe]; // Use Object? for nullable fields
}