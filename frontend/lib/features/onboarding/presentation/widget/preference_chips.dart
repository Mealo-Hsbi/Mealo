import 'package:flutter/material.dart';

class PreferenceChips extends StatelessWidget {
  final String title;
  final List<String> options;
  final List<IconData?>? icons;
  final List<String> selection;

  const PreferenceChips({
    super.key,
    required this.title,
    required this.options,
    required this.selection,
    this.icons,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              title,
              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: List.generate(options.length, (index) {
                final option = options[index];
                final isSelected = selection.contains(option);
                final icon = icons != null && index < icons!.length ? icons![index] : null;

                return FilterChip(
                  avatar: icon != null ? Icon(icon, size: 18, color: isSelected ? theme.colorScheme.primary : null) : null,
                  label: Text(option),
                  selected: isSelected,
                  selectedColor: theme.colorScheme.primary.withOpacity(0.15),
                  checkmarkColor: theme.colorScheme.primary,
                  backgroundColor: Colors.grey.shade200,
                  labelStyle: TextStyle(
                    color: isSelected ? theme.colorScheme.primary : Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                  onSelected: (selected) {
                    if (selected) {
                      selection.add(option);
                    } else {
                      selection.remove(option);
                    }
                    // Neubauberechnung für StatelessWidget erzwingen
                    (context as Element).markNeedsBuild();
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
