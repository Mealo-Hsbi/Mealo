import 'package:flutter/material.dart';
import 'package:frontend/common/models/recipe/analyzed_instruction_set.dart';
import 'package:frontend/common/models/recipe/instruction_step.dart'; // Importiere InstructionStep

class RecipeInstructionsSection extends StatelessWidget {
  final List<AnalyzedInstructionSet>? analyzedInstructions;

  const RecipeInstructionsSection({super.key, required this.analyzedInstructions});

  @override
  Widget build(BuildContext context) {
    if (analyzedInstructions == null || analyzedInstructions!.isEmpty) {
      return const SizedBox.shrink();
    }

    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0), // Vertikales Padding um die gesamte Sektion
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row( // Überschrift mit Icon wie im Mockup
            children: [
              Icon(Icons.format_list_numbered_rounded, size: 28, color: colorScheme.primary), // Passendes Icon
              const SizedBox(width: 8),
              Text(
                'Instructions',
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onBackground,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12), // Abstand zur Liste der Anweisungen

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: analyzedInstructions!.expand((instructionSet) {
              return [
                // Optionaler Untertitel für Anweisungsgruppen (z.B. "For the sauce")
                if (instructionSet.name != null && instructionSet.name!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 12.0, bottom: 8.0),
                    child: Text(
                      instructionSet.name!,
                      style: textTheme.titleLarge?.copyWith( // Etwas größer als Schritte, weniger fett als Haupttitel
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                // Die einzelnen Schritte als Karten
                ...instructionSet.steps.map((step) => Padding(
                      padding: const EdgeInsets.only(bottom: 12.0), // Abstand zwischen den Schritt-Karten
                      child: Container(
                        padding: const EdgeInsets.all(16.0), // Innenabstand
                        decoration: BoxDecoration(
                          color: colorScheme.surface, // Hintergrundfarbe der Schritt-Karte
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
                            // Schrittnummer als "Badge"
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: colorScheme.primary, // Farbe des Badges (z.B. primäre Akzentfarbe)
                                borderRadius: BorderRadius.circular(6.0),
                              ),
                              child: Text(
                                step.number.toString(),
                                style: textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onPrimary, // Textfarbe für die Nummer
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12), // Abstand zwischen Nummer und Text
                            Expanded(
                              child: Text(
                                step.step ?? '', // Der eigentliche Anweisungstext
                                style: textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onSurface,
                                  height: 1.5, // Zeilenabstand für bessere Lesbarkeit
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )),
              ];
            }).toList(),
          ),
          const SizedBox(height: 20), // Abstand nach der gesamten Sektion
        ],
      ),
    );
  }
}