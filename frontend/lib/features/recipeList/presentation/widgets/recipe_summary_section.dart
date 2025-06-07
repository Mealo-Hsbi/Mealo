// lib/features/recipeDetails/presentation/widgets/recipe_summary_section.dart
import 'package:flutter/material.dart';

class RecipeSummarySection extends StatelessWidget {
  final String? summary;

  const RecipeSummarySection({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    if (summary == null || summary!.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Summary:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const Divider(),
        Text(
          summary!, // 'summary' sollte bereits bereinigt sein
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}