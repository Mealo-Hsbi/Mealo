// lib/features/recipeDetails/presentation/widgets/recipe_detail_app_bar.dart
import 'package:flutter/material.dart';

class RecipeDetailAppBar extends StatelessWidget {
  final String imageUrl;
  final String title;

  const RecipeDetailAppBar({
    super.key,
    required this.imageUrl,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 300.0,
      floating: false,
      pinned: true,
      flexibleSpace: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final double top = constraints.biggest.height;
          final bool isCollapsed = top < kToolbarHeight + 20;

          return FlexibleSpaceBar(
            background: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      Center(child: Icon(Icons.broken_image, size: 80, color: Colors.grey[400])),
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.transparent, Colors.black.withOpacity(0.6)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: const [0.6, 1],
                    ),
                  ),
                ),
              ],
            ),
            title: AnimatedOpacity(
              opacity: isCollapsed ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      color: Colors.black38,
                      blurRadius: 6,
                      offset: Offset(1, 1),
                    ),
                  ],
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            stretchModes: const [StretchMode.zoomBackground],
          );
        },
      ),
    );
  }
}