
import 'package:camera/camera.dart';
import 'package:frontend/common/data/ingredients.dart';
import 'package:frontend/common/models/ingredient.dart';
import 'package:frontend/features/camera/data/datasources/image_recognition_api_data_source.dart';
import 'package:frontend/features/camera/domain/repositories/image_recognition_repository.dart';

class ImageRecognitionRepositoryImpl implements ImageRecognitionRepository {
  final ImageRecognitionApiDataSource dataSource; // Abhängigkeit zur DataSource

  ImageRecognitionRepositoryImpl(this.dataSource); // Constructor für Dependency Injection

  @override
  Future<List<Ingredient>> processImages(List<XFile> images) async {
    // Ruft die DataSource auf, um die rohen Strings vom Backend zu erhalten
    final List<String> recognizedStrings = await dataSource.recognizeIngredients(images);

    // Wandelt die erkannten Strings in Ingredient-Objekte um.
    // Hier wird versucht, die Namen mit der allIngredients-Liste abzugleichen,
    // um vollständige Ingredient-Objekte (mit id und imageUrl) zu erhalten.
    // return recognizedStrings.map((name) {
    //   final matchingIngredient = allIngredients.firstWhere(
    //     (ing) => ing.name.toLowerCase() == name.toLowerCase(),
    //     orElse: () => Ingredient(
    //         id: name.toLowerCase(),
    //         name: name,
    //         imageUrl:
    //             ''), // Fallback: Erstelle ein einfaches Ingredient-Objekt, wenn kein Match gefunden wird
    //   );
    //   return matchingIngredient;
    // }).toList();


    final List<Ingredient> matchedIngredients = [];

    for (final recognizedName in recognizedStrings) {
      // Find a matching ingredient in allIngredients, ignoring case
      final matchingIngredient = allIngredients.cast<Ingredient?>().firstWhere( // Cast to Ingredient? for null-safety with orElse: null
        (ing) => ing != null && ing.name.toLowerCase() == recognizedName.toLowerCase(),
        orElse: () => null, // If no match, return null
      );

      // If a match was found (not null), add it to the list
      if (matchingIngredient != null) {
        matchedIngredients.add(matchingIngredient);
      } else {
        // Optional: Log which recognized strings were not found in your local list
        print('Warning: Recognized ingredient "$recognizedName" not found in local allIngredients list. Skipping.');
      }
    }

    return matchedIngredients;
  }
}