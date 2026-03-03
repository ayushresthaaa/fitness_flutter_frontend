import 'package:flutter/material.dart';
import '../../../models/routine/routine_model.dart';
import '../../../widgets/common.dart';

// Big card at top of routine detail screen
// Shows routine info + muscle chips + start workout button
class RoutineHeroCard extends StatelessWidget {
  final Routine routine;
  final VoidCallback onStart;

  const RoutineHeroCard({
    super.key,
    required this.routine,
    required this.onStart,
  });

  List<String> get _muscles {
    final seen = <String>{};
    final result = <String>[];
    for (final re in routine.exercises) {
      for (final m in re.exercise?.primaryMuscles ?? []) {
        if (seen.add(m)) result.add(m);
        if (result.length >= 4) return result;
      }
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final muscles = _muscles;
    final count = routine.exercises.length;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E88E5), Color(0xFF1565C0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name
          Text(
            routine.name,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: kWhite,
            ),
          ),

          // Description
          if (routine.description != null && routine.description!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                routine.description!,
                style: const TextStyle(fontSize: 13, color: Colors.white70),
              ),
            ),

          const SizedBox(height: 12),

          // Exercise count
          Text(
            '$count ${count == 1 ? 'exercise' : 'exercises'}',
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white70,
              fontWeight: FontWeight.w500,
            ),
          ),

          // Muscle chips
          if (muscles.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Wrap(
                spacing: 6,
                runSpacing: 6,
                children: muscles
                    .map(
                      (m) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          m,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: kWhite,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),

          const SizedBox(height: 16),

          // Start workout button
          GestureDetector(
            onTap: onStart,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: kWhite,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.play_arrow_rounded, size: 18, color: kPrimary),
                  SizedBox(width: 6),
                  Text(
                    'Start Workout',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: kPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
