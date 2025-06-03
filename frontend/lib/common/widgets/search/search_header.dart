// lib/common/widgets/search/search_header.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SearchHeader extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final Widget? trailingAction; // <-- NEU: Optionales Widget für Aktionen

  const SearchHeader({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    this.trailingAction, // <-- NEU: Im Konstruktor hinzufügen
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Column(
        children: [
          // Container für den Statusbalken-Abstand
          Container(
            height: MediaQuery.of(context).padding.top,
            color: colorScheme.background,
          ),
          // Container für den eigentlichen Suchbalken-Bereich
          Container(
            color: colorScheme.background,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              // HIER IST DIE WICHTIGE ÄNDERUNG:
              // Das TextField wird jetzt in eine Row gewickelt,
              // um den trailingAction daneben zu platzieren.
              child: Row( // <-- NEU: Row hinzufügen
                children: [
                  Expanded( // <-- NEU: TextField nimmt den verfügbaren Platz ein
                    child: TextField(
                      controller: controller,
                      focusNode: focusNode,
                      decoration: InputDecoration(
                        hintText: 'Search for recipes or ingredients...',
                        prefixIcon: const Icon(Icons.search), // const hinzugefügt
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onChanged: onChanged,
                    ),
                  ),
                  if (trailingAction != null) // <-- NEU: Füge das optionale Action-Widget hinzu
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0), // Kleiner Abstand zum TextField
                      child: trailingAction!,
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}