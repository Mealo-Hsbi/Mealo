// lib/features/recipe/data/models/favorite_model.dart
import 'package:equatable/equatable.dart';
import 'package:frontend/features/recipe/domain/entities/favorite.dart';
import 'package:frontend/features/recipe/data/models/recipe_model.dart';

class FavoriteModel extends Equatable {
  final String id;
  final String userId;
  final String recipeId;
  final DateTime createdAt;
  final RecipeModel recipe; // Das Rezept, das favorisiert wurde, als Modell

  const FavoriteModel({
    required this.id,
    required this.userId,
    required this.recipeId,
    required this.createdAt,
    required this.recipe,
  });

  // Factory-Methode zum Erstellen eines FavoriteModel aus JSON (von Ihrem Backend)
  factory FavoriteModel.fromJson(Map<String, dynamic> json) {
    return FavoriteModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      recipeId: json['recipeId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      recipe: RecipeModel.fromJson(json['recipe'] as Map<String, dynamic>),
    );
  }

  // Methode zur Umwandlung des FavoriteModel in die Favorite Domain-Entität
  Favorite toEntity() {
    return Favorite(
      id: id,
      userId: userId,
      recipeId: recipeId,
      createdAt: createdAt,
      recipe: recipe.toEntity(), // Rekursiver Aufruf zur Umwandlung des Rezept-Modells
    );
  }

  // Methode zur Umwandlung der Favorite Domain-Entität in ein FavoriteModel
  // Nützlich, wenn Sie Favoriten zum Backend senden müssen
  factory FavoriteModel.fromEntity(Favorite entity) {
    return FavoriteModel(
      id: entity.id,
      userId: entity.userId,
      recipeId: entity.recipeId,
      createdAt: entity.createdAt,
      recipe: RecipeModel.fromEntity(entity.recipe), // Rekursiver Aufruf
    );
  }

  @override
  List<Object> get props => [id, userId, recipeId, createdAt, recipe];
}