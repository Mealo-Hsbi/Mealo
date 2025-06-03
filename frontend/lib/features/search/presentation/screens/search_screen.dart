// lib/features/search/presentation/screens/search_screen.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/features/recipeList/parallax_recipes.dart';
import 'package:frontend/features/search/data/repository/recipe_repository_impl.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';

// Imports for models and data
import 'package:frontend/common/data/ingredients.dart';
import 'package:frontend/common/models/ingredient.dart';
import 'package:frontend/common/models/recipe.dart';

// Imports for widgets
import 'package:frontend/common/widgets/ingredientChips/ingredient_chip_row.dart';
import 'package:frontend/common/widgets/search/search_header.dart';

// Imports for architecture components
import 'package:frontend/services/api_client.dart';
import 'package:frontend/features/search/data/datasources/recipe_api_data_source.dart';
import 'package:frontend/features/search/domain/repositories/recipe_repository.dart';
import 'package:frontend/features/search/domain/usecases/search_recipes.dart';

// Provider
import 'package:frontend/providers/selected_ingredients_provider.dart';

// Imports for String-Similarity
import 'package:frontend/common/utils/string_similarity_helper.dart';


class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String query = '';
  List<Ingredient> selectedIngredients = [];
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _searchController = TextEditingController();
  final Map<String, bool> _imageAvailabilityCache = {};
  List<Ingredient> filteredIngredientSuggestions = [];

  final ScrollController _scrollController = ScrollController();

  late SearchRecipes _searchRecipesUsecase;

  List<Recipe> _searchResults = [];
  bool _isLoading = false;
  bool _isFetchingMore = false;
  String? _errorMessage;

  Timer? _debounceTimer;
  final Duration _debounceDuration = const Duration(milliseconds: 400);

  int _offset = 0;
  final int _number = 10;
  bool _hasMore = true;

  // NEU: Definition der Sortieroptionen
  // Key: Interner Wert für die Logik/Backend
  // Value: Map mit 'name' (Anzeige) und 'icon'
  final Map<String, Map<String, dynamic>> _sortOptions = {
    'relevance': {'name': 'Relevance', 'icon': Icons.sort},
    'name_asc': {'name': 'Name (A-Z)', 'icon': Icons.sort_by_alpha},
    'name_desc': {'name': 'Name (Z-A)', 'icon': Icons.sort_by_alpha},
    'readyInMinutes_asc': {'name': 'Preparation Time (shortest first)', 'icon': Icons.access_time},
    'readyInMinutes_desc': {'name': 'Preparation Time (longest first)', 'icon': Icons.access_time},
    // 'matchingIngredients_desc': {'name': 'Matching Ingredients (most first)', 'icon': Icons.check_circle_outline}, // Für später
    // 'rating_desc': {'name': 'Rating (highest first)', 'icon': Icons.star}, // Für später
  };

  // NEU: Aktuell ausgewählte Sortieroption
  String _currentSortOption = 'relevance'; // Standard-Sortierung

  @override
  void initState() {
    super.initState();

    final ApiClient apiClient = ApiClient();
    final RecipeApiDataSource recipeApiDataSource = RecipeApiDataSourceImpl(apiClient);
    final RecipeRepository recipeRepository = RecipeRepositoryImpl(recipeApiDataSource);
    _searchRecipesUsecase = SearchRecipes(recipeRepository);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();

      final selectedIngredientsProvider = context.read<SelectedIngredientsProvider>();
      final ingredientsFromProvider = selectedIngredientsProvider.ingredients;

      if (ingredientsFromProvider.isNotEmpty) {
        setState(() {
          for (var ingredient in ingredientsFromProvider) {
            if (!selectedIngredients.contains(ingredient)) {
              selectedIngredients.add(ingredient);
            }
          }
        });
        selectedIngredientsProvider.clearIngredients();
      }

      _updateCacheForIngredients(selectedIngredients);
      _performSearch(isInitialLoad: true);
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent &&
          !_isLoading && !_isFetchingMore && _hasMore) {
        _loadMoreRecipes();
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _searchController.dispose();
    _debounceTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _updateCacheForIngredients(List<Ingredient> ingredients) {
    for (final ingredient in ingredients) {
      final imageUrl = ingredient.imageUrl;
      if (imageUrl != null && imageUrl.startsWith('assets/') && !_imageAvailabilityCache.containsKey(imageUrl)) {
        _canLoadImage(imageUrl).then((result) {
          if (mounted) {
            setState(() {
              _imageAvailabilityCache[imageUrl] = result;
            });
          }
        });
        _imageAvailabilityCache[imageUrl] = false;
      }
    }
  }

  void _updateFilteredSuggestions() {
    filteredIngredientSuggestions = filterBySimilarity<Ingredient>(
      allIngredients.where((i) => !selectedIngredients.contains(i)).toList(),
      (i) => i.name,
      query,
      threshold: 0.3,
    );
    _updateCacheForIngredients([...selectedIngredients, ...filteredIngredientSuggestions]);
  }

  void toggleIngredient(Ingredient ingredient) {
    setState(() {
      bool isAdding = !selectedIngredients.contains(ingredient);

      if (isAdding) {
        selectedIngredients.add(ingredient);
        _searchController.clear();
        query = '';
        filteredIngredientSuggestions = [];
      } else {
        selectedIngredients.remove(ingredient);
      }
      _performSearch(isInitialLoad: true);
    });
  }

  void _onSearchChanged(String value) {
    setState(() {
      query = value;
      _updateFilteredSuggestions();
    });

    _debounceTimer?.cancel();
    _debounceTimer = Timer(_debounceDuration, () {
      _performSearch(isInitialLoad: true);
    });
  }

  Future<void> _performSearch({bool isInitialLoad = false}) async {
    if (isInitialLoad) {
      if (query.isEmpty && selectedIngredients.isEmpty) {
        setState(() {
          _searchResults = [];
          _errorMessage = null;
          _isLoading = false;
          _isFetchingMore = false;
          _offset = 0;
          _hasMore = true;
        });
        return;
      }

      setState(() {
        _isLoading = true;
        _errorMessage = null;
        _searchResults = [];
        _offset = 0;
        _hasMore = true;
      });
    } else {
      setState(() {
        _isFetchingMore = true;
        _errorMessage = null;
      });
    }

    // NEU: Sortierparameter extrahieren
    String? sortBy;
    String? sortDirection;
    if (_currentSortOption != 'relevance') {
      final parts = _currentSortOption.split('_');
      sortBy = parts[0];
      sortDirection = parts[1];
    }

    try {
      final results = await _searchRecipesUsecase.call(
        query: query,
        selectedIngredients: selectedIngredients,
        offset: _offset,
        number: _number,
        sortBy: sortBy, // NEU: Sortierparameter übergeben
        sortDirection: sortDirection, // NEU: Sortierparameter übergeben
      );

      setState(() {
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
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error fetching recipes: ${e.toString()}';
        _isLoading = false;
        _isFetchingMore = false;
      });
      print('Error during recipe search: $e');
    }
  }

  Future<void> _loadMoreRecipes() async {
    if (_isFetchingMore || !_hasMore) return;

    setState(() {
      _offset += _number;
    });

    await _performSearch(isInitialLoad: false);
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

  // NEU: Methode zum Anzeigen der Sortieroptionen als ModalBottomSheet
  void _showSortOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Column( // Column statt Wrap für bessere Kontrolle und Scrollbarkeit
            mainAxisSize: MainAxisSize.min, // Wichtig: Größe an Inhalt anpassen
            children: _sortOptions.entries.map((entry) {
              final optionKey = entry.key;
              final optionData = entry.value;
              final optionName = optionData['name'] as String;
              final optionIcon = optionData['icon'] as IconData;

              return ListTile(
                leading: Icon(optionIcon),
                title: Text(
                  optionName,
                  style: TextStyle(
                    fontWeight: _currentSortOption == optionKey ? FontWeight.bold : FontWeight.normal,
                    color: _currentSortOption == optionKey ? Theme.of(context).primaryColor : null,
                  ),
                ),
                trailing: _currentSortOption == optionKey
                    ? Icon(Icons.check, color: Theme.of(context).primaryColor)
                    : null,
                onTap: () {
                  setState(() {
                    _currentSortOption = optionKey;
                  });
                  Navigator.pop(context); // BottomSheet schließen
                  _performSearch(isInitialLoad: true); // Neue Suche mit Sortierung
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  // NEU: Hilfsmethode, um das richtige Icon für die Sortierung zu bekommen
  IconData _getSortIcon() {
    final optionData = _sortOptions[_currentSortOption];
    if (optionData != null && optionData.containsKey('icon')) {
      return optionData['icon'] as IconData;
    }
    return Icons.sort; // Standard-Icon, falls nichts gefunden wird
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Column(
        children: [
          SearchHeader(
            controller: _searchController,
            focusNode: _focusNode,
            onChanged: _onSearchChanged,
            trailingAction: IconButton(
              icon: Icon(_getSortIcon()), // Dynamisches Icon
              onPressed: () {
                _showSortOptions(context);
              },
            ),
          ),

          if (selectedIngredients.isNotEmpty)
            IngredientChipScroller(
              ingredients: selectedIngredients,
              selected: true,
              onTap: toggleIngredient,
              theme: theme,
              imageAvailabilityCache: _imageAvailabilityCache,
              showBackground: true,
            ),

          if (filteredIngredientSuggestions.isNotEmpty && query.isNotEmpty)
            IngredientChipScroller(
              ingredients: filteredIngredientSuggestions,
              selected: false,
              onTap: toggleIngredient,
              theme: Theme.of(context),
              imageAvailabilityCache: _imageAvailabilityCache,
            ),

          Expanded(
            child: _isLoading && _searchResults.isEmpty && query.isEmpty && selectedIngredients.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? Center(child: Text(_errorMessage!, textAlign: TextAlign.center))
                    : _searchResults.isEmpty && !_isLoading && query.isEmpty && selectedIngredients.isEmpty
                        ? const Center(
                            child: Text(
                              'Start searching for recipes or select ingredients.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey),
                            ),
                          )
                        : _searchResults.isEmpty && !_isLoading && (query.isNotEmpty || selectedIngredients.isNotEmpty)
                            ? const Center(
                                child: Text(
                                  'No recipes found. Try different terms or ingredients.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.grey),
                                ),
                              )
                            : ListView.builder(
                                controller: _scrollController,
                                itemCount: _searchResults.length + (_hasMore ? 1 : 0),
                                itemBuilder: (context, index) {
                                  if (index == _searchResults.length) {
                                    return _isFetchingMore
                                        ? const Center(child: Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: CircularProgressIndicator(),
                                          ))
                                        : const SizedBox.shrink();
                                  }
                                  final recipe = _searchResults[index];
                                  return RecipeItem(
                                    imageUrl: recipe.imageUrl,
                                    name: recipe.name,
                                    country: recipe.place ?? '',
                                    readyInMinutes: recipe.readyInMinutes,
                                    servings: recipe.servings, // Stelle sicher, dass servings auch im RecipeModel/Recipe ist
                                  );
                                },
                              ),
          ),
        ],
      ),
    );
  }
}