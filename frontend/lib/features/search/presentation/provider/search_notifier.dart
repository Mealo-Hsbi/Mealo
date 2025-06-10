// lib/features/search/presentation/provider/search_notifier.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Für rootBundle

// Importe für Modelle und UseCase
import 'package:frontend/common/data/ingredients.dart'; // Für allIngredients
import 'package:frontend/common/models/ingredient.dart';
import 'package:frontend/common/models/recipe.dart';
// **NEU:** Importiere beide spezifischen Use Cases
import 'package:frontend/features/search/domain/usecases/search_recipes_by_query.dart';
import 'package:frontend/features/search/domain/usecases/search_recipes_by_ingredients.dart';
import 'package:frontend/common/utils/string_similarity_helper.dart';
import 'package:frontend/core/error/failures.dart'; // Für Fehlerbehandlung

class SearchNotifier extends ChangeNotifier {
  // **NEU:** Injektion beider spezifischer Use Cases
  final SearchRecipesByQuery _searchRecipesByQueryUsecase;
  final SearchRecipesByIngredients _searchRecipesByIngredientsUsecase;

  // **NEU:** Konstruktor erwartet jetzt beide Use Cases
  SearchNotifier({
    required SearchRecipesByQuery searchRecipesByQueryUsecase,
    required SearchRecipesByIngredients searchRecipesByIngredientsUsecase,
  })  : _searchRecipesByQueryUsecase = searchRecipesByQueryUsecase,
        _searchRecipesByIngredientsUsecase = searchRecipesByIngredientsUsecase;

  // --- State Variables ---
  String _query = '';
  List<Ingredient> _selectedIngredients = [];
  List<Ingredient> _filteredIngredientSuggestions = [];
  List<Recipe> _searchResults = [];
  bool _isLoading = false;
  bool _isFetchingMore = false;
  String? _errorMessage;
  String _currentSortOption = 'relevance'; // Für Text-basierte Suche
  int _offset = 0;
  final int _number = 10;
  bool _hasMore = true;
  Timer? _debounceTimer;
  final Duration _debounceDuration = const Duration(milliseconds: 400);
  final Map<String, bool> _imageAvailabilityCache = {};

  // Parameter für die maximale Anzahl fehlender Zutaten (relevant für Zutatensuche)
  int _maxMissingIngredients = 2; // Standardwert, kann angepasst werden


  // --- Getters to expose state to UI ---
  String get query => _query;
  List<Ingredient> get selectedIngredients => _selectedIngredients;
  List<Ingredient> get filteredIngredientSuggestions => _filteredIngredientSuggestions;
  List<Recipe> get searchResults => _searchResults;
  bool get isLoading => _isLoading;
  bool get isFetchingMore => _isFetchingMore;
  String? get errorMessage => _errorMessage;
  String get currentSortOption => _currentSortOption;
  bool get hasMore => _hasMore;
  Map<String, bool> get imageAvailabilityCache => _imageAvailabilityCache;
  int get maxMissingIngredients => _maxMissingIngredients;

  // --- Init and Dispose Logic ---
  void initializeSearch(List<Ingredient> initialSelectedIngredients) {
    if (initialSelectedIngredients.isNotEmpty) {
      _selectedIngredients.addAll(initialSelectedIngredients.where((i) => !_selectedIngredients.contains(i)));
    }
    _updateCacheForIngredients(_selectedIngredients);
    // Initialisiere die Suche basierend auf aktuellem Zustand (Query oder Zutaten)
    _performSearch(isInitialLoad: true);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  // --- Business Logic Methods ---
  void _updateCacheForIngredients(List<Ingredient> ingredients) {
    for (final ingredient in ingredients) {
      final imageUrl = ingredient.imageUrl;
      if (imageUrl != null && imageUrl.startsWith('assets/') && !_imageAvailabilityCache.containsKey(imageUrl)) {
        _canLoadImage(imageUrl).then((result) {
          if (hasListeners) {
            _imageAvailabilityCache[imageUrl] = result;
          }
        });
        _imageAvailabilityCache[imageUrl] = false;
      }
    }
  }

  Future<bool> _canLoadImage(String? path) async {
    if (path == null || !path.startsWith('assets/')) return false;
    try {
      await rootBundle.load(path);
      return true;
    } catch (_) {
      return false;
    }
  }

  void _updateFilteredSuggestions() {
    _filteredIngredientSuggestions = filterBySimilarity<Ingredient>(
      allIngredients.where((i) => !_selectedIngredients.contains(i)).toList(),
      (i) => i.name,
      _query,
      threshold: 0.3,
    );
    _updateCacheForIngredients([..._selectedIngredients, ..._filteredIngredientSuggestions]);
    notifyListeners();
  }

  void toggleIngredient(Ingredient ingredient) {
    if (_selectedIngredients.contains(ingredient)) {
      _selectedIngredients.remove(ingredient);
    } else {
      _selectedIngredients.add(ingredient);
      // Wenn eine Zutat hinzugefügt wird, sollte der Text-Query nicht gelöscht werden,
      // wenn wir eine kombinierte Suche anstreben.
      _query = ''; // Diese Zeile wurde entfernt oder auskommentiert
      _filteredIngredientSuggestions = [];
    }
    _performSearch(isInitialLoad: true);
    notifyListeners();
  }

  void onSearchChanged(String value) {
    _query = value;
    // **WICHTIG:** Die problematische Zeile, die _selectedIngredients gelöscht hat, wurde entfernt.
    // Das bedeutet, dass _selectedIngredients IMMER bestehen bleiben, wenn der Benutzer einen Query eingibt.
    // Die Priorisierung der Suche erfolgt jetzt ausschließlich in _performSearch.

    _updateFilteredSuggestions();

    _debounceTimer?.cancel();
    _debounceTimer = Timer(_debounceDuration, () {

      if (_selectedIngredients.isEmpty) {
        _performSearch(isInitialLoad: true);

      }
    });
    notifyListeners();
  }

  void setMaxMissingIngredients(int value) {
    if (_maxMissingIngredients != value) {
      _maxMissingIngredients = value;
      notifyListeners();
      // Löse eine neue Suche aus, wenn sich der Wert ändert und Zutaten ausgewählt sind
      if (_selectedIngredients.isNotEmpty) {
        _performSearch(isInitialLoad: true);
      }
    }
  }

  /// Führt die eigentliche Suche basierend auf dem aktuellen Zustand (Query vs. Zutaten) durch.
  /// Priorisiert Zutatensuche, wenn selectedIngredients vorhanden sind.
  /// Andernfalls wird eine Query-Suche durchgeführt (sofern ein Query vorhanden ist).
  Future<void> _performSearch({bool isInitialLoad = false}) async {
    final bool hasQuery = _query.isNotEmpty;
    final bool hasIngredients = _selectedIngredients.isNotEmpty;

    if (!hasQuery && !hasIngredients) {
      // Keine Suchkriterien, Ergebnisse leeren und Zustand zurücksetzen
      _searchResults = [];
      _errorMessage = null;
      _isLoading = false;
      _isFetchingMore = false;
      _offset = 0;
      _hasMore = true;
      notifyListeners();
      return;
    }

    if (isInitialLoad) {
      _isLoading = true;
      _errorMessage = null;
      _searchResults = [];
      _offset = 0;
      _hasMore = true;
      notifyListeners();
    } else {
      _isFetchingMore = true;
      _errorMessage = null;
      notifyListeners();
    }

    try {
      List<Recipe> results = [];

      // **Logik zur Priorisierung:**
      // Wenn Zutaten ausgewählt sind, führe die Zutatensuche durch.
      // Andernfalls, wenn ein Query vorhanden ist, führe die Query-Suche durch.
      // (Beachte: Die Backend-Endpunkte unterstützen keine direkte Kombination aus Query UND Ingredients in einem Request)
      if (hasIngredients) {
        // --- Zutatensuche durchführen ---
        debugPrint('Performing ingredient search with: ${_selectedIngredients.map((i) => i.name).toList()}');
        results = await _searchRecipesByIngredientsUsecase.call(
          ingredients: _selectedIngredients.map((i) => i.name).toList(), // Namen als String-Liste übergeben
          offset: _offset,
          number: _number,
          maxMissingIngredients: _maxMissingIngredients,
        );
        // Hinweis: sortBy/sortDirection ist hier nicht anwendbar, da Spoonacular findByIngredients diese nicht unterstützt.
        // Falls Sortierung dennoch gewünscht, müsste dies client-seitig erfolgen oder ein separater API-Endpunkt im Backend.
      } else if (hasQuery) {
        // --- Query-Suche durchführen (wenn keine Zutaten ausgewählt sind) ---
        debugPrint('Performing query search with: $_query');
        String? sortBy;
        String? sortDirection;
        if (_currentSortOption != 'relevance') {
          final parts = _currentSortOption.split('_');
          sortBy = parts[0];
          sortDirection = parts[1];
        }
        results = await _searchRecipesByQueryUsecase.call(
          query: _query,
          offset: _offset,
          number: _number,
          sortBy: sortBy,
          sortDirection: sortDirection,
          // filters: filters, // Falls Sie filters im Notifier verwenden, hier hinzufügen
        );
      } else {
        debugPrint('No valid search criteria (query or ingredients) provided.');
      }

      if (isInitialLoad) {
        _searchResults = results;
      } else {
        _searchResults.addAll(results);
      }

      _isLoading = false;
      _isFetchingMore = false;
      _hasMore = results.length == _number; // Annahme: _number ist die volle Seitenlänge
      if (isInitialLoad && results.isEmpty) {
        _hasMore = false; // Wenn keine Ergebnisse beim ersten Laden, gibt es auch keine weiteren
      }
      notifyListeners();
    } on Failure catch (e) { // Fängt die benutzerdefinierten Failure-Typen
      _errorMessage = e.message;
      _isLoading = false;
      _isFetchingMore = false;
      notifyListeners();
      debugPrint('Error during recipe search: ${e.toString()}');
    } catch (e) {
      _errorMessage = 'Ein unerwarteter Fehler ist aufgetreten: ${e.toString()}';
      _isLoading = false;
      _isFetchingMore = false;
      notifyListeners();
      debugPrint('Unexpected error during recipe search: $e');
    }
  }

  Future<void> loadMoreRecipes() async {
    if (_isFetchingMore || !_hasMore) return;

    _offset += _number;
    await _performSearch(isInitialLoad: false);
  }

  void onSortOptionSelected(String selectedOption) {
    _currentSortOption = selectedOption;
    // Sortierung nur auslösen, wenn eine Textsuche aktiv ist, da Zutatensuche dies nicht unterstützt
    if (_query.isNotEmpty) {
      _performSearch(isInitialLoad: true);
    } else {
      debugPrint('Sort option changed, but not applied because no query is active.');
      // Optional: Client-seitige Sortierung, falls für Zutatensuche gewünscht
    }
    notifyListeners();
  }
}