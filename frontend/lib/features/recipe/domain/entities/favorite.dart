// lib/features/recipe/domain/entities/favorite.dart
import 'package:equatable/equatable.dart';
import 'package:frontend/features/recipe/domain/entities/recipe.dart'; // Wichtig: Pfad zur neuen Domain-Recipe-Entität

class Favorite extends Equatable {
  final String id; // UUID des Favorite-Eintrags in Ihrer DB
  final String userId; // UUID des Benutzers
  final String recipeId; // UUID des Rezepts aus IHRER DB (Verweis auf recipe.id)
  final DateTime createdAt;
  final Recipe recipe; // Das komplette Rezept-Objekt (Domain-Entität)

  const Favorite({
    required this.id,
    required this.userId,
    required this.recipeId,
    required this.createdAt,
    required this.recipe,
  });

  @override
  List<Object> get props => [id, userId, recipeId, createdAt, recipe];
}