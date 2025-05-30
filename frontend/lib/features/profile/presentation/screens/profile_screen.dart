import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../services/api_client.dart';
import '../../data/datasources/profile_remote_data_source.dart';
import '../../data/repositories/profile_repository_impl.dart';
import '../../domain/usecases/get_profile.dart';
import '../../domain/usecases/upload_avatar.dart';
import '../viewmodels/profile_viewmodel.dart';
import '../widgets/avatar_widget.dart';
import '../widgets/recipe_preview_item.dart';
import '../widgets/stat_item.dart';
import '../widgets/tag_chip.dart';
import '../widgets/achievement_card.dart';
import '../screens/achievements_overview_screen.dart';
import '../screens/pantry_screen.dart';
import '../screens/settings_screen.dart';
import 'package:frontend/features/recipeList/recipe_list_screen.dart';

const double kSectionSpacing = 6.0;
const double kSectionPadding = 16.0;
const double kHeaderHeight = 240.0;
const double kAvatarRadius = 48.0;

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ProfileViewModel>(
      create: (_) {
        final api = ApiClient();
        final remote = ProfileRemoteDataSourceImpl(api);
        final repo = ProfileRepositoryImpl(remote, api);
        final vm = ProfileViewModel(GetProfile(repo), UploadAvatar(repo));
        vm.loadProfile();
        return vm;
      },
      child: Consumer<ProfileViewModel>(
        builder: (ctx, vm, _) {
          final theme = Theme.of(ctx);

          if (vm.isLoading && vm.profile == null) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }

          final profile = vm.profile!;
          final recent = profile.recentRecipes.take(3).toList();
          final achievements = profile.achievements.take(3).toList();

          return Scaffold(
            backgroundColor: Colors.grey.shade100,
            appBar: AppBar(
              title: const Text('Profile'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () => Navigator.of(context).push(
                    _createSlideRoute(const SettingsScreen()),
                  ),
                ),
              ],
            ),
            body: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 🔝 Headerbild
                  SizedBox(
                    height: kHeaderHeight,
                    width: double.infinity,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        if (profile.avatarUrl != null)
                          Image.network(profile.avatarUrl!, fit: BoxFit.cover),
                        BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                          child: Container(color: Colors.black.withOpacity(0.2)),
                        ),
                      ],
                    ),
                  ),

                  // 👤 Profilkarte mit Avatar
                  Transform.translate(
                    offset: Offset(0, -kAvatarRadius),
                    child: Column(
                      children: [
                        Stack(
                          clipBehavior: Clip.none,
                          alignment: Alignment.topCenter,
                          children: [
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.fromLTRB(
                                kSectionPadding, kAvatarRadius + kSectionSpacing,
                                kSectionPadding, kSectionPadding),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surface,
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(24),
                                ),
                              ),
                              child: Column(
                                children: [
                                  Text(profile.name,
                                      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                                  const SizedBox(height: kSectionSpacing),
                                  Wrap(
                                    spacing: kSectionSpacing,
                                    children: profile.tags.take(3).map((t) => TagChip(t)).toList(),
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      StatItem('Recipes', profile.recipesCount),
                                      const SizedBox(width: 24),
                                      StatItem('Likes', profile.likesCount),
                                      const SizedBox(width: 24),
                                      StatItem('Favorites', profile.favoritesCount),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Positioned(
                              top: -kAvatarRadius,
                              child: AvatarWidget(
                                url: profile.avatarUrl,
                                loading: vm.isLoading,
                                onTap: vm.pickAndUploadAvatar,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: kSectionSpacing),

                        // 🍽️ My Recipes
                        ProfileSection(
                          title: 'My Recipes',
                          action: TextButton(
                            onPressed: () => Navigator.of(context).push(
                                _createSlideRoute(const RecipeListScreen())),
                            child: const Text('View All'),
                          ),
                          child: GridView.count(
                            crossAxisCount: 3,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 3 / 4,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            children: recent.map((r) => RecipePreviewItem(
                              imageUrl: r.imageUrl,
                              title: r.title,
                            )).toList(),
                          ),
                        ),

                        // 🧺 My Pantry
                        ProfileSection(
                          title: 'My Pantry',
                          child: ListTile(
                            leading: const Icon(Icons.kitchen, size: 32),
                            title: const Text('You have X items'),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () => Navigator.of(context).push(
                                _createSlideRoute(const PantryScreen())),
                          ),
                        ),

                        // 🏆 Achievements (letzte Section)
                        ProfileSection(
                          title: 'Achievements',
                          action: TextButton(
                            onPressed: () => Navigator.of(context).push(
                                _createSlideRoute(const AchievementsOverviewScreen())),
                            child: const Text('View All'),
                          ),
                          child: GridView.count(
                            crossAxisCount: 3,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            children: achievements.map((a) => AchievementCard(achievement: a)).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Route _createSlideRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (_, anim, __) => page,
      transitionsBuilder: (_, anim, __, child) => SlideTransition(
        position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
            .animate(CurvedAnimation(parent: anim, curve: Curves.easeInOut)),
        child: child,
      ),
    );
  }
}

class ProfileSection extends StatelessWidget {
  final String title;
  final Widget? action;
  final Widget child;

  const ProfileSection({Key? key, required this.title, this.action, required this.child})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: kSectionSpacing),
      padding: const EdgeInsets.all(kSectionPadding),
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const Spacer(),
            if (action != null) action!,
          ]),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
