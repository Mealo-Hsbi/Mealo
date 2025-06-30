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
import '../screens/settings_screen.dart';
import 'package:frontend/features/recipe/presentation/screens/recipe_list_screen.dart';
import 'package:frontend/features/recipe/presentation/screens/recipe_detail_screen.dart';
import 'package:frontend/features/recipe/presentation/screens/user_recipe_list_screen.dart';

const double kSectionSpacing = 6.0;
const double kSectionPadding = 16.0;
const double kHeaderHeight = 240.0;
const double kAvatarRadius = 48.0;

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileViewModel>(
      builder: (ctx, vm, _) {
        if (vm.profile == null && !vm.isLoading) {
          vm.loadProfile();
        }
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
                SizedBox(
                  height: kHeaderHeight,
                  width: double.infinity,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (profile.avatarUrl != null)
                        Image.network(
                          profile.avatarUrl!,
                          key: UniqueKey(),
                          fit: BoxFit.cover,
                          headers: {
                            'Cache-Control': 'no-cache',
                            'Pragma': 'no-cache',
                            'Expires': '0',
                          },
                        ),
                      BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                        child: Container(color: Colors.black.withOpacity(0.2)),
                      ),
                    ],
                  ),
                ),
                Transform.translate(
                  offset: const Offset(0, -kAvatarRadius),
                  child: Column(
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.topCenter,
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.fromLTRB(
                              kSectionPadding,
                              kAvatarRadius + kSectionSpacing,
                              kSectionPadding,
                              kSectionPadding,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surface,
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(24),
                              ),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  profile.name,
                                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                                ),
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
                                    StatItem('Favorites', profile.favoritesCount),
                                    const SizedBox(width: 24),
                                    StatItem('Achievements', profile.achievements.length),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                            top: -kAvatarRadius,
                            child: AvatarWidget(
                              key: UniqueKey(),
                              url: profile.avatarUrl,
                              loading: vm.isLoading,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: kSectionSpacing),

                      // Rezepte-Sektion mit Fallback
                      ProfileSection(
                        title: 'My Recipes',
                        action: TextButton(
                          onPressed: () => Navigator.of(context).push(
                            _createSlideRoute(const UserRecipeListScreen()),
                          ),
                          child: const Text('View All'),
                        ),
                        child: recent.isNotEmpty
                            ? GridView.count(
                                crossAxisCount: 3,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                                childAspectRatio: 3 / 4,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                children: recent.map((r) => RecipePreviewItem(
                                  imageUrl: r.imageUrl,
                                  title: r.title,
                                  onTap: () {
                                    if ((r.internalId ?? '').isNotEmpty) {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) => RecipeDetailScreen(
                                            initialImageUrl: r.imageUrl,
                                            initialName: r.title,
                                            initialPlace: '',
                                            isInternal: true,
                                            internalRecipeId: r.internalId,
                                          ),
                                        ),
                                      );
                                    } else if (r.spoonacularId != null && r.spoonacularId!.isNotEmpty) {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) => RecipeDetailScreen(
                                            initialImageUrl: r.imageUrl,
                                            initialName: r.title,
                                            initialPlace: '',
                                            isInternal: false,
                                            recipeId: int.tryParse(r.spoonacularId!),
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                )).toList(),
                              )
                            : const _EmptyStateWidget(
                                icon: Icons.no_food,
                                message: 'Du hast noch keine Rezepte erstellt.',
                              ),
                      ),

                      // Achievements-Sektion mit Fallback
                      ProfileSection(
                        title: 'Achievements',
                        action: TextButton(
                          onPressed: () => Navigator.of(context).push(
                            _createSlideRoute(const AchievementsOverviewScreen()),
                          ),
                          child: const Text('View All'),
                        ),
                        child: achievements.isNotEmpty
                            ? GridView.count(
                                crossAxisCount: 3,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                children: achievements.map((a) => AchievementCard(achievement: a)).toList(),
                              )
                            : const _EmptyStateWidget(
                                icon: Icons.emoji_events_outlined,
                                message: 'Du hast noch keine Erfolge erreicht.',
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

class _EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String message;

  const _EmptyStateWidget({
    Key? key,
    required this.icon,
    required this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 40, color: Colors.grey),
            const SizedBox(height: 8),
            Text(message, style: TextStyle(color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }
}
