import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/common/models/recipe.dart';
import 'package:frontend/features/recipe/presentation/widgets/recipe_list/parallax_recipes.dart';

void main() {
  testWidgets('shows allergen tag for recipes with allergens', (WidgetTester tester) async {
    final recipe = Recipe(
      id: 1,
      internalId: null,
      isInternal: false,
      name: 'Milk Cake',
      imageUrl: '',
      place: 'Test',
      containsUserAllergens: true,
      matchedAllergens: ['milk', 'gluten', 'egg'],
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ListView(
            children: [
              RecipeItem(
                id: recipe.id,
                internalId: recipe.internalId,
                isInternal: recipe.isInternal,
                imageUrl: recipe.imageUrl,
                name: recipe.name,
                country: recipe.place ?? '',
                containsUserAllergens: recipe.containsUserAllergens,
                matchedAllergens: recipe.matchedAllergens,
              ),
            ],
          ),
        ),
      ),
    );
    expect(find.textContaining('Allergens:'), findsOneWidget);
    expect(find.textContaining('+'), findsOneWidget); // Should show '+N more' for >2 allergens
  });

  testWidgets('does not show allergen tag for recipes without allergens', (WidgetTester tester) async {
    final recipe = Recipe(
      id: 2,
      internalId: null,
      isInternal: false,
      name: 'Fruit Salad',
      imageUrl: '',
      place: 'Test',
      containsUserAllergens: false,
      matchedAllergens: [],
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ListView(
            children: [
              RecipeItem(
                id: recipe.id,
                internalId: recipe.internalId,
                isInternal: recipe.isInternal,
                imageUrl: recipe.imageUrl,
                name: recipe.name,
                country: recipe.place ?? '',
                containsUserAllergens: recipe.containsUserAllergens,
                matchedAllergens: recipe.matchedAllergens,
              ),
            ],
          ),
        ),
      ),
    );
    expect(find.textContaining('Allergens:'), findsNothing);
  });
} 