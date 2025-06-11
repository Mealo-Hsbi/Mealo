// lib/features/search/presentation/screens/search_screen.dart

import 'package:flutter/material.dart';
import 'package:frontend/features/recipeList/presentation/widgets/skeleton_item/recipe_list_skeleton_item.dart'; // Korrekter Import
import 'package:provider/provider.dart';
import 'package:frontend/common/widgets/ingredientChips/ingredient_chip_row.dart';
import 'package:frontend/common/widgets/search/search_header.dart';
import 'package:frontend/features/search/presentation/widgets/sort_options_bottom_sheet.dart';
import 'package:frontend/features/recipeList/parallax_recipes.dart';
import 'package:frontend/providers/selected_ingredients_provider.dart';
import 'package:frontend/features/search/presentation/provider/search_notifier.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // _itemExtent wird nur für die Skeleton-Items im Ladezustand benötigt.
  // Es wird nicht an ParallaxRecipes übergeben.
  double? _itemExtentForSkeleton;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();

      final searchNotifier = Provider.of<SearchNotifier>(context, listen: false);
      final selectedIngredientsProvider = Provider.of<SelectedIngredientsProvider>(context, listen: false);

      searchNotifier.initializeSearch(selectedIngredientsProvider.ingredients);

      selectedIngredientsProvider.clearIngredients();

      _calculateItemExtentForSkeleton(); // Berechne _itemExtentForSkeleton
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        Provider.of<SearchNotifier>(context, listen: false).loadMoreRecipes();
      }
    });
  }

  // Methode zur Berechnung von _itemExtentForSkeleton
  // Diese Berechnung sollte der Höhe eines einzelnen RecipeListSkeletonItem entsprechen.
  void _calculateItemExtentForSkeleton() {
    // Annahme: Ein RecipeListSkeletonItem hat einen festen Aspekt (z.B. 16:9 für das Bild)
    // und festen vertikalen Padding.
    // Dies ist eine Näherung, du müsstest die genauen Maße deines RecipeListSkeletonItem kennen.
    // Standard-Padding/Margin in ParallaxRecipes:
    final double horizontalListPadding = 24.0 * 2; // Annahme: Links und rechts 24px Padding
    final double verticalItemSpacing = 16.0; // Annahme: Vertikaler Abstand zwischen Items in ParallaxRecipes

    final double availableWidthForImage = MediaQuery.of(context).size.width - horizontalListPadding;
    // Wenn dein ParallaxRecipes die Bilder im Verhältnis 16:9 darstellt:
    final double imageHeight = availableWidthForImage * (9 / 16);

    // Die Gesamthöhe eines Listenelements setzt sich zusammen aus
    // der Bildhöhe, plus Titelfläche, plus alle internen Paddings und Margins.
    // Dies ist eine Schätzung, basierend auf typischen RecipeListSkeletonItem-Layouts.
    // Passen Sie diese Werte an die tatsächliche Struktur Ihres Skeleton-Items an.
    final double estimatedRecipeCardHeight = imageHeight + 80; // Beispiel: 80 für Text und Paddings

    setState(() {
      _itemExtentForSkeleton = estimatedRecipeCardHeight + verticalItemSpacing;
    });
  }


  @override
  void dispose() {
    _focusNode.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer<SearchNotifier>(
      builder: (context, searchNotifier, child) {
        if (_searchController.text != searchNotifier.query) {
          _searchController.text = searchNotifier.query;
          _searchController.selection = TextSelection.fromPosition(
            TextPosition(offset: _searchController.text.length),
          );
        }

        // NUTZE DEN NEUEN GETTER:
        final bool isSortOptionDisabled = !searchNotifier.isAdvancedSortingAvailable;

        return Scaffold(
          body: Column(
            children: [
              SearchHeader(
                controller: _searchController,
                focusNode: _focusNode,
                onChanged: searchNotifier.onSearchChanged,
                trailingAction: Tooltip(
                  message: isSortOptionDisabled
                    ? 'Advanced sorting (e.g., by nutritional values) is only available with text search.'
                    : 'Sort the recipes.',
                  // Tooltip-Text anpassen, wenn die Sortierung deaktiviert ist
                  child: IconButton(
                    icon: Icon(SortOptionsBottomSheet.getSortIcon(searchNotifier.currentSortOption)),
                    // onPressed ist null, wenn die Sortierung deaktiviert ist
                    onPressed: isSortOptionDisabled ? null : () {
                      showModalBottomSheet(
                        context: context,
                        builder: (BuildContext bc) {
                          return SortOptionsBottomSheet(
                            currentSortOption: searchNotifier.currentSortOption,
                            onOptionSelected: searchNotifier.onSortOptionSelected,
                          );
                        },
                      );
                    },
                  ),
                ),
              ),

              if (searchNotifier.selectedIngredients.isNotEmpty)
                IngredientChipScroller(
                  ingredients: searchNotifier.selectedIngredients,
                  selected: true,
                  onTap: searchNotifier.toggleIngredient,
                  theme: theme,
                  imageAvailabilityCache: searchNotifier.imageAvailabilityCache,
                  showBackground: true,
                ),

              if (searchNotifier.filteredIngredientSuggestions.isNotEmpty && searchNotifier.query.isNotEmpty)
                IngredientChipScroller(
                  ingredients: searchNotifier.filteredIngredientSuggestions,
                  selected: false,
                  onTap: searchNotifier.toggleIngredient,
                  theme: Theme.of(context),
                  imageAvailabilityCache: searchNotifier.imageAvailabilityCache,
                  showBackground: true,
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
                    // Ladezustand (erste Suche) - Zeigt jetzt Skeleton-Items
                    if (searchNotifier.isLoading && searchNotifier.searchResults.isEmpty) {
                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 0),
                        itemCount: 4, // Zeige z.B. 4 Skeleton-Items
                        itemExtent: _itemExtentForSkeleton, // Nutze den berechneten itemExtent für Skeleton
                        itemBuilder: (context, index) {
                          if (_itemExtentForSkeleton == null) {
                            // Fallback, falls _itemExtentForSkeleton noch nicht berechnet wurde
                            return const Center(child: CircularProgressIndicator());
                          }
                          return const RecipeSkeletonItem();
                        },
                      );
                    }
                    // Fehlermeldung
                    if (searchNotifier.errorMessage != null) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.error_outline, size: 48, color: Colors.red),
                              const SizedBox(height: 16),
                              Text(
                                searchNotifier.errorMessage!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 16, color: Colors.red),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () {
                                  // Erneute Suche auslösen
                                  searchNotifier.refreshSearch();
                                },
                                child: const Text('Erneut versuchen'),
                              ),
                            ],
                          ),
                        ),
                      );
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
                    // Ergebnisse anzeigen (ParallaxRecipes ist ein guter Wrapper für die ListView)
                    return ParallaxRecipes(
                      recipes: searchNotifier.searchResults,
                      scrollController: _scrollController,
                      isLoadingMore: searchNotifier.isFetchingMore,
                      hasMore: searchNotifier.hasMore,
                      currentSortOption: searchNotifier.currentSortOption,
                      // KEIN itemExtent hier übergeben!
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