import 'package:flutter/material.dart';
import '../../../models/exercise/history_model.dart';
import '../../../widgets/common.dart';

class WorkoutHistoryCard extends StatelessWidget {
  final WorkoutHistory workout;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onCopy;
  final VoidCallback? onSaveAsRoutine;
  final VoidCallback? onDelete;

  const WorkoutHistoryCard({
    super.key,
    required this.workout,
    required this.onTap,
    this.onEdit,
    this.onCopy,
    this.onSaveAsRoutine,
    this.onDelete,
  });

  bool get _hasPR =>
      workout.exercises.any((e) => e.workoutSets.any((s) => s.isPR));

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: kWhite,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: kPrimaryLight, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title row
            Row(
              children: [
                Expanded(
                  child: Text(
                    workout.title ?? 'Workout',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: kTextDark,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                // PR badge
                if (_hasPR)
                  Container(
                    margin: const EdgeInsets.only(left: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF8E1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.emoji_events_rounded,
                          size: 12,
                          color: Color(0xFFFF9800),
                        ),
                        SizedBox(width: 3),
                        Text(
                          'PR',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFFF9800),
                          ),
                        ),
                      ],
                    ),
                  ),

                // ⋮ menu
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, size: 18, color: kTextHint),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  onSelected: (value) {
                    if (value == 'edit') onEdit?.call();
                    if (value == 'copy') onCopy?.call();
                    if (value == 'routine') onSaveAsRoutine?.call();
                    if (value == 'delete') onDelete?.call();
                  },
                  itemBuilder: (_) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit_outlined, size: 16, color: kTextDark),
                          SizedBox(width: 10),
                          Text(
                            'Edit',
                            style: TextStyle(fontSize: 13, color: kTextDark),
                          ),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'copy',
                      child: Row(
                        children: [
                          Icon(Icons.copy_outlined, size: 16, color: kTextDark),
                          SizedBox(width: 10),
                          Text(
                            'Copy Workout',
                            style: TextStyle(fontSize: 13, color: kTextDark),
                          ),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'routine',
                      child: Row(
                        children: [
                          Icon(
                            Icons.bookmark_outline,
                            size: 16,
                            color: kTextDark,
                          ),
                          SizedBox(width: 10),
                          Text(
                            'Save as Routine',
                            style: TextStyle(fontSize: 13, color: kTextDark),
                          ),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline, size: 16, color: kRed),
                          SizedBox(width: 10),
                          Text(
                            'Delete',
                            style: TextStyle(fontSize: 13, color: kRed),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Stats row
            Row(
              children: [
                _StatChip(
                  icon: Icons.fitness_center_rounded,
                  label:
                      '${workout.exercises.length} ${workout.exercises.length == 1 ? 'exercise' : 'exercises'}',
                ),
                if (workout.durationMin != null) ...[
                  const SizedBox(width: 10),
                  _StatChip(
                    icon: Icons.timer_outlined,
                    label: '${workout.durationMin}min',
                  ),
                ],
                if (workout.totalVolume > 0) ...[
                  const SizedBox(width: 10),
                  _StatChip(
                    icon: Icons.monitor_weight_outlined,
                    label: '${workout.totalVolume}kg',
                  ),
                ],
              ],
            ),

            // Muscle chips
            if (workout.musclesWorked.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: workout.musclesWorked
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
          ],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _StatChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 13, color: kTextGrey),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: kTextGrey)),
      ],
    );
  }
}
