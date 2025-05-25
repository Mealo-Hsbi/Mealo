// lib/screens/profile_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '/services/api_client.dart';
import 'settings_screen.dart';
import 'achievements_overview_screen.dart';

class ProfileScreen extends StatelessWidget {
  ProfileScreen({super.key});

  // --- Mock-Daten ---
  final String _userName  = 'Max Mustermann';
  final String _userEmail = 'test@mealo.app';
  final String _avatarUrl = '';
  final List<String> _tags = ['Vegan', 'Glutenfrei', 'Low Carb', 'Proteinreich'];
  final int _recipesCount = 42;
  final int _rescuedCount = 128;
  final int _likesCount   = 354;
  final List<Map<String,String>> _recipePreview = [
    {'image':'https://via.placeholder.com/120x100.png?text=Salat','title':'Bunter Salat'},
    {'image':'https://via.placeholder.com/120x100.png?text=Pasta','title':'Avocado Pasta'},
    {'image':'https://via.placeholder.com/120x100.png?text=Stir-Fry','title':'Veggie Stir-Fry'},
  ];

  @override
  Widget build(BuildContext context) {
    final theme   = Theme.of(context);
    final primary = theme.colorScheme.primary;

    // Achievements mit Icon, Wert und Label
    final achievements = [
      {'icon': Icons.book,    'value': 10,  'label': 'Rezepte'},
      {'icon': Icons.star,    'value': 100, 'label': 'Likes'},
      {'icon': Icons.kitchen, 'value': 50,  'label': 'Zutaten gerettet'},
    ];

    Future<void> _signOut() async {
      await FirebaseAuth.instance.signOut();
      Navigator.of(context, rootNavigator: true).popUntil((r) => r.isFirst);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu),
            iconSize: 28,
            tooltip: 'Einstellungen',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
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
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: const [
                        BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0,2))
                      ],
                    ),
                    padding: const EdgeInsets.fromLTRB(16, 64, 16, 24),
                    child: Column(
                      children: [
                        Text(_userName, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(_userEmail, style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[600])),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 8, runSpacing: 6, alignment: WrapAlignment.center,
                          children: _tags.map((tag) {
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: primary),
                              ),
                              child: Text(tag, style: TextStyle(color: primary)),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildStat('Rezepte', _recipesCount, theme),
                            _buildStat('Zutaten gerettet', _rescuedCount, theme),
                            _buildStat('Likes', _likesCount, theme),
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
                      backgroundImage: _avatarUrl.isNotEmpty ? NetworkImage(_avatarUrl) : null,
                    ),
                  ),
                ],
              ),

              // Abstand reduziert
              const SizedBox(height: 16),

              // Achievements-Box
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Kopfzeile
                      Row(
                        children: [
                          Text('Achievements', style: theme.textTheme.titleLarge),
                          const Spacer(),
                          TextButton(
                            onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                              builder: (_) => const AchievementsOverviewScreen(),
                            )),
                            child: const Text('Alle ansehen'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: achievements.map((a) {
                          return Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(a['icon'] as IconData, size: 28, color: primary),
                                const SizedBox(height: 4),
                                Text(
                                  '${a['value']}',
                                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  a['label'] as String,
                                  style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),

              // Neuer Abstand
              const SizedBox(height: 16),

              // Meine Rezepte-Box
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Kopfzeile
                      Row(
                        children: [
                          Text('Meine Rezepte', style: theme.textTheme.titleLarge),
                          const Spacer(),
                          TextButton(onPressed: () {}, child: const Text('Alle ansehen')),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 140,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _recipePreview.length,
                          itemBuilder: (ctx, i) {
                            final r = _recipePreview[i];
                            return Container(
                              width: 120,
                              margin: EdgeInsets.only(right: i == _recipePreview.length - 1 ? 0 : 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.network(r['image']!, width: 120, height: 80, fit: BoxFit.cover),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(r['title']!, style: theme.textTheme.bodyMedium, overflow: TextOverflow.ellipsis),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStat(String label, int value, ThemeData theme) {
    return Column(
      children: [
        Text('$value', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600])),
      ],
    );
  }
}
