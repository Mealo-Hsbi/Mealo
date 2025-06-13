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

  /// **NEU:** Gibt an, ob erweiterte Sortieroptionen (wie Nährwerte) verfügbar sind.
  /// Dies ist nur der Fall, wenn keine Zutaten ausgewählt sind und ein Suchbegriff vorhanden ist,
  /// da nur die Textsuche diese Sortierung über die Spoonacular API unterstützt.
  bool get isAdvancedSortingAvailable => _selectedIngredients.isEmpty && _query.isNotEmpty;

  // --- Init and Dispose Logic ---
  void initializeSearch(List<Ingredient> initialSelectedIngredients) {
    if (initialSelectedIngredients.isNotEmpty) {
      _selectedIngredients.addAll(initialSelectedIngredients.where((i) => !_selectedIngredients.contains(i)));
    }
    _updateCacheForIngredients(_selectedIngredients);
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

  void resetSearchState() {
    _query = '';
    _selectedIngredients = [];
    _filteredIngredientSuggestions = [];
    _searchResults = [];
    _isLoading = false;
    _isFetchingMore = false;
    _errorMessage = null;
    _currentSortOption = 'relevance'; // Zurücksetzen auf Standardwert
    _offset = 0;
    _hasMore = true;
    _debounceTimer?.cancel(); // Sicherstellen, dass der Timer auch abgebrochen wird
    _imageAvailabilityCache.clear(); // Cache leeren
    notifyListeners();
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
      _query = ''; // Diese Zeile wurde entfernt oder auskommentiert, damit Query bestehen bleibt
      _filteredIngredientSuggestions = [];
    }
    _performSearch(isInitialLoad: true);
    notifyListeners();
  }

  void onSearchChanged(String value) {
    _query = value;

    _updateFilteredSuggestions();

    _debounceTimer?.cancel();
    _debounceTimer = Timer(_debounceDuration, () {
      // Suche nur auslösen, wenn tatsächlich Kriterien vorhanden sind (Query oder Zutaten)
      if (_query.isNotEmpty || _selectedIngredients.isNotEmpty) {
        _performSearch(isInitialLoad: true);
      } else {
        // Wenn keine Kriterien, UI zurücksetzen (Leere Ergebnisse, keine Ladeanzeige)
        _searchResults = [];
        _errorMessage = null;
        _isLoading = false;
        _isFetchingMore = false;
        _offset = 0;
        _hasMore = true;
        notifyListeners();
      }
    });
    notifyListeners();
  }

  void setMaxMissingIngredients(int value) {
    if (_maxMissingIngredients != value) {
      _maxMissingIngredients = value;
      notifyListeners();
      if (_selectedIngredients.isNotEmpty) {
        _performSearch(isInitialLoad: true);
      }
    }
  }

  Future<void> refreshSearch() async {
    _offset = 0;
    _hasMore = true;
    await _performSearch(isInitialLoad: true);
  }

  /// Führt die eigentliche Suche basierend auf dem aktuellen Zustand (Query vs. Zutaten) durch.
  /// Priorisiert Zutatensuche, wenn selectedIngredients vorhanden sind.
  /// Andernfalls wird eine Query-Suche durchgeführt (sofern ein Query vorhanden ist).
  Future<void> _performSearch({bool isInitialLoad = false}) async {
    final bool hasQuery = _query.isNotEmpty;
    final bool hasIngredients = _selectedIngredients.isNotEmpty;

    if (!hasQuery && !hasIngredients) {
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

      // Logik zur Priorisierung der Suche:
      // Wenn Zutaten ausgewählt sind, führe die Zutatensuche durch.
      // Andernfalls, wenn ein Query vorhanden ist, führe die Query-Suche durch.
      if (hasIngredients) {
        debugPrint('Performing ingredient search with: ${_selectedIngredients.map((i) => i.name).toList()}');
        results = await _searchRecipesByIngredientsUsecase.call(
          ingredients: _selectedIngredients.map((i) => i.name).toList(),
          offset: _offset,
          number: _number,
          maxMissingIngredients: _maxMissingIngredients,
        );
        // HINWEIS: sortBy/sortDirection ist hier nicht anwendbar, da Spoonacular findByIngredients diese nicht unterstützt.
      } else if (hasQuery) {
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
      _hasMore = results.length == _number;
      if (isInitialLoad && results.isEmpty) {
        _hasMore = false;
      }
      notifyListeners();
    } on Failure catch (e) {
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

  /// Ändert die Sortieroption und löst eine neue Suche aus, wenn die erweiterte Sortierung verfügbar ist.
  void onSortOptionSelected(String selectedOption) {
    _currentSortOption = selectedOption;
    // Sortierung nur auslösen, wenn erweiterte Sortierung verfügbar ist (d.h. Textsuche aktiv)
    if (isAdvancedSortingAvailable) { // Verwende den neuen Getter
      _performSearch(isInitialLoad: true);
    } else {
      debugPrint('Sort option changed, but not applied because advanced sorting is not available for current search type.');
    }
    notifyListeners();
  }
}