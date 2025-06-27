// lib/features/recipeDetails/presentation/widgets/recipe_instructions_section.dart

import 'package:flutter/material.dart';
import 'package:frontend/common/models/recipe/analyzed_instruction_set.dart';
import 'package:frontend/features/recipe/presentation/widgets/recipe_sections/recipe_timer_button.dart'; // Importiere das Timer-Widget

class RecipeInstructionsSection extends StatelessWidget {
  final List<AnalyzedInstructionSet>? analyzedInstructions;

  const RecipeInstructionsSection({super.key, required this.analyzedInstructions});

  // Helfermethode zum Parsen von einfachem HTML in TextSpans
  List<TextSpan> _parseHtmlToTextSpans(String htmlText, TextStyle defaultStyle) {
    final List<TextSpan> spans = [];
    final RegExp exp = RegExp(r'<b>(.*?)</b>|<strong>(.*?)</strong>|<i>(.*?)</i>|<em>(.*?)</em>|([^<]+)');
    final matches = exp.allMatches(htmlText);

    for (final match in matches) {
      if (match.group(1) != null || match.group(2) != null) {
        // Bold text (<b> or <strong>)
        spans.add(
          TextSpan(
            text: match.group(1) ?? match.group(2),
            style: defaultStyle.copyWith(fontWeight: FontWeight.bold),
          ),
        );
      } else if (match.group(3) != null || match.group(4) != null) {
        // Italic text (<i> or <em>)
        spans.add(
          TextSpan(
            text: match.group(3) ?? match.group(4),
            style: defaultStyle.copyWith(fontStyle: FontStyle.italic),
          ),
        );
      } else if (match.group(5) != null) {
        // Regular text
        spans.add(
          TextSpan(
            text: match.group(5),
            style: defaultStyle,
          ),
        );
      }
    }
    return spans;
  }

  @override
  Widget build(BuildContext context) {
    if (analyzedInstructions == null || analyzedInstructions!.isEmpty) {
      return const SizedBox.shrink();
    }

    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.format_list_numbered_rounded, size: 28, color: colorScheme.primary),
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
          const SizedBox(height: 12),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: analyzedInstructions!.expand((instructionSet) {
              return [
                if (instructionSet.name != null && instructionSet.name!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 12.0, bottom: 8.0),
                    child: Text(
                      instructionSet.name!,
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                ...instructionSet.steps.map((step) {
                  final int? durationInSeconds = step.duration?.toSeconds();
                  final bool hasTimer = durationInSeconds != null && durationInSeconds > 0;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        borderRadius: BorderRadius.circular(8.0),
                        border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Wrap( // NEU: Wrap Widget für flexiblen Zeilenumbruch
                        alignment: WrapAlignment.start,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 12.0, // Abstand zwischen den Elementen im Wrap
                        runSpacing: 8.0, // Abstand zwischen den Zeilen im Wrap
                        children: [
                          // Schrittnummer als "Badge"
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: colorScheme.primary,
                              borderRadius: BorderRadius.circular(6.0),
                            ),
                            child: Text(
                              step.number.toString(),
                              style: textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          // Der eigentliche Anweisungstext (HTML-formatiert)
                          Flexible( // Wichtig, damit der Text umbricht und den Timer nicht verdrängt
                            child: Text.rich(
                              TextSpan(
                                children: _parseHtmlToTextSpans(
                                  step.step,
                                  textTheme.bodyMedium?.copyWith(
                                        color: colorScheme.onSurface,
                                        height: 1.5,
                                      ) ??
                                      const TextStyle(), // Fallback für TextStyle
                                ),
                              ),
                            ),
                          ),
                          // Timer-Button, falls eine Dauer vorhanden ist
                          if (hasTimer)
                            RecipeTimerButton(
                              initialDurationInSeconds: durationInSeconds,
                              // Optional: Text- und Icon-Stile vom Eltern-Widget übergeben
                              textStyle: textTheme.bodyMedium?.copyWith(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                              iconColor: colorScheme.primary,
                            ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ];
            }).toList(),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
