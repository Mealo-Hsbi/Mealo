import 'package:equatable/equatable.dart';
import 'package:frontend/features/recipe/domain/entities/recipe_rating.dart';

/// Repräsentiert die vollständige Antwort nach dem Hinzufügen/Aktualisieren einer Bewertung,
/// einschließlich der individuellen Nutzerbewertung und der aggregierten Werte.
class RecipeRatingResponse extends Equatable {
  final RecipeRating userRating;
  final double? averageRating;
  final int? ratingCount;

  const RecipeRatingResponse({
    required this.userRating,
    this.averageRating,
    this.ratingCount,
  });

  @override
  List<Object?> get props => [userRating, averageRating, ratingCount];
}
