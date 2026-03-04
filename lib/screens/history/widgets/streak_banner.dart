import 'package:flutter/material.dart';
import '../../../models/exercise/history_model.dart';
import '../../../widgets/common.dart';

// Streak banner shown at top of history screen
// Shows current streak and longest streak
class StreakBanner extends StatelessWidget {
  final StreakData streak;

  const StreakBanner({super.key, required this.streak});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Fire icon
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3E0),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.local_fire_department_rounded,
              color: Color(0xFFFF9800),
              size: 24,
            ),
          ),
          const SizedBox(width: 12),

          // Current streak
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${streak.streak} Day Streak',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: kTextDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Longest: ${streak.longestStreak} days',
                  style: const TextStyle(fontSize: 12, color: kTextGrey),
                ),
              ],
            ),
          ),

          // Streak count badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: streak.streak > 0 ? const Color(0xFFFFF3E0) : kBackground,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.local_fire_department_rounded,
                  color: Color(0xFFFF9800),
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  '${streak.streak}',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: streak.streak > 0
                        ? const Color(0xFFFF9800)
                        : kTextGrey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
