import 'package:flutter/material.dart';

class TagChip extends StatelessWidget {
  final String tag;
  const TagChip(this.tag, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).colorScheme.primary;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8, vertical: 6,
      ),
      decoration: BoxDecoration(
        color: p.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(tag, style: TextStyle(color: p)),
    );
  }
}
