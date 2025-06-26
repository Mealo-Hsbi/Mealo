// lib/features/recipeDetails/presentation/widgets/recipe_instructions_section.dart

import 'package:flutter/material.dart';
import 'package:frontend/common/models/recipe/analyzed_instruction_set.dart';
import 'package:frontend/features/recipeList/presentation/widgets/recipe_timer_button.dart';

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
                  // Prüfen, ob eine Dauer für diesen Schritt vorhanden ist
                  final int? durationInSeconds = step.duration?.toSeconds();

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
                      child: Column( // Ändern zu Column, um Timer unter den Text zu legen
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
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
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  step.step, // Der eigentliche Anweisungstext
                                  style: textTheme.bodyMedium?.copyWith(
                                    color: colorScheme.onSurface,
                                    height: 1.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (durationInSeconds != null && durationInSeconds > 0)
                            Padding(
                              padding: const EdgeInsets.only(top: 12.0), // Abstand zum Text
                              child: Align(
                                alignment: Alignment.centerLeft, // Timer linksbündig unter dem Text
                                child: RecipeTimerButton(
                                  initialDurationInSeconds: durationInSeconds,
                                ),
                              ),
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
