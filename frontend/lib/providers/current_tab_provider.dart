import 'package:flutter/foundation.dart';

class CurrentTabProvider with ChangeNotifier {
  int _currentIndex = 0;
  bool _shouldNavigateToSearch = false; // NEU: Flag für automatische Navigation

  int get currentIndex => _currentIndex;
  bool get shouldNavigateToSearch => _shouldNavigateToSearch;

  void setCurrentIndex(int index, {bool navigateToSearch = false}) { // NEU: navigateToSearch Parameter
    if (_currentIndex != index) {
      _currentIndex = index;
      _shouldNavigateToSearch = navigateToSearch;
      notifyListeners();
    } else if (navigateToSearch && !_shouldNavigateToSearch) {
      // Fall: Aktueller Tab ist bereits der Ziel-Tab, aber wir wollen trotzdem navigieren
      _shouldNavigateToSearch = navigateToSearch;
      notifyListeners();
    } else if (!navigateToSearch && _shouldNavigateToSearch) {
      // Fall: Flag zurücksetzen, wenn der Tab gewechselt wurde und keine Navigation gewünscht ist
      _shouldNavigateToSearch = false;
      notifyListeners();
    }
  }

  // Methode, um das Flag zurückzusetzen, nachdem die Navigation erfolgt ist
  void resetSearchNavigation() {
    if (_shouldNavigateToSearch) {
      _shouldNavigateToSearch = false;
      notifyListeners();
    }
  }
}