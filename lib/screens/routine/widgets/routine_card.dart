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
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black.withOpacity(0.05), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// HEADER
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    routine.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: kTextDark,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '$count ${count == 1 ? 'exercise' : 'exercises'}',
                  style: TextStyle(
                    fontSize: 11,
                    color: kTextGrey.withOpacity(0.7),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),

            /// BADGES
            if (routine.createdByTrainer == true ||
                routine.reviewStatus == 'pending')
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    if (routine.createdByTrainer == true)
                      _badge('From Trainer', kPrimary),

                    if (routine.reviewStatus == 'pending')
                      _badge('Pending Review', const Color(0xFFF57C00)),
                  ],
                ),
              ),

            /// DESCRIPTION
            if (routine.description != null && routine.description!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  routine.description!,
                  style: TextStyle(
                    fontSize: 12,
                    color: kTextGrey.withOpacity(0.85),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

            /// 🔥 TRAINER NOTES (NEW STYLE)
            if (routine.trainerNotes != null &&
                routine.trainerNotes!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: kPrimary.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: kPrimary.withOpacity(0.15)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.sticky_note_2_rounded,
                        size: 16,
                        color: kPrimary,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          routine.trainerNotes!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: kPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            /// MUSCLE CHIPS
            if (muscles.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: muscles.map((m) {
                    return Container(
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
                    );
                  }).toList(),
                ),
              ),

            const SizedBox(height: 14),

            /// ACTION
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: onStart,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: kPrimary,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: kPrimary.withOpacity(0.25),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.play_arrow_rounded, size: 16, color: kWhite),
                        SizedBox(width: 6),
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

  /// Reusable badge
  Widget _badge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
