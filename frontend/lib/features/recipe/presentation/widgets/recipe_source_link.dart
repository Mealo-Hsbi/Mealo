// lib/features/recipeDetails/presentation/widgets/recipe_source_link.dart
import 'package:flutter/material.dart';
import 'package:frontend/common/utils/url_launcher.dart';

class RecipeSourceLink extends StatelessWidget {
  final String? sourceUrl;
  final String? sourceName;

  const RecipeSourceLink({
    super.key,
    required this.sourceUrl,
    required this.sourceName,
  });

  @override
  Widget build(BuildContext context) {
    if (sourceUrl == null || sourceUrl!.isEmpty) {
      return const SizedBox.shrink();
    }
    return GestureDetector(
      onTap: () => UrlLauncherUtil.launchURL(context, sourceUrl!),
      child: Text(
        'View original recipe at: ${sourceName ?? 'Source'}',
        style: TextStyle(
          color: Theme.of(context).primaryColor,
          decoration: TextDecoration.underline,
          fontSize: 16,
        ),
      ),
    );
  }
}