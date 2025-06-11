// lib/features/search/presentation/widgets/recipe_filter_bottom_sheet.dart

import 'package:flutter/material.dart';
import 'package:frontend/features/search/presentation/provider/search_notifier.dart';
import 'package:provider/provider.dart';

class RecipeFilterBottomSheet extends StatelessWidget {
  const RecipeFilterBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    // Verwenden Sie Consumer, um auf den SearchNotifier zuzugreifen
    return Consumer<SearchNotifier>(
      builder: (context, searchNotifier, child) {
        return SafeArea(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Filteroptionen',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                const Divider(),

                // **NEU:** Slider für Max. fehlende Zutaten
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Maximale fehlende Zutaten:',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: Slider(
                              value: searchNotifier.maxMissingIngredients.toDouble(),
                              min: 0,
                              max: 5, // Passen Sie den Maximalwert an Ihre Bedürfnisse an
                              divisions: 5, // Für ganze Zahlen von 0 bis 5
                              label: searchNotifier.maxMissingIngredients.toString(),
                              onChanged: (newValue) {
                                searchNotifier.setMaxMissingIngredients(newValue.round());
                              },
                            ),
                          ),
                          Text(searchNotifier.maxMissingIngredients.toString(), style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(width: 8),
                        ],
                      ),
                      Text(
                        'Stellen Sie ein, wie viele Ihrer benötigten Zutaten maximal fehlen dürfen.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                const Divider(),

                // Hier könnten weitere Filteroptionen hinzugefügt werden, z.B. Checkboxen für Diäten, etc.
                // Beispiel:
                // ListTile(
                //   title: Text('Vegetarisch'),
                //   trailing: Checkbox(
                //     value: false, // Hier den tatsächlichen Filter-State des Notifiers nutzen
                //     onChanged: (bool? value) {
                //       // Filter-State im Notifier aktualisieren und Suche auslösen
                //     },
                //   ),
                // ),

                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    onPressed: () {
                      // Schließt das Bottom Sheet und löst optional eine Suche aus,
                      // wenn die setMaxMissingIngredients-Methode dies nicht schon tut
                      Navigator.pop(context);
                    },
                    child: const Text('Filter anwenden'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}