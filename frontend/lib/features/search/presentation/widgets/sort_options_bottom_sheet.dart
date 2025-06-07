// lib/features/search/presentation/widgets/sort_options_bottom_sheet.dart

import 'package:flutter/material.dart';

// Definieren der Sortieroptionen außerhalb der Klasse, da sie statisch sind
// Key: Interner Wert für die Logik/Backend (Muss Spoonacular-kompatibel sein)
// Value: Map mit 'name' (Anzeige) und 'icon'
const Map<String, Map<String, dynamic>> sortOptionsData = {
  'relevance': {'name': 'Relevance', 'icon': Icons.sort},
  'time_asc': {'name': 'Preparation Time (shortest first)', 'icon': Icons.access_time},
  'time_desc': {'name': 'Preparation Time (longest first)', 'icon': Icons.access_time},
  'popularity_desc': {'name': 'Popularity (highest first)', 'icon': Icons.trending_up},
  'calories_asc': {'name': 'Calories (lowest first)', 'icon': Icons.local_fire_department},
  'calories_desc': {'name': 'Calories (highest first)', 'icon': Icons.local_fire_department},
  'healthiness_desc': {'name': 'Healthiness (highest first)', 'icon': Icons.favorite_outline},
  'protein_desc': {'name': 'Protein (highest first)', 'icon': Icons.fitness_center},
  'fat_desc': {'name': 'Fat (highest first)', 'icon': Icons.fastfood},
  'carbs_desc': {'name': 'Carbs (highest first)', 'icon': Icons.rice_bowl},
  'sugar_desc': {'name': 'Sugar (highest first)', 'icon': Icons.cake},
};

class SortOptionsBottomSheet extends StatelessWidget {
  final String currentSortOption;
  final ValueChanged<String> onOptionSelected; // Callback für die Auswahl

  const SortOptionsBottomSheet({
    super.key,
    required this.currentSortOption,
    required this.onOptionSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: sortOptionsData.entries.map((entry) {
            final optionKey = entry.key;
            final optionData = entry.value;
            final optionName = optionData['name'] as String;
            final optionIcon = optionData['icon'] as IconData;

            Widget? arrowOverlay;
            if (optionKey.endsWith('_asc')) {
              arrowOverlay = const Positioned(
                top: -4, // Etwas weiter nach oben
                right: -4, // Etwas weiter nach rechts (mehr Abstand)
                child: Icon(
                  Icons.arrow_drop_up,
                  size: 24,
                  color: Colors.black,
                ),
              );
            } else if (optionKey.endsWith('_desc')) {
              arrowOverlay = const Positioned(
                bottom: -4, // Etwas weiter nach unten
                right: -4, // Etwas weiter nach rechts (mehr Abstand)
                child: Icon(
                  Icons.arrow_drop_down,
                  size: 24,
                  color: Colors.black,
                ),
              );
            }

            return ListTile(
              leading: SizedBox(
                width: 36, // Größe des Platzhalters leicht erhöht, um mehr Raum zu geben
                height: 36, // Größe des Platzhalters leicht erhöht
                child: Stack(
                  clipBehavior: Clip.none, // Erlaubt dem Pfeil, über die Grenzen des Stack hinauszugehen
                  children: [
                    // Haupt-Icon, leicht nach links und oben verschoben
                    Positioned(
                      left: 0,
                      top: 6, // Angepasster Top-Wert
                      child: Icon(optionIcon, size: 24),
                    ),
                    if (arrowOverlay != null)
                      arrowOverlay,
                  ],
                ),
              ),
              title: Text(
                optionName,
                style: TextStyle(
                  fontWeight: currentSortOption == optionKey ? FontWeight.bold : FontWeight.normal,
                  color: currentSortOption == optionKey ? Theme.of(context).primaryColor : null,
                ),
              ),
              trailing: currentSortOption == optionKey
                  ? Icon(Icons.check, color: Theme.of(context).primaryColor)
                  : null,
              onTap: () {
                onOptionSelected(optionKey);
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  static IconData getSortIcon(String currentOption) {
    final optionData = sortOptionsData[currentOption];
    if (optionData != null && optionData.containsKey('icon')) {
      return optionData['icon'] as IconData;
    }
    return Icons.sort;
  }
}