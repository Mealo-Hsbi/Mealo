// lib/features/recipeDetails/presentation/widgets/recipe_summary_section.dart
import 'package:flutter/material.dart';
import 'package:html/parser.dart' show parse; // Importiere parse-Funktion aus dem html-Paket
import 'package:html/dom.dart' as dom; // Importiere dom-Typen

class RecipeSummarySection extends StatelessWidget {
  final String? summary;

  const RecipeSummarySection({super.key, required this.summary});

  // Hilfsmethode, um HTML in TextSpan zu konvertieren
  List<TextSpan> _parseHtmlToTextSpans(String htmlText, BuildContext context) {
    final List<TextSpan> spans = [];
    final document = parse(htmlText);

    // Iteriere durch die Nodes des Dokuments
    for (final node in document.body!.nodes) {
      if (node is dom.Text) {
        spans.add(TextSpan(text: node.text));
      } else if (node is dom.Element) {
        if (node.localName == 'b' || node.localName == 'strong') {
          // Für fettgedruckten Text
          spans.add(TextSpan(
            text: node.text,
            style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
          ));
        } else {
          // Für alle anderen HTML-Elemente, füge nur ihren Textinhalt hinzu
          // Dies ist wichtig, da wir nur <b>/<strong> Tags rendern wollen.
          spans.add(TextSpan(text: node.text));
        }
      }
    }
    return spans;
  }

  @override
  Widget build(BuildContext context) {
    if (summary == null || summary!.isEmpty) {
      return const SizedBox.shrink();
    }

    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row( // Überschrift mit Icon wie im Mockup
            children: [
              Icon(Icons.notes_rounded, size: 28, color: colorScheme.primary), // Passendes Icon
              const SizedBox(width: 8),
              Text(
                'Summary',
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onBackground,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12), // Abstand zum Text

          // Der eigentliche Summary-Text, geparst als Text.rich
          Text.rich(
            TextSpan(
              children: _parseHtmlToTextSpans(summary!, context),
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface,
                height: 1.5, // Zeilenabstand für bessere Lesbarkeit
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}