// lib/features/search/presentation/provider/search_notifier.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Für rootBundle

// Importe für Modelle und UseCase
import 'package:frontend/common/data/ingredients.dart'; // Für allIngredients
import 'package:frontend/common/models/ingredient.dart';
import 'package:frontend/common/models/recipe.dart';
import 'package:frontend/features/search/domain/usecases/search_recipes.dart';
import 'package:frontend/common/utils/string_similarity_helper.dart';
import 'package:frontend/core/error/failures.dart'; // NEU: Für Fehlerbehandlung

class SearchNotifier extends ChangeNotifier {
  // **Korrektur:** Benannter Parameter im Konstruktor
  final SearchRecipes _searchRecipesUsecase;

  // **Korrektur:** Konstruktor erwartet jetzt einen benannten Parameter
  SearchNotifier({required SearchRecipes searchRecipesUsecase})
      : _searchRecipesUsecase = searchRecipesUsecase;

  // --- State Variables ---
  String _query = '';
  List<Ingredient> _selectedIngredients = [];
  List<Ingredient> _filteredIngredientSuggestions = [];
  List<Recipe> _searchResults = [];
  bool _isLoading = false;
  bool _isFetchingMore = false;
  String? _errorMessage;
  String _currentSortOption = 'relevance';
  int _offset = 0;
  final int _number = 10;
  bool _hasMore = true;
  Timer? _debounceTimer;
  final Duration _debounceDuration = const Duration(milliseconds: 400);
  final Map<String, bool> _imageAvailabilityCache = {};

  // **NEU:** Parameter für die maximale Anzahl fehlender Zutaten
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

  // **NEU:** Getter für maxMissingIngredients
  int get maxMissingIngredients => _maxMissingIngredients;

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
      _query = '';
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
      _performSearch(isInitialLoad: true);
    });
    notifyListeners();
  }

  // **NEU:** Setter für maxMissingIngredients
  void setMaxMissingIngredients(int value) {
    if (_maxMissingIngredients != value) {
      _maxMissingIngredients = value;
      notifyListeners();
      // Optional: Löse eine neue Suche aus, wenn sich der Wert ändert
      _performSearch(isInitialLoad: true);
    }
  }

  Future<void> _performSearch({bool isInitialLoad = false}) async {
    if (isInitialLoad) {
      if (_query.isEmpty && _selectedIngredients.isEmpty) {
        _searchResults = [];
        _errorMessage = null;
        _isLoading = false;
        _isFetchingMore = false;
        _offset = 0;
        _hasMore = true;
        notifyListeners();
        return;
      }

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

    String? sortBy;
    String? sortDirection;
    if (_currentSortOption != 'relevance') {
      final parts = _currentSortOption.split('_');
      sortBy = parts[0];
      sortDirection = parts[1];
    }

    try {
      final results = await _searchRecipesUsecase.call(
        query: _query,
        // **Korrektur:** selectedIngredients als Liste von String-Namen übergeben
        ingredients: _selectedIngredients.map((i) => i.name).toList(),
        offset: _offset,
        number: _number,
        sortBy: sortBy,
        sortDirection: sortDirection,
        // **NEU:** maxMissingIngredients hier übergeben
        maxMissingIngredients: _maxMissingIngredients,
        // filters: filters, // Falls Sie filters im Notifier verwenden, hier hinzufügen
      );

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
    _performSearch(isInitialLoad: true);
    notifyListeners();
  }
}