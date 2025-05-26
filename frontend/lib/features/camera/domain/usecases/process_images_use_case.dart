import 'package:camera/camera.dart'; // Für XFile
import 'package:frontend/common/models/ingredient.dart';
import 'package:frontend/features/camera/domain/repositories/image_recognition_repository.dart'; // Abhängigkeit zum Repository Interface

class ProcessImagesUseCase {
  final ImageRecognitionRepository repository; // Abhängigkeit zum Repository

  ProcessImagesUseCase(this.repository); // Constructor für Dependency Injection

  Future<List<Ingredient>> call(List<XFile> images) async {
    // Ruft die Methode des Repositories auf
    return await repository.processImages(images);
  }
}