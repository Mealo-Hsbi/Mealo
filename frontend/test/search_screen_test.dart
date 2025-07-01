import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/search/presentation/screens/search_screen.dart';
import 'package:frontend/features/search/presentation/provider/search_notifier.dart';
import 'package:frontend/features/search/domain/usecases/search_recipes_by_query.dart';
import 'package:frontend/features/search/domain/usecases/search_recipes_by_ingredients.dart';
import 'package:frontend/features/search/domain/repositories/recipe_repository.dart';
import 'package:frontend/common/models/recipe.dart';
import 'package:frontend/common/models/recipe/recipe_details.dart';
import 'package:frontend/providers/selected_ingredients_provider.dart';
import 'package:dio/dio.dart';
import 'package:provider/provider.dart';
import 'package:network_image_mock/network_image_mock.dart';

class DummyRecipeRepository implements RecipeRepository {
  @override
  Future<List<Recipe>> searchRecipesByQuery({
    required String query,
    int offset = 0,
    int number = 10,
    String? sortBy,
    String? sortDirection,
    Map<String, dynamic>? filters,
    CancelToken? cancelToken,
  }) async {
    return [];
  }

  @override
  Future<List<Recipe>> searchRecipesByIngredients({
    required List<String> ingredients,
    int offset = 0,
    int number = 10,
    int? maxMissingIngredients,
    CancelToken? cancelToken,
  }) async {
    return [];
  }

  @override
  Future<RecipeDetails> getRecipeDetails(int recipeId, {CancelToken? cancelToken}) async {
    throw UnimplementedError();
  }

  @override
  Future<RecipeDetails> getInternalRecipeDetails(String internalRecipeId, {CancelToken? cancelToken}) async {
    throw UnimplementedError();
  }
}

void main() {
  final dummyRepo = DummyRecipeRepository();
  group('Search Screen Tests', () {
    testWidgets('Search screen displays correctly', (WidgetTester tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(
          MaterialApp(
            home: MultiProvider(
              providers: [
                ChangeNotifierProvider<SelectedIngredientsProvider>(create: (_) => SelectedIngredientsProvider()),
                ChangeNotifierProvider<SearchNotifier>(
                  create: (_) => SearchNotifier(
                    searchRecipesByQueryUsecase: SearchRecipesByQuery(dummyRepo),
                    searchRecipesByIngredientsUsecase: SearchRecipesByIngredients(dummyRepo),
                  ),
                ),
              ],
              child: const SearchScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Should show search interface
        expect(find.byType(TextField), findsOneWidget);
        expect(find.text('Search for recipes or ingredients...'), findsOneWidget);
      });
    });

    testWidgets('Search screen shows search bar', (WidgetTester tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(
          MaterialApp(
            home: MultiProvider(
              providers: [
                ChangeNotifierProvider<SelectedIngredientsProvider>(create: (_) => SelectedIngredientsProvider()),
                ChangeNotifierProvider<SearchNotifier>(
                  create: (_) => SearchNotifier(
                    searchRecipesByQueryUsecase: SearchRecipesByQuery(dummyRepo),
                    searchRecipesByIngredientsUsecase: SearchRecipesByIngredients(dummyRepo),
                  ),
                ),
              ],
              child: const SearchScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(TextField), findsOneWidget);
        expect(find.text('Search for recipes or ingredients...'), findsOneWidget);
      });
    });

    testWidgets('Search screen shows search button', (WidgetTester tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(
          MaterialApp(
            home: MultiProvider(
              providers: [
                ChangeNotifierProvider<SelectedIngredientsProvider>(create: (_) => SelectedIngredientsProvider()),
                ChangeNotifierProvider<SearchNotifier>(
                  create: (_) => SearchNotifier(
                    searchRecipesByQueryUsecase: SearchRecipesByQuery(dummyRepo),
                    searchRecipesByIngredientsUsecase: SearchRecipesByIngredients(dummyRepo),
                  ),
                ),
              ],
              child: const SearchScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.search), findsOneWidget);
      });
    });

    testWidgets('Search screen allows text input', (WidgetTester tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(
          MaterialApp(
            home: MultiProvider(
              providers: [
                ChangeNotifierProvider<SelectedIngredientsProvider>(create: (_) => SelectedIngredientsProvider()),
                ChangeNotifierProvider<SearchNotifier>(
                  create: (_) => SearchNotifier(
                    searchRecipesByQueryUsecase: SearchRecipesByQuery(dummyRepo),
                    searchRecipesByIngredientsUsecase: SearchRecipesByIngredients(dummyRepo),
                  ),
                ),
              ],
              child: const SearchScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Enter search text
        await tester.enterText(find.byType(TextField), 'pasta');
        await tester.pumpAndSettle();

        expect(find.text('pasta'), findsOneWidget);
      });
    });
  });
} 