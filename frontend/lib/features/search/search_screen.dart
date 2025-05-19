import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String query = '';
  String searchMode = 'Recipes'; // oder 'Ingredients'

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
  value: SystemUiOverlayStyle.dark, // dunkle Icons auf hellem Hintergrund
  child: Scaffold(
    body: Column(
      children: [
        // Nur Statusbar-Hintergrund
        Container(
          height: MediaQuery.of(context).padding.top,
          color: Colors.grey[200], // Heller Hintergrund für Statusleiste
        ),
        // Restlicher Content unverändert
        Expanded(
          child: SafeArea(
            top: false, // Wir haben oben manuell Platz geschaffen
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Suchfeld-Bereich wie vorher
                Container(
                  color: Colors.grey[200],
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TextField(
                          decoration: const InputDecoration(
                            hintText: 'Suche nach Recipesn oder Ingredients...',
                            prefixIcon: Icon(Icons.search),
                            border: InputBorder.none,
                          ),
                          onChanged: (value) {
                            setState(() => query = value);
                          },
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        margin: const EdgeInsets.only(top: 8),
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => searchMode = 'Recipes'),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: searchMode == 'Recipes' ? Colors.white : Colors.transparent,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    'Recipes',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: searchMode == 'Recipes' ? Colors.black : Colors.grey[700],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => searchMode = 'Ingredients'),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: searchMode == 'Ingredients' ? Colors.white : Colors.transparent,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    'Ingredients',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: searchMode == 'Ingredients' ? Colors.black : Colors.grey[700],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: query.isEmpty
                      ? const Center(child: Text('Bitte etwas eingeben...'))
                      : Center(child: Text('Suche nach "$query" in $searchMode')),
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
}
