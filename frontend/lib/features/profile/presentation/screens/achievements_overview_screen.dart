import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/achievement_provider.dart';
import '../../domain/entities/achievement.dart';
import '../widgets/achievement_card.dart';

class AchievementsOverviewScreen extends StatefulWidget {
  const AchievementsOverviewScreen({super.key});

  @override
  State<AchievementsOverviewScreen> createState() => _AchievementsOverviewScreenState();
}

class _AchievementsOverviewScreenState extends State<AchievementsOverviewScreen> {
  @override
  void initState() {
    super.initState();
    // Lade Achievements beim ersten Laden
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AchievementProvider>().loadAchievements();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('All Achievements'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<AchievementProvider>().refreshAchievements();
            },
          ),
        ],
      ),
      body: Consumer<AchievementProvider>(
        builder: (context, achievementProvider, child) {
          switch (achievementProvider.status) {
            case AchievementStatus.initial:
            case AchievementStatus.loading:
              return const Center(
                child: CircularProgressIndicator(),
              );
            
            case AchievementStatus.error:
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading achievements',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      achievementProvider.errorMessage ?? 'Unknown error',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        achievementProvider.refreshAchievements();
                      },
                      child: const Text('Try again'),
                    ),
                  ],
                ),
              );
            
            case AchievementStatus.loaded:
              final achievements = achievementProvider.achievements;
              
              if (achievements.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.emoji_events_outlined,
                        size: 64,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No achievements available',
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'There are no achievements available yet.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }

              return Column(
                children: [
                  // Achievement Progress Header
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Progress',
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${achievementProvider.unlockedCount} of ${achievementProvider.totalCount} unlocked',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 12),
                        LinearProgressIndicator(
                          value: achievementProvider.totalCount > 0 
                              ? achievementProvider.unlockedCount / achievementProvider.totalCount 
                              : 0,
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Achievements List
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: achievements.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (ctx, i) {
                        final achievement = achievements[i];
                        return _buildAchievementTile(achievement, theme);
                      },
                    ),
                  ),
                ],
              );
          }
        },
      ),
    );
  }

  Widget _buildAchievementTile(Achievement achievement, ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Icon(
          getAchievementIcon(achievement.icon),
          size: 32,
          color: achievement.unlocked 
              ? theme.colorScheme.primary
              : Colors.grey[400],
        ),
        title: Text(
          achievement.title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: achievement.unlocked 
                ? theme.colorScheme.onSurface
                : Colors.grey[600],
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              achievement.description,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: achievement.unlocked 
                    ? theme.colorScheme.onSurface.withOpacity(0.7)
                    : Colors.grey[500],
              ),
            ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: achievement.unlocked 
                ? theme.colorScheme.primary
                : Colors.grey[300],
            shape: BoxShape.circle,
          ),
          child: Icon(
            achievement.unlocked 
                ? Icons.check
                : Icons.lock,
            color: achievement.unlocked 
                ? Colors.white
                : Colors.grey[600],
            size: 20,
          ),
        ),
      ),
    );
  }
}
