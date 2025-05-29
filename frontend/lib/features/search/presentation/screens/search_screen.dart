// lib/features/search/presentation/screens/search_screen.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/features/recipeList/parallax_recipes.dart';
import 'package:frontend/features/search/data/repository/recipe_repository_impl.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart'; // Für die Dio Instanz, falls noch nicht global verwaltet

// Importe für Modelle und Daten
import 'package:frontend/common/data/ingredients.dart';
import 'package:frontend/common/models/ingredient.dart';
import 'package:frontend/common/models/recipe.dart'; // Basis-Rezept-Modell

// Importe für Widgets
import 'package:frontend/common/widgets/ingredientChips/ingredient_chip_row.dart';
import 'package:frontend/common/widgets/search/search_header.dart';

// Importe für Architektur-Komponenten (neu!)
import 'package:frontend/services/api_client.dart'; // Dein Dio ApiClient
import 'package:frontend/features/search/data/datasources/recipe_api_data_source.dart';
import 'package:frontend/features/search/domain/repositories/recipe_repository.dart'; // Das abstrakte Interface
import 'package:frontend/features/search/domain/usecases/search_recipes.dart'; // Dein Usecase

// Provider
import 'package:frontend/providers/selected_ingredients_provider.dart';

// Importe für String-Similarity (bestehend)
import 'package:frontend/common/utils/string_similarity_helper.dart';

// TODO: Erstelle diesen Screen, um die Details anzuzeigen
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

  // NEU: Usecase für die Rezeptsuche
  late SearchRecipes _searchRecipesUsecase;
  // TODO: Einen Usecase für das Abrufen der Rezeptdetails hinzufügen, z.B.
  // late GetRecipeDetails _getRecipeDetailsUsecase;

  List<Recipe> _searchResults = [];
  bool _isLoading = false;
  String? _errorMessage;

  Timer? _debounceTimer; // Debounce-Timer for the search input
  final Duration _debounceDuration = const Duration(milliseconds: 400); // 300ms debounce

  @override
  void initState() {
    super.initState();

    // Initialisiere die Architektur-Komponenten
    // Wichtig: In einer realen App würdest du ApiClient und Dio
    // wahrscheinlich zentral über einen DI-Container (z.B. get_it)
    // oder einen Provider verwalten und hier injizieren, anstatt direkt zu instanziieren.
    // Hier instanziieren wir sie direkt für Einfachheit im Beispiel:
    final ApiClient apiClient = ApiClient();
    final RecipeApiDataSource recipeApiDataSource = RecipeApiDataSource(apiClient);
    final RecipeRepository recipeRepository = RecipeRepositoryImpl(recipeApiDataSource);
    _searchRecipesUsecase = SearchRecipes(recipeRepository);
    // _getRecipeDetailsUsecase = GetRecipeDetails(recipeRepository); // Initialisiere deinen Detail-Usecase hier

    // Füge den PostFrameCallback hinzu, um nach dem ersten Frame den Fokus zu setzen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();

      // Zutaten aus dem Provider lesen
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
        selectedIngredientsProvider.clearIngredients(); // Zutaten im Provider zurücksetzen
      }

      _updateCacheForIngredients(selectedIngredients);

      // Führe eine initiale Suche aus, falls bereits Zutaten ausgewählt sind
      // oder wenn der Query nicht leer ist (z.B. bei einem Deep Link oder Wiederherstellung)
      if (selectedIngredients.isNotEmpty || query.isNotEmpty) {
        _performSearch();
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _searchController.dispose();
    _debounceTimer?.cancel(); // Timer abbrechen, um Speicherlecks zu vermeiden
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
      bool isAdding = !selectedIngredients.contains(ingredient); // Prüfen, ob hinzugefügt wird

      if (isAdding) {
        selectedIngredients.add(ingredient);
        _searchController.clear();
        query = '';
        filteredIngredientSuggestions = [];
      } else {
        selectedIngredients.remove(ingredient);
        // NEU: Beim Entfernen behalten wir den Such-Query
        // D.h., _searchController.clear() und query = '' werden NICHT aufgerufen.
      }
      
      // Unabhängig davon, ob hinzugefügt oder entfernt, führe eine neue Suche aus.
      _performSearch(); 
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
      _performSearch();
    });
  }

  // Methode zum Ausführen der Rezeptsuche über den Usecase
  Future<void> _performSearch() async {
    // Führe keine Suche aus, wenn weder ein Suchbegriff noch Zutaten vorhanden sind
    if (query.isEmpty && selectedIngredients.isEmpty) {
      setState(() {
        _searchResults = [];
        _errorMessage = null;
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null; // Vor jeder neuen Suche Fehler zurücksetzen
    });

    try {
      final results = await _searchRecipesUsecase.call(
        query: query,
        selectedIngredients: selectedIngredients,
        // Hier können später Filter und Sortierung hinzugefügt werden
        // filters: {'diet': 'vegetarian'},
        // sortBy: 'calories',
        // sortDirection: 'desc',
      );
      setState(() {
        _searchResults = results;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Fehler bei der Rezeptsuche: ${e.toString()}';
        _isLoading = false;
      });
      print('Error during recipe search: $e'); // Für Debugging in der Konsole
    }
  }

  // Hilfsmethode, um lokale Bildassets auf Verfügbarkeit zu prüfen
  Future<bool> _canLoadImage(String? path) async {
    if (path == null || !path.startsWith('assets/')) return false; // Nur lokale Assets prüfen
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

          if (filteredIngredientSuggestions.isNotEmpty && query.isNotEmpty) // Nur anzeigen, wenn Query nicht leer
            IngredientChipScroller(
              ingredients: filteredIngredientSuggestions,
              selected: false,
              onTap: toggleIngredient,
              theme: Theme.of(context),
              imageAvailabilityCache: _imageAvailabilityCache,
            ),

          // Anzeige der Suchergebnisse oder Lade-/Fehlerzustände
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator()) // Ladeindikator
                : _errorMessage != null
                    ? Center(child: Text(_errorMessage!, textAlign: TextAlign.center)) // Fehlermeldung
                    : _searchResults.isEmpty
                        ? Center(
                            child: query.isEmpty && selectedIngredients.isEmpty
                                ? const Text(
                                    'Beginne mit der Suche nach Rezepten oder wähle Zutaten aus.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.grey),
                                  )
                                : const Text(
                                    'Keine Rezepte gefunden. Versuche es mit anderen Begriffen oder Zutaten.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.grey),
                                  ),
                          )
                        : 
                                                  ListView.builder(
                            // Wichtig: Verwende ParallaxFlowDelegate nur, wenn der
                            // Parallax-Effekt innerhalb der ListView funktionieren soll.
                            // Das kann komplex sein. Für den Anfang, wenn Parallax
                            // pro Element funktioniert, ist eine einfache ListView.builder ok.
                            // Wenn der Parallax-Effekt einen ScrollController braucht,
                            // müssen wir hier einen einfügen.
                            itemCount: _searchResults.length,
                            itemBuilder: (context, index) {
                              final recipe = _searchResults[index];
                              // Hier wird jedes einzelne RecipeItem innerhalb
                              // der ListView.builder gerendert.
                              // Dein RecipeItem braucht imageUrl, name und country.
                              return RecipeItem(
                                imageUrl: recipe.imageUrl,
                                name: recipe.name,
                                // country: recipe.place ?? '', // Sicherstellen, dass 'place' vorhanden ist
                                country: '', // Sicherstellen, dass 'place' vorhanden ist
                                readyInMinutes: recipe.readyInMinutes, // Optional
                                servings: recipe.servings, // Optional
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
}