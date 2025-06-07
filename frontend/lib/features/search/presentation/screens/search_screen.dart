// lib/features/search/presentation/screens/search_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/common/widgets/ingredientChips/ingredient_chip_row.dart';
import 'package:frontend/common/widgets/search/search_header.dart';
import 'package:frontend/features/search/presentation/widgets/sort_options_bottom_sheet.dart';
import 'package:frontend/features/recipeList/parallax_recipes.dart'; // RecipeItem ist hier definiert
import 'package:frontend/providers/selected_ingredients_provider.dart';
import 'package:frontend/features/search/presentation/provider/search_notifier.dart'; // NEU: Importiere den Notifier

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();

      // Hole den SearchNotifier über Provider.of oder Provider.read
      final searchNotifier = Provider.of<SearchNotifier>(context, listen: false);
      final selectedIngredientsProvider = Provider.of<SelectedIngredientsProvider>(context, listen: false);
      
      // Initialisiere den SearchNotifier mit den eventuell vorhandenen Zutaten aus dem Provider
      searchNotifier.initializeSearch(selectedIngredientsProvider.ingredients);

      // Leere die Zutaten im SelectedIngredientsProvider, da sie jetzt vom SearchNotifier verwaltet werden
      selectedIngredientsProvider.clearIngredients();
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        // Rufe die Methode zum Laden weiterer Rezepte über den Notifier auf
        Provider.of<SearchNotifier>(context, listen: false).loadMoreRecipes();
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    // Der SearchNotifier wird automatisch von Provider disposed, wenn der Widget-Tree entfernt wird.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Watch (listen) for changes in SearchNotifier
    return Consumer<SearchNotifier>(
      builder: (context, searchNotifier, child) {
        // Den TextEditingController mit dem Query des Notifiers synchronisieren
        // Vermeiden Sie, dass der Controller neu gesetzt wird, wenn es keine Änderung gab,
        // um unerwünschte Cursor-Positionen zu vermeiden.
        if (_searchController.text != searchNotifier.query) {
          _searchController.text = searchNotifier.query;
          _searchController.selection = TextSelection.fromPosition(
            TextPosition(offset: _searchController.text.length),
          );
        }

        return Scaffold(
          body: Column(
            children: [
              SearchHeader(
                controller: _searchController,
                focusNode: _focusNode,
                onChanged: searchNotifier.onSearchChanged, // Methode vom Notifier
                trailingAction: IconButton(
                  icon: Icon(SortOptionsBottomSheet.getSortIcon(searchNotifier.currentSortOption)),
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (BuildContext bc) {
                        return SortOptionsBottomSheet(
                          currentSortOption: searchNotifier.currentSortOption,
                          onOptionSelected: searchNotifier.onSortOptionSelected, // Methode vom Notifier
                        );
                      },
                    );
                  },
                ),
              ),

              if (searchNotifier.selectedIngredients.isNotEmpty)
                IngredientChipScroller(
                  ingredients: searchNotifier.selectedIngredients,
                  selected: true,
                  onTap: searchNotifier.toggleIngredient, // Methode vom Notifier
                  theme: theme,
                  imageAvailabilityCache: searchNotifier.imageAvailabilityCache,
                  showBackground: true,
                ),

              if (searchNotifier.filteredIngredientSuggestions.isNotEmpty && searchNotifier.query.isNotEmpty)
                IngredientChipScroller(
                  ingredients: searchNotifier.filteredIngredientSuggestions,
                  selected: false,
                  onTap: searchNotifier.toggleIngredient, // Methode vom Notifier
                  theme: Theme.of(context),
                  imageAvailabilityCache: searchNotifier.imageAvailabilityCache,
                ),

              Expanded(
                child: Builder(
                  builder: (context) {
                    // Startzustand: Keine Suche, keine Zutaten
                    if (!searchNotifier.isLoading && searchNotifier.searchResults.isEmpty && searchNotifier.query.isEmpty && searchNotifier.selectedIngredients.isEmpty) {
                      return const Center(
                        child: Text(
                          'Start searching for recipes or select ingredients.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),
                      );
                    }
                    // Ladezustand (erste Suche)
                    if (searchNotifier.isLoading && searchNotifier.searchResults.isEmpty) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    // Fehlermeldung
                    if (searchNotifier.errorMessage != null) {
                      return Center(child: Text(searchNotifier.errorMessage!, textAlign: TextAlign.center));
                    }
                    // Keine Ergebnisse nach Suche
                    if (searchNotifier.searchResults.isEmpty && !searchNotifier.isLoading && (searchNotifier.query.isNotEmpty || searchNotifier.selectedIngredients.isNotEmpty)) {
                      return const Center(
                        child: Text(
                          'No recipes found. Try different terms or ingredients.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),
                      );
                    }
                    // Ergebnisse anzeigen
                    return ListView.builder(
                      controller: _scrollController,
                      itemCount: searchNotifier.searchResults.length + (searchNotifier.hasMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == searchNotifier.searchResults.length) {
                          return searchNotifier.isFetchingMore
                              ? const Center(child: Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: CircularProgressIndicator(),
                                ))
                              : const SizedBox.shrink();
                        }
                        final recipe = searchNotifier.searchResults[index];
                        return RecipeItem(
                          id: recipe.id,
                          imageUrl: recipe.imageUrl,
                          name: recipe.name,
                          country: recipe.place ?? '',
                          readyInMinutes: recipe.readyInMinutes,
                          servings: recipe.servings,
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}