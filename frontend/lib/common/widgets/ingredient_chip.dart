import 'package:flutter/material.dart';
import 'package:frontend/common/models/ingredient.dart';

class IngredientChip extends StatelessWidget {
  final Ingredient ingredient;
  final bool selected;
  final VoidCallback onTap;
  final ThemeData theme;
  final bool showImage;

  const IngredientChip({
    required this.ingredient,
    required this.selected,
    required this.onTap,
    required this.theme,
    required this.showImage,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final backgroundColor = selected ? theme.primaryColor : Colors.grey[800];
    final textColor = selected ? Colors.black : Colors.white;
    const double imageSize = 24;
    const double chipHeight = 40;

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
            if (showImage)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: SizedBox(
                  width: imageSize,
                  height: imageSize,
                  child: Image.asset(
                    ingredient.imageUrl!,
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
}
