
import 'package:camera/camera.dart';
import 'package:frontend/common/data/ingredients.dart';
import 'package:frontend/common/models/ingredient.dart';
import 'package:frontend/features/camera/data/datasources/image_recognition_api_data_source.dart';
import 'package:frontend/features/camera/domain/repositories/image_recognition_repository.dart';

Map<String, String> _aliasToIdMap = {};

void _initializeAliasMap() {
  if (_aliasToIdMap.isNotEmpty) return;
    
    // Nur einmal initialisieren
    for (var ingredient in allIngredients) {
      // Füge die kanonische ID selbst hinzu, falls nicht schon vorhanden
      _aliasToIdMap[ingredient.id] = ingredient.id;
      // Füge den Namen selbst hinzu, falls er sich von der ID unterscheidet
      // und nicht schon als ID oder Alias vorhanden ist
      final normalizedNameForId = ingredient.name.toLowerCase().replaceAll(' ', '_');
      if (_aliasToIdMap[normalizedNameForId] == null) {
        _aliasToIdMap[normalizedNameForId] = ingredient.id;
      }

      if (ingredient.aliases != null) {
        for (var alias in ingredient.aliases!) {
          // Normalisiere auch die Aliase (Kleinbuchstaben, Unterstriche)
          final normalizedAlias = alias.toLowerCase().replaceAll(' ', '_');
          _aliasToIdMap[normalizedAlias] = ingredient.id;
        }
      }
    }
    print('Alias-Map initialisiert: ${_aliasToIdMap.length} Einträge.');
}


class ImageRecognitionRepositoryImpl implements ImageRecognitionRepository {
  final ImageRecognitionApiDataSource dataSource; // Abhängigkeit zur DataSource

  ImageRecognitionRepositoryImpl(this.dataSource) {
    _initializeAliasMap();  
  }// Constructor für Dependency Injection

  String _normalizeIngredientNameForIdMatching(String name) {
    // 1. Eingangs-Namen normalisieren (Kleinbuchstaben, Unterstriche)
    final normalizedInput = name.toLowerCase().trim().replaceAll(' ', '_');

    // 2. Direkter Lookup in der vorbereiteten Alias-Map
    // Wenn der normalisierte Input direkt in der Map ist (egal ob ID oder Alias),
    // erhalten wir die zugehörige kanonische ID.
    final matchedId = _aliasToIdMap[normalizedInput];
    if (matchedId != null) {
      return matchedId;
    }

    // 3. Fallback: Einfache Singular-Regeln für allgemeine Fälle,
    // falls kein direkter Alias-Match gefunden wurde.
    // Dies ist eine "best effort"-Regel für neue, unvorhergesehene Varianten.
    String tempName = normalizedInput;
    if (tempName.endsWith('es') && tempName.length > 2 && !tempName.endsWith('ches') && !tempName.endsWith('shes')) {
      tempName = tempName.substring(0, tempName.length - 2);
    } else if (tempName.endsWith('s') && tempName.length > 1) {
      tempName = tempName.substring(0, tempName.length - 1);
    }

    // Erneuter Lookup nach der Fallback-Singularisierung
    final fallbackMatchedId = _aliasToIdMap[tempName];
    if (fallbackMatchedId != null) {
        return fallbackMatchedId;
    }
    
    // Wenn alles fehlschlägt, geben wir den (versuchten) Singular zurück.
    // Dieser wird dann im .firstWhere als "nicht gefunden" behandelt.
    return tempName; 
  }

  @override
  Future<List<Ingredient>> processImages(List<XFile> images) async {
    final List<String> recognizedStrings = await dataSource.recognizeIngredients(images);

    final List<Ingredient> matchedIngredients = [];
    final Set<String> addedIngredientIds = {};

    for (final recognizedNameRaw in recognizedStrings) {
      final normalizedIdCandidate = _normalizeIngredientNameForIdMatching(recognizedNameRaw);

      if (addedIngredientIds.contains(normalizedIdCandidate)) {
        continue;
      }

      final matchingIngredient = allIngredients.where(
        (ing) => ing.id == normalizedIdCandidate, // Abgleich immer über die ID
      ).toList();

      if (matchingIngredient.isNotEmpty) {
        matchedIngredients.add(matchingIngredient.first);
        addedIngredientIds.add(matchingIngredient.first.id);
      } else {
        print('Warning: Normalisierte ID "$normalizedIdCandidate" (ursprünglich: "$recognizedNameRaw") nicht in der lokalen allIngredients-Liste gefunden. Wird übersprungen.');
      }
    }

    return matchedIngredients;
  }
}