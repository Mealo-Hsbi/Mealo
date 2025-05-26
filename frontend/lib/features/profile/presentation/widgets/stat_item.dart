import 'package:flutter/material.dart';

class StatItem extends StatelessWidget {
  final String label;
  final int value;

  const StatItem(this.label, this.value, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$value',
          style: t.textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: t.textTheme.bodySmall
              ?.copyWith(color: Colors.grey[600]),
        ),
      ],
    );
  }
}
