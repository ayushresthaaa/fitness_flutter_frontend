// lib/screens/meal/insights/widgets/streak_card.dart

import 'package:flutter/material.dart';
import '../../../../widgets/common.dart';

class StreakCard extends StatelessWidget {
  final int streak;

  const StreakCard({super.key, required this.streak});

  String get _message {
    if (streak == 0) return 'Log today to start your streak';
    if (streak == 1) return 'Great start — keep it going';
    if (streak < 7) return 'Building momentum';
    return 'On a roll — don\'t stop now';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.local_fire_department_rounded,
            size: 20,
            color: Color(0xFFFF9800),
          ),
          const SizedBox(height: 10),
          Text(
            streak == 0 ? '0 days' : '$streak ${streak == 1 ? 'day' : 'days'}',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: kTextDark,
              height: 1,
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            'Logging Streak',
            style: TextStyle(fontSize: 12, color: kTextGrey),
          ),
          const SizedBox(height: 6),
          Text(
            _message,
            style: const TextStyle(fontSize: 12, color: kTextGrey),
          ),
        ],
      ),
    );
  }
}
