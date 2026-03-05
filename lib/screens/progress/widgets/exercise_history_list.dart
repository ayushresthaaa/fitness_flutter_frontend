import 'package:flutter/material.dart';
import '../../../models/progress/progress_model.dart';
import '../../../widgets/common.dart';

class ExerciseHistoryList extends StatelessWidget {
  final List<ProgressPoint> history;
  final bool isCardio;

  const ExerciseHistoryList({
    super.key,
    required this.history,
    required this.isCardio,
  });

  String _formatDate(DateTime date) {
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
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return '${days[date.weekday - 1]}, ${months[date.month - 1]} ${date.day} ${date.year}';
  }

  String _strengthLabel(ProgressSet set) {
    final weight = set.weightKg != null ? '${set.weightKg}kg' : '-';
    final reps = set.reps != null ? '${set.reps} reps' : '-';
    return '$weight × $reps';
  }

  String _cardioLabel(ProgressSet set) {
    final duration = set.durationSec != null
        ? '${(set.durationSec! / 60).toStringAsFixed(1)}min'
        : '-';
    final distance = set.distanceMeters != null
        ? '${(set.distanceMeters! / 1000).toStringAsFixed(2)}km'
        : '';
    if (distance.isNotEmpty) return '$duration · $distance';
    return duration;
  }

  @override
  Widget build(BuildContext context) {
    if (history.isEmpty) {
      return const EmptyState(
        icon: Icons.history_rounded,
        title: 'No history yet',
        subtitle: 'Complete a workout to see your history here',
      );
    }

    // Show most recent first
    final reversed = history.reversed.toList();

    return Column(
      children: reversed.map((point) {
        final completedSets = point.sets.where((s) => s.isCompleted).toList();

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: kWhite,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date + workout title
                Text(
                  _formatDate(point.date),
                  style: const TextStyle(fontSize: 12, color: kTextGrey),
                ),
                if (point.workoutTitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    point.workoutTitle!,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: kTextDark,
                    ),
                  ),
                ],

                const SizedBox(height: 10),

                if (completedSets.isEmpty)
                  const Text(
                    'No completed sets',
                    style: TextStyle(fontSize: 12, color: kTextGrey),
                  )
                else
                  ...completedSets.map((set) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        children: [
                          // Set number
                          SizedBox(
                            width: 28,
                            child: Text(
                              '${set.setNumber}',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: kTextGrey,
                              ),
                            ),
                          ),

                          // Warmup badge
                          if (set.isWarmup)
                            Container(
                              margin: const EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 5,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFF9800),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'W',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  color: kWhite,
                                ),
                              ),
                            ),

                          // Weight × reps or cardio
                          Expanded(
                            child: Text(
                              isCardio
                                  ? _cardioLabel(set)
                                  : _strengthLabel(set),
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: kTextDark,
                              ),
                            ),
                          ),

                          // RPE
                          if (set.rpe != null)
                            Text(
                              'RPE ${set.rpe}',
                              style: const TextStyle(
                                fontSize: 11,
                                color: kTextGrey,
                              ),
                            ),

                          // PR badge
                          if (set.isPR)
                            const Padding(
                              padding: EdgeInsets.only(left: 8),
                              child: Icon(
                                Icons.emoji_events_rounded,
                                size: 16,
                                color: Color(0xFFFF9800),
                              ),
                            ),
                        ],
                      ),
                    );
                  }),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
