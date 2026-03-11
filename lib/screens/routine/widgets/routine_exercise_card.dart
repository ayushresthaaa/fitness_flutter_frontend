import 'package:flutter/material.dart';
import '../../../models/routine/routine_model.dart';
import '../../../widgets/common.dart';

// Single exercise row in routine detail screen
// Long press to pair as superset
class RoutineExerciseCard extends StatelessWidget {
  final RoutineExercise routineExercise;
  final VoidCallback? onRemove;
  final VoidCallback? onLongPress;

  const RoutineExerciseCard({
    super.key,
    required this.routineExercise,
    required this.onRemove,
    this.onLongPress,
  });

  String get _subtitle {
    final parts = <String>[];
    if (routineExercise.sets != null) parts.add('${routineExercise.sets} sets');
    if (routineExercise.reps != null) parts.add('${routineExercise.reps} reps');
    if (routineExercise.weightKg != null)
      parts.add('${routineExercise.weightKg}kg');
    if (routineExercise.restSec != null)
      parts.add('${routineExercise.restSec}s rest');
    return parts.isEmpty ? 'No defaults set' : parts.join(' · ');
  }

  @override
  Widget build(BuildContext context) {
    final exercise = routineExercise.exercise;
    final isCardio = exercise?.category == 'cardio';

    return GestureDetector(
      onLongPress: onLongPress,
      child: Container(
        decoration: BoxDecoration(
          color: kWhite,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        child: Row(
          children: [
            

            // Name + meta
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exercise?.name ?? 'Exercise',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: kTextDark,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _subtitle,
                    style: const TextStyle(fontSize: 12, color: kTextGrey),
                  ),
                ],
              ),
            ),

            // Remove
            GestureDetector(
              onTap: onRemove,
              child: const Icon(Icons.close, size: 18, color: kTextHint),
            ),
          ],
        ),
      ),
    );
  }
}
