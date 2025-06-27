import 'package:flutter/material.dart';

class ServingsAdjusterSection extends StatefulWidget {
  final int originalServings;
  final int currentServings;
  final ValueChanged<int> onServingsChanged;

  const ServingsAdjusterSection({
    super.key,
    required this.originalServings,
    required this.currentServings,
    required this.onServingsChanged,
  });

  @override
  State<ServingsAdjusterSection> createState() => _ServingsAdjusterSectionState();
}

class _ServingsAdjusterSectionState extends State<ServingsAdjusterSection> {
  // Kein TextEditingController mehr nötig, da der Dialog entfernt wurde

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      color: colorScheme.secondary.withOpacity(0.1), // Hintergrund wie im Mockup
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.people_alt, size: 24, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Adjust Servings',
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Number of Servings:', style: textTheme.bodyMedium),
                const SizedBox(height: 8),

                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(
                    color: colorScheme.surface, // Hintergrund für den Stepper
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: colorScheme.outline.withOpacity(0.5)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween, // Verteilt die Buttons und die Zahl
                    children: [
                      IconButton(
                        icon: Icon(Icons.remove, color: colorScheme.primary),
                        onPressed: widget.currentServings > 1
                            ? () => widget.onServingsChanged(widget.currentServings - 1)
                            : null, // Deaktiviert bei 1 Portion
                      ),
                      Text(
                        // Nur die Zahl anzeigen, nicht tappbar
                        widget.currentServings.toString(),
                        style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: Icon(Icons.add, color: colorScheme.primary),
                        onPressed: () => widget.onServingsChanged(widget.currentServings + 1),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12), // Abstand zum Reset Button

                // Reset Button separat, nimmt die volle Breite ein
                ElevatedButton(
                  onPressed: widget.currentServings == widget.originalServings
                      ? null
                      : () {
                          widget.onServingsChanged(widget.originalServings);
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  child: Text('Reset to ${widget.originalServings} servings'),
                ),
              ],
            ),
            // const SizedBox(height: 8),
            // Text(
            //   'Original recipe serves ${widget.originalServings}. Ingredient quantities below will adjust accordingly.',
            //   style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
            // ),
          ],
        ),
      ),
    );
  }
}