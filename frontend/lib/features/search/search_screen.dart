import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/common/data/ingredients.dart';
import 'package:frontend/common/models/ingredient.dart';
import 'package:frontend/common/utils/string_similarity_helper.dart';
import 'package:frontend/common/widgets/ingredient_chip.dart';

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

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        body: Column(
          children: [
            Container(
              height: MediaQuery.of(context).padding.top,
              color: Colors.grey[200],
            ),
            Expanded(
              child: SafeArea(
                top: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      color: Colors.grey[200],
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TextField(
                          controller: _searchController,
                          focusNode: _focusNode,
                          decoration: const InputDecoration(
                            hintText: 'Search for recipes or ingredients...',
                            prefixIcon: Icon(Icons.search),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(vertical: 12),
                          ),
                          onChanged: _onSearchChanged,
                        ),
                      ),
                    ),

                    if (selectedIngredients.isNotEmpty)
                      Container(
                        color: Colors.grey[200],
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        // Scrollbare Zeile statt Wrap:
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              for (final ingredient in selectedIngredients)
                                Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: IngredientChip(
                                    ingredient: ingredient,
                                    selected: true,
                                    onTap: () => toggleIngredient(ingredient),
                                    theme: theme,
                                    showImage: _imageAvailabilityCache[ingredient.imageUrl ?? ''] ?? false,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),

                    if (filteredIngredientSuggestions.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: filteredIngredientSuggestions.map((ingredient) {
                            return IngredientChip(
                              ingredient: ingredient,
                              selected: false,
                              onTap: () => toggleIngredient(ingredient),
                              theme: theme,
                              showImage: _imageAvailabilityCache[ingredient.imageUrl ?? ''] ?? false,
                            );
                          }).toList(),
                        ),
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
              ),
            ),
          ],
        ),
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
