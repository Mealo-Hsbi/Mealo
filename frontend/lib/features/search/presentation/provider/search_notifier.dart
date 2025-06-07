// lib/features/search/presentation/provider/search_notifier.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Für rootBundle

import 'package:frontend/common/data/ingredients.dart';
import 'package:frontend/common/models/ingredient.dart';
import 'package:frontend/common/models/recipe.dart';
import 'package:frontend/features/search/domain/usecases/search_recipes.dart';
import 'package:frontend/common/utils/string_similarity_helper.dart';

class SearchNotifier extends ChangeNotifier {
  final SearchRecipes _searchRecipesUsecase;

  SearchNotifier(this._searchRecipesUsecase);

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
  Map<String, bool> get imageAvailabilityCache => _imageAvailabilityCache; // Expose cache


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
          if (hasListeners) { // Check if there are listeners before updating
            _imageAvailabilityCache[imageUrl] = result;
            // No need to call notifyListeners() for each individual image,
            // as this is a background cache. The UI will request images as needed.
          }
        });
        _imageAvailabilityCache[imageUrl] = false; // Mark as potentially unavailable until checked
      }
    }
  }

  // NOTE: This should probably be moved to a more generic Utility class
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
    notifyListeners(); // Notify UI about suggestion changes
  }

  void toggleIngredient(Ingredient ingredient) {
    if (_selectedIngredients.contains(ingredient)) {
      _selectedIngredients.remove(ingredient);
    } else {
      _selectedIngredients.add(ingredient);
      _query = ''; // Clear query on ingredient selection
      _filteredIngredientSuggestions = []; // Clear suggestions
    }
    _performSearch(isInitialLoad: true);
    notifyListeners(); // Notify UI about selected ingredients change
  }

  void onSearchChanged(String value) {
    _query = value;
    _updateFilteredSuggestions(); // Update filtered suggestions immediately

    _debounceTimer?.cancel();
    _debounceTimer = Timer(_debounceDuration, () {
      _performSearch(isInitialLoad: true); // Perform actual search after debounce
    });
    notifyListeners(); // Notify UI about query change
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
        selectedIngredients: _selectedIngredients,
        offset: _offset,
        number: _number,
        sortBy: sortBy,
        sortDirection: sortDirection,
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
    } catch (e) {
      _errorMessage = 'Error fetching recipes: ${e.toString()}';
      _isLoading = false;
      _isFetchingMore = false;
      notifyListeners();
      debugPrint('Error during recipe search: $e'); // Use debugPrint for console output
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