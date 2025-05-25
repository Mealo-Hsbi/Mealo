import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '/services/api_client.dart';
import 'achievements_overview_screen.dart';
import 'pantry_screen.dart';
import 'settings_screen.dart';

const double kSectionSpacing = 8.0;

class ProfileScreen extends StatelessWidget {
  ProfileScreen({Key? key}) : super(key: key);

  // --- Mock data ---
  final String _userName = 'Max Mustermann';
  final String _userEmail = 'test@mealo.app';
  final String _avatarUrl = '';
  final List<String> _tags = [
    'Vegan',
    'Gluten-free',
    'Low-carb',
    'Protein-rich'
  ];
  final int _recipesCount = 42;
  final int _rescuedCount = 128;
  final int _likesCount = 354;
  final List<Map<String, String>> _recipePreview = [
    {
      'image': 'https://via.placeholder.com/120x100.png?text=Colorful%20Salad',
      'title': 'Colorful Salad',
    },
    {
      'image': 'https://via.placeholder.com/120x100.png?text=Avocado%20Pasta',
      'title': 'Avocado Pasta',
    },
    {
      'image': 'https://via.placeholder.com/120x100.png?text=Veggie%20Stir-Fry',
      'title': 'Veggie Stir-Fry',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    final achievements = [
      {'icon': Icons.book, 'value': 10, 'label': 'Recipes'},
      {'icon': Icons.star, 'value': 100, 'label': 'Likes'},
      {'icon': Icons.kitchen, 'value': 50, 'label': 'Ingredients Saved'},
    ];

    Future<void> _signOut() async {
      await FirebaseAuth.instance.signOut();
      Navigator.of(context, rootNavigator: true).popUntil((r) => r.isFirst);
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
              Navigator.of(context)
                  .push(_createSlideRoute(const SettingsScreen()));
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Profile card & avatar
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
                  padding: const EdgeInsets.fromLTRB(16, 64, 16, 24),
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
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        alignment: WrapAlignment.center,
                        children: _tags.map((t) => TagChip(t)).toList(),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          StatItem('Recipes', _recipesCount),
                          StatItem('Ingredients Saved', _rescuedCount),
                          StatItem('Likes', _likesCount),
                        ],
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 0,
                  child: CircleAvatar(
                    radius: 48,
                    backgroundColor: primary,
                    backgroundImage:
                        _avatarUrl.isNotEmpty ? NetworkImage(_avatarUrl) : null,
                  ),
                ),
              ],
            ),

            // Achievements section
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
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(a['icon'] as IconData, size: 28, color: primary),
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

            // My Pantry section
            ProfileSection(
              title: 'My Pantry',
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                leading: const Icon(Icons.kitchen, size: 32),
                title: const Text('You currently have 7 items'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context)
                    .push(_createSlideRoute(const PantryScreen())),
              ),
            ),

            // My Recipes section
            ProfileSection(
              title: 'My Recipes',
              action:
                  TextButton(onPressed: () {}, child: const Text('View All')),
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
                      isLast: i == _recipePreview.length - 1,
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Route _createSlideRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (_, animation, __) => page,
      transitionsBuilder: (_, animation, __, child) {
        final tween =
            Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero);
        return SlideTransition(
          position: tween.animate(
            CurvedAnimation(parent: animation, curve: Curves.easeInOut),
          ),
          child: child,
        );
      },
    );
  }
}

/// Full-width, white, no radius (except on profile card), spacing via kSectionSpacing
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
      margin: const EdgeInsets.only(top: kSectionSpacing),
      padding: const EdgeInsets.all(16),
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

class StatItem extends StatelessWidget {
  final String label;
  final int value;

  const StatItem(this.label, this.value, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$value',
          style: t.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(label, style: t.textTheme.bodySmall?.copyWith(color: Colors.grey[600])),
      ],
    );
  }
}

class TagChip extends StatelessWidget {
  final String tag;

  const TagChip(this.tag, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).colorScheme.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: p.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(tag, style: TextStyle(color: p)),
    );
  }
}

class RecipePreviewItem extends StatelessWidget {
  final String imageUrl;
  final String title;
  final bool isLast;

  const RecipePreviewItem({
    Key? key,
    required this.imageUrl,
    required this.title,
    this.isLast = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      margin: EdgeInsets.only(right: isLast ? 0 : 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              Uri.encodeFull(imageUrl),
              width: 120,
              height: 80,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 120,
                height: 80,
                color: Colors.grey[200],
                child: const Icon(Icons.broken_image, color: Colors.grey),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
