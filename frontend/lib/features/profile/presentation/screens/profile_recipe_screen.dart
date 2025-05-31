// lib/features/profile/presentation/screens/profile_recipes_screen.dart

import 'package:flutter/material.dart';

// Richtig: einheitliches Recipe-Modell aus der Domain/Entities
import 'package:frontend/features/recipeList/domain/entities/recipe.dart';
// Richtig: ParallaxWidget
import 'package:frontend/features/recipeList/presentation/parallax_recipes.dart';

class ProfileRecipesScreen extends StatelessWidget {
  const ProfileRecipesScreen({Key? key}) : super(key: key);

  List<Recipe> _buildMockRecipes() {
    return [
      Recipe(
        id: 'uuid-1',
        createdById: null,
        spoonacularId: 715538,
        name: 'Spaghetti Bolognese',
        place: 'Italien', // Du legst hier selbst fest, was „place“ heißen soll
        imageUrl: 'https://images.unsplash.com/photo-1589301760014-d929f3979dbc?&w=800',
        servings: 4,
        readyInMinutes: 45,
        cookingMinutes: 30,
        preparationMinutes: 15,
        dishTypes: ['main course', 'dinner'],
        summary: 'Ein klassisches italienisches Nudelgericht mit würziger Soße.',
        instructions:
            '1. Zwiebeln fein hacken …\n2. Hackfleisch anbraten …\n3. Tomaten hinzugeben …',
        healthScore: 70.5,
        spoonacularScore: 95.0,
        pricePerServing: 2.50,
        vegan: false,
        vegetarian: false,
        glutenFree: false,
        dairyFree: true,
        weightWatcherPoints: 10,
        createdAt: DateTime.now(),
      ),
      Recipe(
        id: 'uuid-2',
        createdById: null,
        spoonacularId: 716429,
        name: 'Tomaten-Mozzarella-Salat',
        place: 'Italien',
        imageUrl: 'https://images.unsplash.com/photo-1572441710609-24dde1eed2a4?&w=800',
        servings: 2,
        readyInMinutes: 10,
        cookingMinutes: 0,
        preparationMinutes: 10,
        dishTypes: ['salad', 'side dish'],
        summary: 'Frischer Salat mit Tomaten, Mozzarella und Basilikum.',
        instructions: '1. Tomaten und Mozzarella in Scheiben schneiden …\n2. Anrichten …',
        healthScore: 85.0,
        spoonacularScore: 88.0,
        pricePerServing: 1.75,
        vegan: false,
        vegetarian: true,
        glutenFree: true,
        dairyFree: false,
        weightWatcherPoints: 4,
        createdAt: DateTime.now(),
      ),
      // …weitere Mock‐Rezepte…
    ];
  }

  @override
  Widget build(BuildContext context) {
    final mockRecipes = _buildMockRecipes();

    return Scaffold(
      appBar: AppBar(title: const Text('My Recipes')),
      body: mockRecipes.isEmpty
          ? Center(
              child: Text(
                'Du hast noch keine Rezepte.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            )
          : SingleChildScrollView(
              child: ParallaxRecipes(recipes: mockRecipes),
            ),
    );
  }
}
