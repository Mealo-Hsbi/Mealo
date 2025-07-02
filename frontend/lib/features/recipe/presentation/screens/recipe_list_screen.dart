// lib/features/recipeList/recipe_list_screen.dart

import 'package:flutter/material.dart';
import 'package:frontend/features/recipe/recipe_service.dart';
import 'package:frontend/features/recipe/presentation/widgets/recipe_list/parallax_recipes.dart';
import 'package:frontend/common/models/recipe.dart';
import 'package:provider/provider.dart';
import 'package:frontend/core/providers/app_providers.dart';

class RecipeListScreen extends StatelessWidget {
  const RecipeListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alle Rezepte'),
      ),
      body: FutureBuilder<List<Recipe>>(
        future: RecipeService.fetchRandomRecipes(number: 10),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Fehler: ${snapshot.error}'));
          }
          final recipes = snapshot.data ?? [];
          if (recipes.isEmpty) {
            return const Center(child: Text('Keine Rezepte gefunden.'));
          }
          final premiumProvider = Provider.of<PremiumProvider>(context);
          // ParallaxRecipes übernimmt hier das Scrollen
          return Consumer<PremiumProvider>(
            builder: (context, premiumProvider, _) {
              return ParallaxRecipes(
                recipes: recipes,
                scrollController: ScrollController(),
                isLoadingMore: false,
                hasMore: false,
                showAds: !premiumProvider.isPremium,
              );
            },
          );
        },
      ),
    );
  }
}
