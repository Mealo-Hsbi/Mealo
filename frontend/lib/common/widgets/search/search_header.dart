import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SearchHeader extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;

  const SearchHeader({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Column(
        children: [
          Container(
            height: MediaQuery.of(context).padding.top,
            color: colorScheme.background, // genau Colors.grey[200]
          ),
          Container(
            color: colorScheme.background, // genau Colors.grey[200]
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: colorScheme.surface, // genau Colors.white
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                decoration: InputDecoration(
                  hintText: 'Search for recipes or ingredients...',
                  prefixIcon: Icon(Icons.search),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
