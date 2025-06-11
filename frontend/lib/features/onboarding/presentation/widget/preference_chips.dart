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
                  avatar: icon != null
                      ? Icon(icon, size: 18, color: isSelected ? theme.colorScheme.onPrimary : Colors.grey)
                      : null,
                  label: Text(
                    option,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isSelected ? theme.colorScheme.onPrimary : Colors.black,
                    ),
                  ),
                  selected: isSelected,
                  selectedColor: theme.colorScheme.primary,
                  backgroundColor: Colors.grey.shade200,
                  elevation: 1,
                  pressElevation: 3,
                  showCheckmark: false, // ❌ Kein Haken
                  onSelected: (selected) {
                    if (selected) {
                      selection.add(option);
                    } else {
                      selection.remove(option);
                    }
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
