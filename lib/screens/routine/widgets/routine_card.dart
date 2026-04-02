import 'package:flutter/material.dart';
import '../../../models/routine/routine_model.dart';
import '../../../widgets/common.dart';

// Card shown in routine list screen
class RoutineCard extends StatelessWidget {
  final Routine routine;
  final VoidCallback onTap;
  final VoidCallback onStart;

  const RoutineCard({
    super.key,
    required this.routine,
    required this.onTap,
    required this.onStart,
  });

  List<String> get _muscles {
    final seen = <String>{};
    final result = <String>[];
    for (final re in routine.exercises) {
      for (final m in re.exercise?.primaryMuscles ?? []) {
        if (seen.add(m)) result.add(m);
        if (result.length >= 3) return result;
      }
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final muscles = _muscles;
    final count = routine.exercises.length;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: kWhite,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Name + exercise count
            Row(
              children: [
                Expanded(
                  child: Text(
                    routine.name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: kTextDark,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  '$count ${count == 1 ? 'exercise' : 'exercises'}',
                  style: const TextStyle(fontSize: 12, color: kTextGrey),
                ),
              ],
            ),

            // Badges - From Trainer and Pending Review only
            if (routine.createdByTrainer == true ||
                routine.reviewStatus == 'pending')
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    // From Trainer badge - blue
                    if (routine.createdByTrainer == true)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: kPrimaryLight,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'From Trainer',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: kPrimary,
                          ),
                        ),
                      ),

                    // Pending Review badge - orange
                    if (routine.reviewStatus == 'pending')
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF3E0),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Pending Review',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFF57C00),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

            // Description
            if (routine.description != null && routine.description!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  routine.description!,
                  style: const TextStyle(fontSize: 12, color: kTextGrey),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

            // Trainer notes - only shown if trainer left a note
            if (routine.trainerNotes != null &&
                routine.trainerNotes!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'Trainer: ${routine.trainerNotes!}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: kPrimary,
                    fontStyle: FontStyle.italic,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

            // Muscle chips
            if (muscles.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Wrap(
                  spacing: 6,
                  children: muscles
                      .map(
                        (m) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: kPrimaryLight,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            m,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: kPrimary,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),

            const SizedBox(height: 12),

            // Start workout button
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: onStart,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: kPrimary,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: kPrimary, width: 1.5),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.play_arrow_rounded, size: 14, color: kWhite),
                        SizedBox(width: 4),
                        Text(
                          'Start',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: kWhite,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
