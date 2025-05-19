import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/common/data/ingredients.dart';
import 'package:frontend/common/models/ingredient.dart';
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
                          onChanged: (value) {
                            setState(() {
                              query = value;
                            });
                          },
                        ),
                      ),
                    ),

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
                                (ingredient) => _buildIngredientChip(
                                  ingredient,
                                  selected: true,
                                  onTap: () => toggleIngredient(ingredient),
                                  theme: theme,
                                ),
                              )
                              .toList(),
                        ),
                      ),

                    if (filteredIngredientSuggestions.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: filteredIngredientSuggestions
                              .map(
                                (ingredient) => _buildIngredientChip(
                                  ingredient,
                                  selected: false,
                                  onTap: () => toggleIngredient(ingredient),
                                  theme: theme,
                                ),
                              )
                              .toList(),
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

  Widget _buildIngredientChip(
    Ingredient ingredient, {
    required bool selected,
    required VoidCallback onTap,
    required ThemeData theme,
  }) {
    final backgroundColor = selected ? theme.primaryColor : Colors.grey[800];
    final textColor = selected ? Colors.black : Colors.white;
    const double imageSize = 24;
    const double chipHeight = 40;

    final imageUrl = ingredient.imageUrl;
    final cacheKey = imageUrl ?? 'no_image';

    bool? canShowImage = _imageAvailabilityCache[cacheKey];

    // Wenn noch nicht im Cache -> prüfen und speichern
    if (canShowImage == null && imageUrl != null) {
      _canLoadImage(imageUrl).then((result) {
        setState(() {
          _imageAvailabilityCache[cacheKey] = result;
        });
      });
      canShowImage = false; // vorerst nicht anzeigen
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        height: chipHeight,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // if (!selected && canShowImage == true)
            if (canShowImage == true)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: SizedBox(
                  width: imageSize,
                  height: imageSize,
                  child: Image.asset(
                    imageUrl!,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            Text(
              ingredient.name,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: textColor,
                fontWeight: FontWeight.w600,
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
