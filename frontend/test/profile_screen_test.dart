import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:frontend/features/profile/presentation/screens/profile_screen.dart';
import 'package:frontend/features/profile/presentation/viewmodels/profile_viewmodel.dart';
import 'package:frontend/features/profile/presentation/providers/achievement_provider.dart';
import 'package:frontend/features/profile/domain/entities/profile_dto.dart';
import 'package:frontend/features/profile/domain/entities/profile_dto.dart' as dto;
import 'package:frontend/features/profile/domain/entities/profile_dto.dart' show AchievementDto, RecipePreviewDto, ProfileDto;
import 'package:frontend/features/profile/domain/entities/achievement.dart';
import 'package:network_image_mock/network_image_mock.dart';

class MockProfileViewModel extends ChangeNotifier implements ProfileViewModel {
  @override
  bool isLoading = false;
  @override
  ProfileDto? profile = ProfileDto(
    id: '1',
    name: 'Test User',
    email: 'test@example.com',
    tags: ['Vegan'],
    recipesCount: 2,
    favoritesCount: 1,
    likesCount: 0,
    avatarUrl: 'https://via.placeholder.com/150',
    pantryCount: 0,
    recentRecipes: [
      RecipePreviewDto(
        id: 'r1',
        internalId: 'abc',
        spoonacularId: null,
        imageUrl: 'https://via.placeholder.com/150',
        title: 'Mein Rezept',
      ),
    ],
    achievements: [
      AchievementDto(
        key: 'a1',
        title: 'Test Achievement',
        description: 'Test Desc',
        icon: '',
      ),
    ],
  );
  @override
  Future<void> loadProfile() async {}
  @override
  Future<void> pickAndUploadAvatar() async {}
  @override
  Future<void> uploadAvatar(_) async {}
}

class MockAchievementProvider extends ChangeNotifier implements AchievementProvider {
  final List<Achievement> _achievements = [
    Achievement(
      id: '1',
      key: 'a1',
      title: 'Test Achievement',
      description: 'Test Desc',
      icon: '',
      unlocked: true,
    ),
  ];
  @override
  AchievementStatus get status => AchievementStatus.loaded;
  @override
  List<Achievement> get achievements => _achievements;
  @override
  int get unlockedCount => _achievements.where((a) => a.unlocked).length;
  @override
  int get totalCount => _achievements.length;
  @override
  String? get errorMessage => null;
  @override
  bool get isLoading => false;
  @override
  Future<void> loadAchievements() async {}
  @override
  Future<void> refreshAchievements() async {}
  @override
  void reset() {}
  @override
  Achievement? getAchievementById(String id) {
    try {
      return _achievements.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }
  @override
  Achievement? getAchievementByKey(String key) {
    try {
      return _achievements.firstWhere((a) => a.key == key);
    } catch (_) {
      return null;
    }
  }
}

void main() {
  Widget buildTestWidget() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ProfileViewModel>(create: (_) => MockProfileViewModel()),
        ChangeNotifierProvider<AchievementProvider>(create: (_) => MockAchievementProvider()),
      ],
      child: const MaterialApp(home: ProfileScreen()),
    );
  }

  testWidgets('Achievements und eigene Rezepte werden angezeigt', (WidgetTester tester) async {
    await mockNetworkImagesFor(() async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();
      expect(find.text('Test User'), findsOneWidget);
      expect(find.text('Mein Rezept'), findsOneWidget);
      expect(find.text('Test Achievement'), findsOneWidget);
    });
  });

  testWidgets('Klick auf "View All" bei Rezepten navigiert', (WidgetTester tester) async {
    await mockNetworkImagesFor(() async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();
      final recipesSection = find.ancestor(
        of: find.text('My Recipes'),
        matching: find.byType(Container),
      );
      final viewAllButton = find.descendant(
        of: recipesSection,
        matching: find.widgetWithText(TextButton, 'View All'),
      );
      expect(viewAllButton, findsOneWidget);
      await tester.tap(viewAllButton);
      await tester.pumpAndSettle();
    });
  });
} 