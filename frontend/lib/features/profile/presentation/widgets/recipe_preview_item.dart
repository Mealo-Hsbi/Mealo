import 'package:flutter/material.dart';

class RecipePreviewItem extends StatelessWidget {
  final String imageUrl;
  final String title;
  final bool isLast;

  const RecipePreviewItem({
    Key? key,
    required this.imageUrl,
    required this.title,
    this.isLast = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140, // Breiter für bessere Lesbarkeit
      margin: EdgeInsets.only(right: isLast ? 0 : 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              imageUrl,
              width: 140,
              height: 80,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 140,
                height: 80,
                color: Colors.grey[200],
                child: const Icon(Icons.broken_image, color: Colors.grey),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium,
            maxLines: 2, // Neu: zwei Zeilen ermöglichen
            overflow: TextOverflow.ellipsis, // Ellipsis, falls länger als 2 Zeilen
          ),
        ],
      ),
    );
  }
}
