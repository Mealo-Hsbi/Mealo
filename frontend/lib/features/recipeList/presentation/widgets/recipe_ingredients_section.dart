import 'package:flutter/material.dart';
import 'package:frontend/common/models/recipe/extended_ingredient.dart';
import 'dart:math' as math; // Für die escapeRegExp Funktion

// Helper function to escape strings for regex (copied from your JS mockup)
String escapeRegExp(String str) {
  return str.replaceAllMapped(RegExp(r'[.*+?^${}()|[\]\\]'), (match) => '\\${match.group(0)}');
}

// Helper function for formatting amounts (copied from your JS mockup and adapted for Dart)
String formatAmount(double amount) {
  if (amount <= 0) return "0";

  final wholePart = amount.floor();
  final decimalPart = amount - wholePart;

  // Use a small tolerance for floating point comparisons
  const double tolerance = 0.005; // Adjusted tolerance for Dart doubles

  if ((decimalPart - 0.25).abs() < tolerance) return wholePart > 0 ? '${wholePart} ¼' : '¼';
  if ((decimalPart - 0.333).abs() < tolerance) return wholePart > 0 ? '${wholePart} ⅓' : '⅓';
  if ((decimalPart - 0.5).abs() < tolerance) return wholePart > 0 ? '${wholePart} ½' : '½';
  if ((decimalPart - 0.666).abs() < tolerance) return wholePart > 0 ? '${wholePart} ⅔' : '⅔';
  if ((decimalPart - 0.75).abs() < tolerance) return wholePart > 0 ? '${wholePart} ¾' : '¾';
  
  if (decimalPart == 0) return amount.toInt().toString(); // Whole number

  return amount.toStringAsFixed(1); // Default to 1 decimal place
}

class RecipeIngredientsSection extends StatelessWidget {
  final List<ExtendedIngredient>? ingredients;
  final int? originalServings; // Benötigt für die Anzeige im Titel
  final int? currentServings; // Benötigt für die Anzeige im Titel


  const RecipeIngredientsSection({
    super.key,
    required this.ingredients,
    this.originalServings,
    this.currentServings,
  });

  @override
  Widget build(BuildContext context) {
    if (ingredients == null || ingredients!.isEmpty) {
      return const SizedBox.shrink();
    }

    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    // Optional: Anzeige "for X servings"
    String servingsText = '';
    if (originalServings != null && currentServings != null && currentServings! > 0 && originalServings! > 0 && currentServings != originalServings) {
      servingsText = '(for ${currentServings} servings)';
    }


    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row( // Überschrift mit Icon wie im Mockup
            children: [
              Icon(Icons.restaurant_menu, size: 28, color: colorScheme.primary), // Utensils Icon
              const SizedBox(width: 8),
              Text(
                'Ingredients',
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onBackground,
                ),
              ),
              if (servingsText.isNotEmpty) ...[
                const SizedBox(width: 8),
                Text(
                  servingsText,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.normal,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12), // Abstand zum nächsten Element

          // Die Liste der Zutaten
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(), // Damit die Liste nicht selbst scrollt
            itemCount: ingredients!.length,
            itemBuilder: (context, index) {
              final ing = ingredients![index];

              // Anpassung der Anzeige-Logik für Menge und Einheit
              String displayText = ing.original ?? ''; // Standard: Originaltext

              if (ing.amount != null && ing.amount! > 0) {
                final formattedAdjAmount = formatAmount(ing.amount!);
                final unit = ing.unit ?? "";
                final namePart = ing.name ?? "";

                // Versuche, den originalen String zu parsen und nur die Zahl zu ersetzen
                // Dies ist ein komplexer Teil, der robustes Regex erfordert.
                // Für Einfachheit, falls original string eine Zahl am Anfang hat, ersetzen wir diese.
                // Ansonsten bauen wir den String neu zusammen.

                final RegExp firstNumRegex = RegExp(r'^(\d*\.?\d+)\s*([a-zA-Z]*)'); // Matches 1.0, 1/2, 1 1/2, etc. and an optional unit
                final match = firstNumRegex.firstMatch(ing.original ?? '');

                if (match != null && match.group(1) != null) {
                  // Wenn eine Zahl am Anfang gefunden wurde, ersetze sie
                  displayText = ing.original!.replaceFirst(match.group(1)!, formattedAdjAmount);
                } else {
                  // Fallback: Baue den String neu zusammen, wenn keine einfache Zahl am Anfang
                  String newText = '$formattedAdjAmount ${unit} ${namePart}'.trim();
                  // Vermeide doppelte Einheit, wenn der Name sie bereits enthält (z.B. "cup" in "cup flour")
                  if (unit.isNotEmpty && namePart.toLowerCase().contains(unit.toLowerCase())) {
                    newText = '$formattedAdjAmount ${namePart}'.trim();
                  }
                  displayText = newText.replaceAll(RegExp(r'\s+'), ' ').trim(); // Mehrere Leerzeichen reduzieren
                }
              }


              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0), // Abstand zwischen den Listenelementen
                child: Container(
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: colorScheme.surface, // Hintergrundfarbe der einzelnen Zutat
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(color: colorScheme.outline.withOpacity(0.2)), // Dezenter Rand
                    boxShadow: [ // Leichter Schatten für den "schwebenden" Effekt
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.check_circle, color: colorScheme.primary, size: 20), // CheckCircle Icon
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          displayText,
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 20), // Abstand nach der Liste
        ],
      ),
    );
  }
}