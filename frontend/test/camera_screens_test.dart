import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/camera/presentation/screens/camera_screen.dart';
import 'package:frontend/features/camera/presentation/widgets/camera_view.dart';
import 'package:frontend/features/camera/presentation/widgets/camera_controls.dart';
import 'package:frontend/features/camera/presentation/screens/ingredient_review_screen.dart';
import 'package:frontend/common/models/ingredient.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/core/config/app_config.dart';
import 'package:frontend/core/config/environment.dart';

void main() {
  setUpAll(() {
    dotenv.testLoad();
    dotenv.env['API_BASE_URL'] = 'http://localhost:3000/api';
    dotenv.env['SPOONACULAR_API_KEY'] = 'test-key';
    
    // Initialize AppConfig
    AppConfig.init(Environment.dev);
  });

  group('Camera Screen Tests', () {
    testWidgets('Camera screen displays correctly', (WidgetTester tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(
          MaterialApp(
            home: const CameraScreen(isVisible: true),
          ),
        );
        await tester.pumpAndSettle();

        // Should show camera interface
        expect(find.byType(CameraScreen), findsOneWidget);
        expect(find.byType(CameraView), findsOneWidget);
      });
    });

    testWidgets('Camera screen shows camera controls', (WidgetTester tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(
          MaterialApp(
            home: const CameraScreen(isVisible: true),
          ),
        );
        await tester.pumpAndSettle();

        // Should show camera controls
        expect(find.byType(CameraControls), findsOneWidget);
      });
    });
  });

  group('Ingredient Review Screen Tests', () {
    testWidgets('Ingredient review screen displays correctly', (WidgetTester tester) async {
      await mockNetworkImagesFor(() async {
        final ingredients = [
          Ingredient(id: '1', name: 'tomato', imageUrl: null),
          Ingredient(id: '2', name: 'onion', imageUrl: null),
        ];

        await tester.pumpWidget(
          MaterialApp(
            home: IngredientReviewScreen(ingredients: ingredients),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Review Ingredients'), findsOneWidget);
        expect(find.text('We recognized the following ingredients:'), findsOneWidget);
        expect(find.text('tomato'), findsOneWidget);
        expect(find.text('onion'), findsOneWidget);
      });
    });

    testWidgets('Ingredient review screen shows find recipes button', (WidgetTester tester) async {
      await mockNetworkImagesFor(() async {
        final ingredients = [
          Ingredient(id: '1', name: 'tomato', imageUrl: null),
        ];

        await tester.pumpWidget(
          MaterialApp(
            home: IngredientReviewScreen(ingredients: ingredients),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Find Recipes!'), findsOneWidget);
      });
    });

    testWidgets('Ingredient review screen handles empty ingredients', (WidgetTester tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(
          MaterialApp(
            home: IngredientReviewScreen(ingredients: []),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Review Ingredients'), findsOneWidget);
        expect(find.text('We recognized the following ingredients:'), findsOneWidget);
        expect(find.text('Find Recipes!'), findsOneWidget);
      });
    });

    testWidgets('Ingredient review screen shows ingredients with images', (WidgetTester tester) async {
      await mockNetworkImagesFor(() async {
        final ingredients = [
          Ingredient(id: '1', name: 'tomato', imageUrl: 'assets/images/ingredients/tomato.webp'),
        ];

        await tester.pumpWidget(
          MaterialApp(
            home: IngredientReviewScreen(ingredients: ingredients),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('tomato'), findsOneWidget);
        expect(find.byType(Image), findsOneWidget);
      });
    });
  });
} 