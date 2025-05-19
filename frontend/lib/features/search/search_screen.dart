import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/common/data/ingredients.dart';
import 'package:frontend/common/models/ingredient.dart';
import 'package:frontend/common/utils/string_similarity_helper.dart'; // neu

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String query = '';
  List<Ingredient> selectedIngredients = [];

  void toggleIngredient(Ingredient ingredient) {
    setState(() {
      if (selectedIngredients.contains(ingredient)) {
        selectedIngredients.remove(ingredient);
      } else {
        selectedIngredients.add(ingredient);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final filteredIngredientSuggestions = filterBySimilarity<Ingredient>(
      allIngredients.where((i) => !selectedIngredients.contains(i)).toList(),
      (i) => i.name,
      query,
      threshold: 0.3,
    );

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
                    // Suchfeld oben
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
                          decoration: const InputDecoration(
                            hintText: 'Search for recipes or ingredients...',
                            prefixIcon: Icon(Icons.search),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(vertical: 12),
                          ),
                          onChanged: (value) {
                            setState(() {
                              query = value;
                            });
                          },
                        ),
                      ),
                    ),

                    // Ausgewählte Zutaten
                    if (selectedIngredients.isNotEmpty)
                      Container(
                        color: Colors.grey[200],
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: selectedIngredients
                              .map(
                                (ingredient) => _buildSpotifyStyleChip(
                                  ingredient.name,
                                  selected: true,
                                  onTap: () => toggleIngredient(ingredient),
                                  theme: theme,
                                ),
                              )
                              .toList(),
                        ),
                      ),

                    // Vorschläge für Zutaten
                    if (filteredIngredientSuggestions.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: filteredIngredientSuggestions
                              .map(
                                (ingredient) => _buildSpotifyStyleChip(
                                  ingredient.name,
                                  selected: false,
                                  onTap: () => toggleIngredient(ingredient),
                                  theme: theme,
                                ),
                              )
                              .toList(),
                        ),
                      ),

                    // Ergebnisbereich
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

  Widget _buildSpotifyStyleChip(
    String label, {
    required bool selected,
    required VoidCallback onTap,
    required ThemeData theme,
  }) {
    final backgroundColor = selected
        ? theme.primaryColor
        : Colors.grey[700];
    final textColor = selected ? Colors.black : Colors.white;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: textColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
