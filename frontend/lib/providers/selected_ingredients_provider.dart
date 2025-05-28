import 'package:flutter/foundation.dart'; // Für ChangeNotifier
import 'package:frontend/common/models/ingredient.dart'; // Dein Ingredient Model

class SelectedIngredientsProvider with ChangeNotifier {
  List<Ingredient> _ingredients = [];

  List<Ingredient> get ingredients => _ingredients;

  // Methode, um die gesamte Liste der ausgewählten Zutaten zu setzen (z.B. von der Kamera)
  void setIngredients(List<Ingredient> newIngredients) {
    _ingredients = List.from(newIngredients); // Wichtig: Eine Kopie erstellen, um Seiteneffekte zu vermeiden
    notifyListeners();
  }

  // Methode zum Hinzufügen einer Zutat
  void addIngredient(Ingredient ingredient) {
    if (!_ingredients.contains(ingredient)) { // Vermeide Duplikate
      _ingredients.add(ingredient);
      notifyListeners();
    }
  }

  // Methode zum Entfernen einer Zutat
  void removeIngredient(Ingredient ingredient) {
    if (_ingredients.contains(ingredient)) {
      _ingredients.remove(ingredient);
      notifyListeners();
    }
  }

  // Optional: Alle Zutaten löschen
  void clearIngredients() {
    _ingredients.clear();
    notifyListeners();
  }
  
}