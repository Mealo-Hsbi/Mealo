// lib/features/search/presentation/screens/search_screen.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/features/recipeList/parallax_recipes.dart';
import 'package:frontend/features/search/data/repository/recipe_repository_impl.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart'; // For Dio instance, if not globally managed

// Imports for models and data
import 'package:frontend/common/data/ingredients.dart';
import 'package:frontend/common/models/ingredient.dart';
import 'package:frontend/common/models/recipe.dart'; // Base Recipe Model

// Imports for widgets
import 'package:frontend/common/widgets/ingredientChips/ingredient_chip_row.dart';
import 'package:frontend/common/widgets/search/search_header.dart';

// Imports for architecture components
import 'package:frontend/services/api_client.dart'; // Your Dio ApiClient
import 'package:frontend/features/search/data/datasources/recipe_api_data_source.dart';
import 'package:frontend/features/search/domain/repositories/recipe_repository.dart'; // The abstract interface
import 'package:frontend/features/search/domain/usecases/search_recipes.dart'; // Your Usecase

// Provider
import 'package:frontend/providers/selected_ingredients_provider.dart';

// Imports for String-Similarity (existing)
import 'package:frontend/common/utils/string_similarity_helper.dart';

// TODO: Create this screen to display details
// import 'package:frontend/features/recipe_details/presentation/screens/recipe_detail_screen.dart';


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

  // NEW: ScrollController for pagination
  final ScrollController _scrollController = ScrollController();

  // Usecase for recipe search
  late SearchRecipes _searchRecipesUsecase;
  // TODO: Add a Usecase for fetching recipe details, e.g.
  // late GetRecipeDetails _getRecipeDetailsUsecase;

  List<Recipe> _searchResults = [];
  bool _isLoading = false;
  bool _isFetchingMore = false; // NEW: Flag to prevent multiple concurrent loadMore calls
  String? _errorMessage;

  Timer? _debounceTimer; // Debounce-Timer for the search input
  final Duration _debounceDuration = const Duration(milliseconds: 400); // 400ms debounce

  // NEW: Pagination state
  int _offset = 0; // Start index for fetching results
  final int _number = 10; // Number of recipes to fetch per request (items per page)
  bool _hasMore = true; // Flag to indicate if there are more results to load

  @override
  void initState() {
    super.initState();

    // Initialize architecture components
    final ApiClient apiClient = ApiClient();
    final RecipeApiDataSource recipeApiDataSource = RecipeApiDataSourceImpl(apiClient);
    final RecipeRepository recipeRepository = RecipeRepositoryImpl(recipeApiDataSource);
    _searchRecipesUsecase = SearchRecipes(recipeRepository);
    // _getRecipeDetailsUsecase = GetRecipeDetails(recipeRepository); // Initialize your detail usecase here

    // Add PostFrameCallback to set focus after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();

      // Read ingredients from the provider
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
        selectedIngredientsProvider.clearIngredients(); // Reset ingredients in the provider
      }

      _updateCacheForIngredients(selectedIngredients);

      // Perform an initial search if ingredients are already selected
      // or if the query is not empty (e.g., from a deep link or restoration)
      // Call _performSearch with isInitialLoad: true
      _performSearch(isInitialLoad: true);
    });

    // Add listener for scroll events
    _scrollController.addListener(() {
      // Check if user scrolled to the bottom AND not currently loading/fetching AND has more data
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
    _debounceTimer?.cancel(); // Cancel timer to prevent memory leaks
    _scrollController.dispose(); // Dispose scroll controller
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
        _imageAvailabilityCache[imageUrl] = false; // Don't show for now
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
      bool isAdding = !selectedIngredients.contains(ingredient); // Check if adding

      if (isAdding) {
        selectedIngredients.add(ingredient);
        _searchController.clear();
        query = '';
        filteredIngredientSuggestions = [];
      } else {
        selectedIngredients.remove(ingredient);
        // NEW: When removing, we keep the search query
        // This means _searchController.clear() and query = '' are NOT called.
      }
      
      // Regardless of adding or removing, perform a new search, resetting pagination
      _performSearch(isInitialLoad: true); 
    });
  }

  void _onSearchChanged(String value) {
    setState(() {
      query = value;
      _updateFilteredSuggestions();
    });

    // Cancel any existing timer to reset the debounce
    _debounceTimer?.cancel();
    // Start a new timer. The search will only execute if no new input comes within _debounceDuration.
    _debounceTimer = Timer(_debounceDuration, () {
      _performSearch(isInitialLoad: true); // Always perform a new search, resetting pagination
    });
  }

  // Method to execute the recipe search via the usecase
  // isInitialLoad is true for new searches (text input, ingredient toggle, initial load)
  // isInitialLoad is false for "load more" pagination calls
  Future<void> _performSearch({bool isInitialLoad = false}) async {
    // If it's an initial load, clear results and reset pagination state
    if (isInitialLoad) {
      // Don't execute if neither query nor ingredients are present and it's a fresh load
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
        _errorMessage = null; // Reset error before each new search
        _searchResults = []; // Clear results for a new search
        _offset = 0; // Reset offset
        _hasMore = true; // Assume there are more results for a new search
      });
    } else {
      // For load more, set fetching flag
      setState(() {
        _isFetchingMore = true;
        _errorMessage = null; // Clear error for subsequent fetch
      });
    }

    try {
      final results = await _searchRecipesUsecase.call(
        query: query,
        selectedIngredients: selectedIngredients,
        offset: _offset, // Pass offset
        number: _number, // Pass number of results (limit)
        // Filters and sorting can be added here later
        // filters: {'diet': 'vegetarian'},
        // sortBy: 'calories',
        // sortDirection: 'desc',
      );

      setState(() {
        if (isInitialLoad) {
          _searchResults = results; // Set results for initial load
        } else {
          _searchResults.addAll(results); // Add new results for lazy loading
        }
        
        _isLoading = false;
        _isFetchingMore = false;
        // Check if fewer results than requested, means no more data
        _hasMore = results.length == _number;
        // If results.length < _number, it means we've hit the end of the available recipes.
        // If results.length == 0 and it's an initial load, _hasMore should be false.
        if (isInitialLoad && results.isEmpty) {
          _hasMore = false;
        }
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error fetching recipes: ${e.toString()}'; // Updated error message
        _isLoading = false;
        _isFetchingMore = false;
      });
      print('Error during recipe search: $e'); // For debugging in the console
    }
  }

  // NEW: Method to load more recipes
  Future<void> _loadMoreRecipes() async {
    if (_isFetchingMore || !_hasMore) return; // Prevent multiple calls or if no more data

    setState(() {
      _offset += _number; // Increment offset before fetching
    });

    await _performSearch(isInitialLoad: false); // Fetch more results
  }

  // Helper method to check local image asset availability
  Future<bool> _canLoadImage(String? path) async {
    if (path == null || !path.startsWith('assets/')) return false; // Only check local assets
    try {
      await rootBundle.load(path);
      return true;
    } catch (_) {
      return false;
    }
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

          if (filteredIngredientSuggestions.isNotEmpty && query.isNotEmpty) // Only show if query is not empty
            IngredientChipScroller(
              ingredients: filteredIngredientSuggestions,
              selected: false,
              onTap: toggleIngredient,
              theme: Theme.of(context),
              imageAvailabilityCache: _imageAvailabilityCache,
            ),

          // Display search results or loading/error states
          Expanded(
            child: _isLoading && _searchResults.isEmpty && query.isEmpty && selectedIngredients.isEmpty // Only show full screen loader on initial empty search
                ? const Center(child: CircularProgressIndicator()) // Loading indicator
                : _errorMessage != null
                    ? Center(child: Text(_errorMessage!, textAlign: TextAlign.center)) // Error message
                    : _searchResults.isEmpty && !_isLoading && query.isEmpty && selectedIngredients.isEmpty
                        ? const Center(
                            child: Text(
                              'Start searching for recipes or select ingredients.', // Initial empty state text
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey),
                            ),
                          )
                        : _searchResults.isEmpty && !_isLoading && (query.isNotEmpty || selectedIngredients.isNotEmpty)
                            ? const Center(
                                child: Text(
                                  'No recipes found. Try different terms or ingredients.', // No results text for active search
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.grey),
                                ),
                              )
                            : ListView.builder(
                                controller: _scrollController, // Attach the ScrollController
                                // Add 1 to itemCount if there's potentially more data to show a loading indicator at the bottom
                                itemCount: _searchResults.length + (_hasMore ? 1 : 0),
                                itemBuilder: (context, index) {
                                  // If it's the last item and _hasMore is true, show the loading indicator
                                  if (index == _searchResults.length) {
                                    return _isFetchingMore
                                        ? const Center(child: Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: CircularProgressIndicator(),
                                          ))
                                        : const SizedBox.shrink(); // Hide indicator if no more data to fetch
                                  }
                                  final recipe = _searchResults[index];
                                  return RecipeItem(
                                    imageUrl: recipe.imageUrl,
                                    name: recipe.name,
                                    country: recipe.place ?? '', // Use recipe.place for country/origin
                                    readyInMinutes: recipe.readyInMinutes,
                                  );
                                },
                              ),
          ),
        ],
      ),
    );
  }
}