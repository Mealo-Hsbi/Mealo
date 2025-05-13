import 'package:flutter/material.dart';
import 'package:frontend/features/recipeList/parallax_recipes.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body:
      ParallaxRecipes()
      //  Center(
      //   child: Column(
      //     mainAxisAlignment: MainAxisAlignment.center,
      //     children: [
      //       // const Text('Home Screen'),
      //       ParallaxRecipes(),
      //     ],
      //   ),
      // ),
    );
  }
}
