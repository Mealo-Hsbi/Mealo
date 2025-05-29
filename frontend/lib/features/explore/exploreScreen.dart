// lib/features/explore/exploreScreen.dart (Aktualisiere diesen File)
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // NEU: Provider importieren
import 'package:frontend/features/search/presentation/screens/search_screen.dart';
import 'package:frontend/providers/current_tab_provider.dart'; // NEU: CurrentTabProvider importieren

class ExploreScreen extends StatefulWidget { // GEÄNDERT: StatefulWidget statt StatelessWidget
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  late VoidCallback _currentTabListener;

  @override
  void initState() {
    super.initState();
    // Listener initialisieren
    _currentTabListener = () {
      final currentTabProvider = context.read<CurrentTabProvider>();
      // Prüfen, ob der ExploreScreen der aktive Tab ist UND das Navigations-Flag gesetzt ist
      if (currentTabProvider.currentIndex == 1 && currentTabProvider.shouldNavigateToSearch) {
        Navigator.of(context).popUntil((route) => route.isFirst);
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const SearchScreen()),
        );
        currentTabProvider.resetSearchNavigation();
      }
    };

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CurrentTabProvider>().addListener(_currentTabListener);
      // Beim initialen Laden auch prüfen, falls der Tab bereits bei App-Start der richtige ist
      _currentTabListener();
    });
  }

  @override
  void dispose() {
    // Listener wieder entfernen
    context.read<CurrentTabProvider>().removeListener(_currentTabListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Optional: Überprüfen, ob der SearchScreen bereits aktiv ist, um Dopplungen zu vermeiden.
    // Dies ist primär für den Fall, dass man manuell auf die Suchleiste im ExploreScreen tippt.
    // Der Listener kümmert sich um den automatischen Fall.

    return Scaffold(
      appBar: AppBar(title: const Text('Explore')), // Hier kannst du den Titel anpassen
      body: SafeArea(
        child: Column(
          children: [
            // Suchleiste oben
            Padding(
              padding: const EdgeInsets.all(16),
              child: GestureDetector(
                onTap: () {
                  // Sicherstellen, dass bei manuellem Tippen der Stack erst zur Root geleert wird
                  // bevor man zum SearchScreen navigiert, um saubere Navigation zu haben.
                  Navigator.of(context).popUntil((route) => route.isFirst);
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const SearchScreen()),
                  );
                },
                child: Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(24),
                  ),
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: const [
                      Icon(Icons.search, color: Colors.grey),
                      SizedBox(width: 8),
                      Text(
                        'Suche nach Rezepten...',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Platzhalter für weitere Inhalte
            const Expanded(
              child: Center(
                child: Text('Hier kommen später andere Explore-Inhalte hin.'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}