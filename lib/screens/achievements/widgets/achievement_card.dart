import 'package:flutter/material.dart';
import '../../../models/achievement/achievement_model.dart';
import '../../../widgets/common.dart';

// Shows differently based on earned status — full color if earned, greyed out if locked
class AchievementCard extends StatelessWidget {
  final Achievement achievement;

  const AchievementCard({super.key, required this.achievement});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: achievement.earned ? kPrimaryLight : kBackground,
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          // Icon container
          // Container(
          //   width: 48,
          //   height: 48,
          //   decoration: BoxDecoration(
          //     color: achievement.earned ? kPrimaryLight : kBackground,
          //     borderRadius: BorderRadius.circular(12),
          //   ),
          //   child: Center(
          //     // child: Icon(
          //     //   _iconForType(achievement.type),
          //     //   size: 24,
          //     //   color: achievement.earned ? kPrimary : kTextHint,
          //     // ),
          //   ),
          // ),
          const SizedBox(width: 12),

          // Name, description, date or requirement
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  achievement.name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: achievement.earned ? kTextDark : kTextGrey,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  achievement.description,
                  style: const TextStyle(fontSize: 12, color: kTextGrey),
                ),
                const SizedBox(height: 4),
                Text(
                  achievement.earned
                      ? 'Unlocked ${_formatDate(achievement.unlockedAt!)}'
                      : '${achievement.requirement} required',
                  style: TextStyle(
                    fontSize: 11,
                    color: achievement.earned ? kPrimary : kTextHint,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // Check or lock icon
          // Icon(
          //   achievement.earned ? Icons.check_circle : Icons.lock_outline,
          //   color: achievement.earned ? kPrimary : kTextHint,
          //   size: 20,
          // ),
        ],
      ),
    );
  }

  // IconData _iconForType(String type) {
  //   if (type == 'first_workout') return Icons.flag_rounded;
  //   if (type == 'workout_count') return Icons.fitness_center_rounded;
  //   if (type == 'streak') return Icons.local_fire_department_rounded;
  //   if (type == 'exercises_logged') return Icons.list_alt_rounded;
  //   if (type == 'personal_record') return Icons.emoji_events_rounded;
  //   return Icons.star_rounded;
  // }

  String _formatDate(DateTime date) {
    return '${_month(date.month)} ${date.day}, ${date.year}';
  }

  String _month(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }
}
