import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/home/presentation/home_screen.dart';
import 'package:frontend/features/recipe/recipe_service.dart';
import 'package:mockito/mockito.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/core/config/app_config.dart';
import 'package:frontend/core/config/environment.dart';

class MockRecipeService extends Mock implements RecipeService {}

void main() {
  setUpAll(() {
    dotenv.testLoad();
    dotenv.env['API_BASE_URL'] = 'http://localhost:3000/api';
    dotenv.env['SPOONACULAR_API_KEY'] = 'test-key';
    
    // Initialize AppConfig
    AppConfig.init(Environment.dev);
  });

  group('Home Screen Tests', () {
    testWidgets('Home screen renders', (WidgetTester tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(
          MaterialApp(
            home: const HomeScreen(),
          ),
        );
        await tester.pumpAndSettle();

        // Sollte den HomeScreen rendern
        expect(find.byType(HomeScreen), findsOneWidget);
      });
    });

    testWidgets('Home screen shows navigation elements', (WidgetTester tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(
          MaterialApp(
            home: const HomeScreen(),
          ),
        );
        await tester.pumpAndSettle();

        // Should show navigation elements
        expect(find.byType(AppBar), findsOneWidget);
      });
    });

    testWidgets('Home screen shows content area', (WidgetTester tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(
          MaterialApp(
            home: const HomeScreen(),
          ),
        );
        await tester.pumpAndSettle();

        // Should show content area
        expect(find.byType(Scaffold), findsOneWidget);
      });
    });
  });
} 