import 'package:flutter/material.dart';
import '../../../models/routine/weekly_program_model.dart';
import '../../../widgets/common.dart';

// Shown at top of WeeklyProgramScreen
// Blue card if workout assigned, white if rest day
class TodayProgramCard extends StatelessWidget {
  final WeeklyProgramDay today;
  final VoidCallback? onStart;

  const TodayProgramCard({super.key, required this.today, this.onStart});

  @override
  Widget build(BuildContext context) {
    final isRest = today.isRestDay || today.routine == null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isRest ? kWhite : kPrimary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: isRest ? _buildRestDay() : _buildWorkoutDay(),
    );
  }

  Widget _buildRestDay() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: kBackground,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.hotel_rounded, color: kTextGrey, size: 22),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'TODAY · ${today.dayOfWeek.displayName.toUpperCase()}',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: kTextGrey,
              ),
            ),
            const SizedBox(height: 2),
            const Text(
              'Rest Day',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: kTextDark,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWorkoutDay() {
    final routine = today.routine!;
    final count = routine.exercises.length;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.fitness_center_rounded,
            color: kWhite,
            size: 22,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'TODAY · ${today.dayOfWeek.displayName.toUpperCase()}',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                routine.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: kWhite,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                '$count ${count == 1 ? 'exercise' : 'exercises'}',
                style: const TextStyle(fontSize: 12, color: Colors.white70),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: onStart,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: kWhite,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Row(
              children: [
                Icon(Icons.play_arrow_rounded, color: kPrimary, size: 18),
                SizedBox(width: 4),
                Text(
                  'Start',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: kPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
