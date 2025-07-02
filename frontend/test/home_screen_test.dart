import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/home/presentation/home_screen.dart';
import 'package:frontend/features/recipe/recipe_service.dart';
import 'package:mockito/mockito.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/core/config/app_config.dart';
import 'package:frontend/core/config/environment.dart';
import 'package:provider/provider.dart' as provider;
import 'package:frontend/features/profile/presentation/viewmodels/profile_viewmodel.dart';
import 'package:frontend/features/profile/domain/entities/profile_dto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Minimal mock ProfileViewModel
class MockProfileViewModel extends ChangeNotifier implements ProfileViewModel {
  @override
  ProfileDto? profile;
  @override
  bool isLoading = false;
  @override
  String? errorMessage;

  @override
  Future<void> loadProfile() async {}
  @override
  Future<void> pickAndUploadAvatar() async {}
  @override
  Future<void> uploadAvatar(dynamic file) async {}

  // Add a default constructor for the mock
  MockProfileViewModel();
}

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
    // testWidgets('Home screen renders', (WidgetTester tester) async {
    //   await mockNetworkImagesFor(() async {
    //     await tester.pumpWidget(
    //       ProviderScope(
    //         child: provider.ChangeNotifierProvider<ProfileViewModel>(
    //           create: (_) => MockProfileViewModel(),
    //           child: MaterialApp(
    //             home: const HomeScreen(),
    //           ),
    //         ),
    //       ),
    //     );
    //     await tester.pumpAndSettle();
    //     expect(find.byType(HomeScreen), findsOneWidget);
    //   });
    // });

    // testWidgets('Home screen shows navigation elements', (WidgetTester tester) async {
    //   await mockNetworkImagesFor(() async {
    //     await tester.pumpWidget(
    //       ProviderScope(
    //         child: provider.ChangeNotifierProvider<ProfileViewModel>(
    //           create: (_) => MockProfileViewModel(),
    //           child: MaterialApp(
    //             home: const HomeScreen(),
    //           ),
    //         ),
    //       ),
    //     );
    //     await tester.pumpAndSettle();
    //     expect(find.byType(AppBar), findsOneWidget);
    //   });
    // });

    // testWidgets('Home screen shows content area', (WidgetTester tester) async {
    //   await mockNetworkImagesFor(() async {
    //     await tester.pumpWidget(
    //       ProviderScope(
    //         child: provider.ChangeNotifierProvider<ProfileViewModel>(
    //           create: (_) => MockProfileViewModel(),
    //           child: MaterialApp(
    //             home: const HomeScreen(),
    //           ),
    //         ),
    //       ),
    //     );
    //     await tester.pumpAndSettle();
    //     expect(find.byType(Scaffold), findsOneWidget);
    //   });
    // });
  });
} 