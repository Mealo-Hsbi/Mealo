// lib/features/recipeDetails/presentation/widgets/recipe_instructions_section.dart
import 'package:flutter/material.dart';
import 'package:frontend/common/models/recipe/analyzed_instruction_set.dart'; // Benötigt

class RecipeInstructionsSection extends StatelessWidget {
  final List<AnalyzedInstructionSet>? analyzedInstructions;

  const RecipeInstructionsSection({super.key, required this.analyzedInstructions});

  @override
  Widget build(BuildContext context) {
    if (analyzedInstructions == null || analyzedInstructions!.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Instructions:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const Divider(),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: analyzedInstructions!.expand((instructionSet) {
            return [
              if (instructionSet.name != null && instructionSet.name!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 12.0, bottom: 8.0),
                  child: Text(
                    instructionSet.name!,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ...instructionSet.steps.map((step) => Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Text(
                  // 'step.step' sollte bereits bereinigt sein, da es im Modell passiert
                  '${step.number}. ${step.step}',
                  style: const TextStyle(fontSize: 16),
                ),
              )),
            ];
          }).toList(),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}