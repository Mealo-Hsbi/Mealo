import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/common/data/ingredients.dart';
import 'package:frontend/common/models/ingredient.dart';
import 'package:frontend/common/utils/string_similarity_helper.dart';
import 'package:frontend/common/widgets/ingredientChips/ingredient_chip_row.dart';
import 'package:frontend/common/widgets/search/search_header.dart';

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

  void _updateCacheForIngredients(List<Ingredient> ingredients) {
    for (final ingredient in ingredients) {
      final imageUrl = ingredient.imageUrl;
      if (imageUrl != null && !_imageAvailabilityCache.containsKey(imageUrl)) {
        _canLoadImage(imageUrl).then((result) {
          if (mounted) {
            setState(() {
              _imageAvailabilityCache[imageUrl] = result;
            });
          }
        });
        _imageAvailabilityCache[imageUrl] = false; // vorerst nicht anzeigen
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
      if (selectedIngredients.contains(ingredient)) {
        selectedIngredients.remove(ingredient);
      } else {
        selectedIngredients.add(ingredient);
      }
    });

    _searchController.clear();

    filteredIngredientSuggestions = [];    
  }

  void _onSearchChanged(String value) {
    setState(() {
      query = value;

      _updateFilteredSuggestions();
      if (query.isEmpty) {
        filteredIngredientSuggestions = [];
      }
    });
  }


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _searchController.dispose();
    super.dispose();
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

          if (filteredIngredientSuggestions.isNotEmpty)
            IngredientChipScroller(
              ingredients: filteredIngredientSuggestions,
              selected: false,
              onTap: toggleIngredient,
              theme: Theme.of(context),
              imageAvailabilityCache: _imageAvailabilityCache,
            ),

          Expanded(
            child: query.isEmpty
                ? const Center(child: Text('Bitte etwas eingeben...'))
                : Center(
                    child: Text(
                      'Suche nach "$query"\n'
                      'Filter: ${selectedIngredients.map((i) => i.name).join(', ')}',
                      textAlign: TextAlign.center,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Future<bool> _canLoadImage(String? path) async {
    if (path == null) return false;
    try {
      await rootBundle.load(path);
      return true;
    } catch (_) {
      return false;
    }
  }
}
