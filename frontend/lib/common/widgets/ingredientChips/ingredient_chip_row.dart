import 'package:flutter/material.dart';
import 'package:frontend/common/models/ingredient.dart';
import 'ingredient_chip.dart';

class IngredientChipScroller extends StatelessWidget {
  final List<Ingredient> ingredients;
  final bool selected;
  final void Function(Ingredient) onTap;
  final ThemeData theme;
  final Map<String, bool> imageAvailabilityCache;
  final bool showBackground;

  const IngredientChipScroller({
    super.key,
    required this.ingredients,
    required this.selected,
    required this.onTap,
    required this.theme,
    required this.imageAvailabilityCache,
    this.showBackground = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: showBackground ? Colors.grey[200] : null,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: ingredients
              .map((ingredient) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: IngredientChip(
                      ingredient: ingredient,
                      selected: selected,
                      onTap: () => onTap(ingredient),
                      theme: theme,
                      showImage:
                          imageAvailabilityCache[ingredient.imageUrl ?? ''] ?? false,
                    ),
                  ))
              .toList(),
        ),
      ),
    );
  }
}
