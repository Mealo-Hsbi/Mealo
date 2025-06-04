// lib/features/search/presentation/screens/search_screen.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/features/recipeList/parallax_recipes.dart'; // KEEP THIS IMPORT
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
import 'package:frontend/features/search/presentation/widgets/sort_options_bottom_sheet.dart';


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

  final ScrollController _scrollController = ScrollController(); // Keep this controller

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
        sortBy: sortBy,
        sortDirection: sortDirection,
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

  void _onSortOptionSelected(String selectedOption) {
    setState(() {
      _currentSortOption = selectedOption;
    });
    _performSearch(isInitialLoad: true);
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
              icon: Icon(SortOptionsBottomSheet.getSortIcon(_currentSortOption)),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  builder: (BuildContext bc) {
                    return SortOptionsBottomSheet(
                      currentSortOption: _currentSortOption,
                      onOptionSelected: _onSortOptionSelected,
                    );
                  },
                );
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
                            // Revert to using ParallaxRecipes here, but pass the scroll controller
                            : ParallaxRecipes(
                                recipes: _searchResults,
                                currentSortOption: _currentSortOption,
                                scrollController: _scrollController, // PASS THE SCROLL CONTROLLER
                                isLoadingMore: _isFetchingMore, // Pass loading state for the footer
                                hasMore: _hasMore, // Pass hasMore state for the footer
                              ),
          ),
        ],
      ),
    );
  }
}