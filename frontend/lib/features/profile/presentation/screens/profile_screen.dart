import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../services/api_client.dart';
import '../../data/datasources/profile_remote_data_source.dart';
import '../../data/repositories/profile_repository_impl.dart';
import '../../domain/usecases/get_avatar.dart';
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
const double kChipHorizontalSpacing = 8.0;
const double kChipRunSpacing = 6.0;
const double kItemSpacing = 24.0;

class ProfileScreen extends StatelessWidget {
  ProfileScreen({Key? key}) : super(key: key);

  // --- Mock data ---
  final String _userName = 'Max Mustermann';
  final String _userEmail = 'test@mealo.app';
  final List<String> _tags = [
    'Vegan',
    'Gluten-free',
    'Low-carb',
    'Protein-rich',
  ];
  final int _recipesCount = 42;
  final int _rescuedCount = 128;
  final int _likesCount = 354;
  final List<Map<String, String>> _recipePreview = [
    {
      'image':
          'https://via.placeholder.com/120x100.png?text=Colorful%20Salad',
      'title': 'Colorful Salad',
    },
    {
      'image':
          'https://via.placeholder.com/120x100.png?text=Avocado%20Pasta',
      'title': 'Avocado Pasta',
    },
    {
      'image':
          'https://via.placeholder.com/120x100.png?text=Veggie%20Stir-Fry',
      'title': 'Veggie Stir-Fry',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ProfileViewModel>(
      create: (_) {
        final api = ApiClient();
        final remote = ProfileRemoteDataSourceImpl(api);
        final repo = ProfileRepositoryImpl(remote, api);
        final vm = ProfileViewModel(
          GetAvatarUrl(repo),
          UploadAvatar(repo),
        );
        vm.loadAvatar('avatars/initial.png');
        return vm;
      },
      child: Consumer<ProfileViewModel>(
        builder: (ctx, vm, _) {
          final theme = Theme.of(ctx);
          final primary = theme.colorScheme.primary;

          final achievements = [
            {'icon': Icons.book, 'value': 10, 'label': 'Recipes'},
            {'icon': Icons.star, 'value': 100, 'label': 'Likes'},
            {
              'icon': Icons.kitchen,
              'value': 50,
              'label': 'Ingredients Saved'
            },
          ];

          Future<void> _signOut() async {
            await FirebaseAuth.instance.signOut();
            Navigator.of(context, rootNavigator: true)
                .popUntil((r) => r.isFirst);
          }

          return Scaffold(
            backgroundColor: Colors.grey.shade100,
            appBar: AppBar(
              title: const Text('Profile'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.menu),
                  tooltip: 'Settings',
                  onPressed: () {
                    Navigator.of(context).push(
                      _createSlideRoute(const SettingsScreen()),
                    );
                  },
                ),
              ],
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: kItemSpacing),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Profile-Card & Avatar
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
                          kSectionPadding,
                          64,
                          kSectionPadding,
                          kSectionPadding,
                        ),
                        child: Column(
                          children: [
                            Text(
                              _userName,
                              style: theme.textTheme.titleLarge
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _userEmail,
                              style: theme.textTheme.bodyMedium
                                  ?.copyWith(color: Colors.grey[600]),
                            ),
                            const SizedBox(height: kItemSpacing),
                            Wrap(
                              spacing: kChipHorizontalSpacing,
                              runSpacing: kChipRunSpacing,
                              alignment: WrapAlignment.center,
                              children:
                                  _tags.map((t) => TagChip(t)).toList(),
                            ),
                            const SizedBox(height: kItemSpacing),
                            Row(
                              children: [
                                Expanded(
                                  child: StatItem(
                                      'Recipes', _recipesCount),
                                ),
                                Expanded(
                                  child: StatItem('Ingredients Saved',
                                      _rescuedCount),
                                ),
                                Expanded(
                                  child: StatItem('Likes', _likesCount),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        top: 0,
                        child: AvatarWidget(
                          url: vm.avatarUrl,
                          loading: vm.isLoading,
                          onTap: vm.pickAndUploadAvatar,
                        ),
                      ),
                    ],
                  ),

                  // Achievements
                  ProfileSection(
                    title: 'Achievements',
                    action: TextButton(
                      onPressed: () =>
                          Navigator.of(context).push(
                              _createSlideRoute(const AchievementsOverviewScreen())),
                      child: const Text('View All'),
                    ),
                    child: Row(
                      children: achievements.map((a) {
                        return Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(a['icon'] as IconData,
                                  size: 28, color: primary),
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
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  // My Pantry
                  ProfileSection(
                    title: 'My Pantry',
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: kSectionPadding),
                      leading:
                          const Icon(Icons.kitchen, size: 32),
                      title:
                          const Text('You currently have 7 items'),
                      trailing:
                          const Icon(Icons.chevron_right),
                      onTap: () => Navigator.of(context).push(
                          _createSlideRoute(const PantryScreen())),
                    ),
                  ),

                  // My Recipes
                  ProfileSection(
                    title: 'My Recipes',
                    action: TextButton(
                        onPressed: () {},
                        child: const Text('View All')),
                    child: SizedBox(
                      height: 140,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _recipePreview.length,
                        itemBuilder: (ctx, i) {
                          final r = _recipePreview[i];
                          return RecipePreviewItem(
                            imageUrl: r['image']!,
                            title: r['title']!,
                            isLast:
                                i == _recipePreview.length - 1,
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
      pageBuilder: (_, animation, __) =>
          page,
      transitionsBuilder:
          (_, animation, __, child) {
        final tween = Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero);
        return SlideTransition(
          position: tween.animate(
            CurvedAnimation(
                parent: animation, curve: Curves.easeInOut),
          ),
          child: child,
        );
      },
    );
  }
}

/// Full-width, white background, equal vertical margin
class ProfileSection extends StatelessWidget {
  final String title;
  final Widget? action;
  final Widget child;

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
              Text(title,
                  style: Theme.of(context).textTheme.titleLarge),
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

/// Restliche Widgets bleiben unverändert:
/// StatItem, TagChip, RecipePreviewItem
