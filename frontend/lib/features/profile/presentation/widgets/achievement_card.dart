import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../domain/entities/profile_dto.dart';

IconData mapAchievementIcon(String? iconKey) {
  switch (iconKey) {
    case 'heart': return FontAwesomeIcons.heart;
    case 'shopping-cart': return FontAwesomeIcons.cartShopping;
    case 'share-alt': return FontAwesomeIcons.shareAlt;
    case 'utensils': return FontAwesomeIcons.utensils;
    case 'clock': return FontAwesomeIcons.clock;
    case 'users': return FontAwesomeIcons.users;
    case 'calendar-week': return FontAwesomeIcons.calendarWeek;
    case 'books': return FontAwesomeIcons.book;
    case 'barcode': return FontAwesomeIcons.barcode;
    default: return FontAwesomeIcons.medal;
  }
}

class AchievementCard extends StatelessWidget {
  final AchievementDto achievement;

  const AchievementCard({Key? key, required this.achievement}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      clipBehavior: Clip.hardEdge,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(mapAchievementIcon(achievement.icon), size: 24),
            const SizedBox(height: 6),
            Text(
              achievement.title,
              style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
