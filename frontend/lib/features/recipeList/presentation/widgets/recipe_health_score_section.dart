import 'package:flutter/material.dart';

class RecipeHealthScoreSection extends StatelessWidget {
  final double? healthScore;

  const RecipeHealthScoreSection({super.key, required this.healthScore});

  // Methode zum Anzeigen des Info-Dialogs
  void _showHealthScoreInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('About Health Score'),
          content: const Text(
            'This score indicates how healthy the recipe is, based on its nutritional profile. Higher is better.',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Got it!'),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Dialog schließen
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (healthScore == null) {
      return const SizedBox.shrink();
    }

    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    // Bestimme die Farbe basierend auf dem Health Score
    Color scoreColor;
    if (healthScore! >= 75) {
      scoreColor = Colors.green.shade600; // Sehr gut
    } else if (healthScore! >= 50) {
      scoreColor = Colors.orange.shade600; // Mittel
    } else {
      scoreColor = Colors.red.shade600; // Weniger gut
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0), // Vertikales Padding
      child: Card(
        elevation: 0, // Keine zusätzliche Elevation, Card dient als Container
        color: colorScheme.secondary.withOpacity(0.1), // Hintergrund wie bei ServingsAdjuster
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.monitor_heart_rounded, size: 28, color: colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    'Health Score',
                    style: textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(width: 4), // Kleiner Abstand zum Info-Icon
                  // **NEU: GestureDetector für den Klick-Dialog**
                  GestureDetector(
                    onTap: () => _showHealthScoreInfoDialog(context),
                    child: Icon(
                      Icons.info_outline,
                      size: 20,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.center,
                child: Text(
                  '${healthScore!.toStringAsFixed(0)}%',
                  style: textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: scoreColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}