// lib/features/recipe/data/models/favorite_model.dart
import 'package:equatable/equatable.dart';
import 'package:frontend/features/recipe/domain/entities/favorite.dart';
import 'package:frontend/features/recipe/data/models/recipe_model.dart';

class FavoriteModel extends Equatable {
  final String? id; // Make ID nullable
  final String userId;
  final String recipeId;
  final DateTime createdAt;
  final RecipeModel recipe;

  const FavoriteModel({
    this.id, // Now nullable in constructor
    required this.userId,
    required this.recipeId,
    required this.createdAt,
    required this.recipe,
  });

  factory FavoriteModel.fromJson(Map<String, dynamic> json) {
    return FavoriteModel(
      id: json['id'] as String?, // Safely cast to String?
      userId: json['userId'] as String,
      recipeId: json['recipeId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      recipe: RecipeModel.fromJson(json['recipe'] as Map<String, dynamic>),
    );
  }

  // Methode zur Umwandlung des FavoriteModel in die Favorite Domain-Entität
  Favorite toEntity() {
    return Favorite(
      id: id ?? '', // Provide a default value if id is null
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
  List<Object> get props => [id ?? '', userId, recipeId, createdAt, recipe];
}