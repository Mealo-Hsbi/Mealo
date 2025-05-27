// lib/features/profile/presentation/screens/profile_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
import '../screens/achievements_overview_screen.dart';
import '../screens/pantry_screen.dart';
import '../screens/settings_screen.dart';

const double kSectionSpacing = 8.0;
const double kSectionPadding = 16.0;
const double kItemSpacing = 24.0;

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ProfileViewModel>(
      create: (_) {
        final api    = ApiClient();
        final remote = ProfileRemoteDataSourceImpl(api);
        final repo   = ProfileRepositoryImpl(remote, api);
        final vm     = ProfileViewModel(
          GetProfile(repo),
          UploadAvatar(repo),
        );
        vm.loadProfile(); 
        return vm;
      },
      child: Consumer<ProfileViewModel>(
        builder: (ctx, vm, _) {
          final theme = Theme.of(ctx);

          // Loading
          if (vm.isLoading && vm.profile == null) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          final profile = vm.profile!;

          // Achievements-Daten
          final achievements = [
            {'icon': Icons.book,   'value': profile.recipesCount,   'label': 'Recipes'},
            {'icon': Icons.star,   'value': profile.likesCount,     'label': 'Likes'},
            {'icon': Icons.kitchen,'value': profile.favoritesCount, 'label': 'Favorites'},
          ];

          // Drei neueste Rezepte
          final recent = profile.recentRecipes.take(3).toList();

          return Scaffold(
            backgroundColor: Colors.grey.shade100,
            appBar: AppBar(
              title: const Text('Profile'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.menu),
                  tooltip: 'Settings',
                  onPressed: () => Navigator.of(context).push(
                    _createSlideRoute(const SettingsScreen()),
                  ),
                ),
              ],
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: kItemSpacing),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Profil-Card & Avatar
                  Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.topCenter,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 48),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(24),
                            topRight: Radius.circular(24),
                          ),
                        ),
                        padding: const EdgeInsets.fromLTRB(
                          kSectionPadding, 64, kSectionPadding, kSectionPadding),
                        child: Column(
                          children: [
                            Text(
                              profile.name,
                              style: theme.textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              profile.email,
                              style: theme.textTheme.bodyMedium
                                ?.copyWith(color: Colors.grey[600]),
                            ),
                            const SizedBox(height: kSectionSpacing),
                            Wrap(
                              spacing: kSectionSpacing,
                              children: profile.tags
                                .map((t) => TagChip(t))
                                .toList(),
                            ),
                            const SizedBox(height: kSectionSpacing),
                            Row(
                              children: achievements.map((a) {
                                return Expanded(
                                  child: StatItem(
                                    a['label'] as String,
                                    a['value'] as int,
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        top: 0,
                        child: AvatarWidget(
                          url: profile.avatarUrl,
                          loading: vm.isLoading,
                          onTap: vm.pickAndUploadAvatar,
                        ),
                      ),
                    ],
                  ),

                  // Achievements (Icons + Werte)
                  ProfileSection(
                    title: 'Achievements',
                    action: TextButton(
                      onPressed: () => Navigator.of(context).push(
                        _createSlideRoute(const AchievementsOverviewScreen()),
                      ),
                      child: const Text('View All'),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: achievements.map((a) {
                        return Column(
                          children: [
                            Icon(a['icon'] as IconData, size: 28),
                            const SizedBox(height: 4),
                            Text(
                              '${a['value']}',
                              style: theme.textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              a['label'] as String,
                              style: theme.textTheme.bodySmall
                                ?.copyWith(color: Colors.grey[600]),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),

                  // My Pantry
                  ProfileSection(
                    title: 'My Pantry',
                    child: ListTile(
                      leading: const Icon(Icons.kitchen, size: 32),
                      title: const Text('You have X items'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.of(context).push(
                        _createSlideRoute(const PantryScreen()),
                      ),
                    ),
                  ),

                  // Drei neueste Rezepte
                  ProfileSection(
                    title: 'Recent Recipes',
                    child: SizedBox(
                      height: 140,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: recent.length,
                        itemBuilder: (ctx, i) {
                          final r = recent[i];
                          return RecipePreviewItem(
                            imageUrl: r.imageUrl,
                            title: r.title,
                            isLast: i == recent.length - 1,
                          );
                        },
                      ),
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

/// Full-width, white background, equal vertical margin
class ProfileSection extends StatelessWidget {
  final String  title;
  final Widget? action;
  final Widget  child;

  const ProfileSection({
    Key? key,
    required this.title,
    this.action,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: kSectionSpacing),
      padding: const EdgeInsets.all(kSectionPadding),
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(title, style: Theme.of(context).textTheme.titleLarge),
              const Spacer(),
              if (action != null) action!,
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
