import 'package:flutter/material.dart';
import 'package:frontend/features/recipeList/parallax_recipes.dart';
import 'package:frontend/common/models/recipe.dart';
import 'package:frontend/features/recipeList/recipe_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),

      // body:
      // ParallaxRecipes()

      //  Center(
      //   child: Column(
      //     mainAxisAlignment: MainAxisAlignment.center,
      //     children: [
      //       // const Text('Home Screen'),
      //       ParallaxRecipes(),
      //     ],
      //   ),
      // ),

      body: FutureBuilder<List<Recipe>>(
        future: RecipeService.fetchRandomRecipes(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Fehler: ${snapshot.error}'));
          } else {
            return Center(child: Text('Homy Screen'));
            // placeholder widget
          }
        },
      ),
    );
  }
}
