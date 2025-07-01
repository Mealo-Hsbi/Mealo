import 'package:flutter/material.dart';
import '../../domain/entities/achievement.dart';

IconData getAchievementIcon(String? iconKey) {
  switch (iconKey) {
    case 'restaurant':
      return Icons.restaurant;
    case 'camera_alt':
      return Icons.camera_alt;
    case 'favorite':
      return Icons.favorite;
    case 'star':
      return Icons.star;
    case 'star_rate':
      return Icons.star_rate;
    case 'rate_review':
      return Icons.rate_review;
    case 'chef':
      return Icons.emoji_food_beverage;
    case 'edit_note':
      return Icons.edit_note;
    case 'share':
      return Icons.share;
    case 'campaign':
      return Icons.campaign;
    default:
      return Icons.emoji_events;
  }
}

class AchievementCard extends StatelessWidget {
  final Achievement achievement;

  const AchievementCard({Key? key, required this.achievement}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      clipBehavior: Clip.hardEdge,
      child: Container(
        decoration: BoxDecoration(
          color: achievement.unlocked 
              ? theme.colorScheme.primary.withOpacity(0.1)
              : Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                getAchievementIcon(achievement.icon),
                size: 28,
                color: achievement.unlocked ? theme.colorScheme.primary : Colors.grey[600],
              ),
              const SizedBox(height: 6),
              Text(
                achievement.title,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: achievement.unlocked 
                      ? theme.colorScheme.primary
                      : Colors.grey[600],
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Icon(
                achievement.unlocked ? Icons.check_circle : Icons.lock,
                size: 16,
                color: achievement.unlocked 
                    ? theme.colorScheme.primary
                    : Colors.grey[600],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
