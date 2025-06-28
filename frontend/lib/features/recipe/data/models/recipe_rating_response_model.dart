// lib/features/recipe/data/models/recipe_rating_response_model.dart
import 'package:equatable/equatable.dart';
import 'package:frontend/features/recipe/data/models/recipe_rating_model.dart';
import 'package:frontend/features/recipe/domain/entities/recipe_rating.dart'; // Import RecipeRating

class RecipeRatingResponseModel extends Equatable {
  final RecipeRatingModel userRating;
  final double averageRating;
  final int ratingCount;

  const RecipeRatingResponseModel({
    required this.userRating,
    required this.averageRating,
    required this.ratingCount,
  });

  factory RecipeRatingResponseModel.fromJson(Map<String, dynamic> json) {
    return RecipeRatingResponseModel(
      userRating: RecipeRatingModel.fromJson(json['userRating'] as Map<String, dynamic>),
      averageRating: (json['averageRating'] as num).toDouble(),
      ratingCount: json['ratingCount'] as int,
    );
  }

  // Optional: A method to convert this model to a domain entity
  // This depends on whether your domain layer needs this combined data
  // For now, we'll primarily use it in the data and presentation layers.
  // If your domain layer (e.g., RecipeRating) doesn't need all three,
  // you might just pass the individual parts up, or create a new domain entity.
  // For simplicity, let's assume RecipeRating still represents only the user's rating.
  // The average/count will be passed separately or used directly in presentation.

  @override
  List<Object?> get props => [userRating, averageRating, ratingCount];
}