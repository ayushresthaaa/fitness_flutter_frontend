// lib/screens/meal/widgets/streak_card.dart

import 'package:flutter/material.dart';
import '../../../../../widgets/common.dart';

class StreakCard extends StatelessWidget {
  final int streak;

  const StreakCard({super.key, required this.streak});

  String get _streakMessage {
    if (streak == 0) return 'Log today to start your streak!';
    if (streak == 1) return 'Great start — keep it going!';
    if (streak < 7) return 'Building momentum!';
    return 'Keep going — you\'re on a roll!';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        // orange gradient for the streak card — matches template
        gradient: const LinearGradient(
          colors: [Color(0xFFFF7043), Color(0xFFFF8A65)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // streak info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'LOGGING STREAK',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.white70,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  streak == 1 ? '1 day' : '$streak days',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: kWhite,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _streakMessage,
                  style: const TextStyle(fontSize: 13, color: Colors.white70),
                ),
              ],
            ),
          ),

          // fire icon to make it feel rewarding
          const Icon(
            Icons.local_fire_department_rounded,
            color: kWhite,
            size: 48,
          ),
        ],
      ),
    );
  }
}
