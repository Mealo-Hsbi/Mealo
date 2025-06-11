import 'package:flutter/material.dart';

class PreferenceChips extends StatelessWidget {
  final String title;
  final List<String> options;
  final List<String> selection;

  const PreferenceChips({
    super.key,
    required this.title,
    required this.options,
    required this.selection,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: theme.textTheme.titleLarge),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: options.map((option) {
              final isSelected = selection.contains(option);
              return FilterChip(
                label: Text(option),
                selected: isSelected,
                selectedColor: theme.colorScheme.primary.withOpacity(0.2),
                onSelected: (selected) {
                  if (selected) {
                    selection.add(option);
                  } else {
                    selection.remove(option);
                  }
                  (context as Element).markNeedsBuild(); // zum Re-Rendern
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
