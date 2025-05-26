import 'package:camera/camera.dart';
import 'package:frontend/common/models/ingredient.dart'; // Für den Typ XFile


abstract class ImageRecognitionRepository {
  Future<List<Ingredient>> processImages(List<XFile> images);
}