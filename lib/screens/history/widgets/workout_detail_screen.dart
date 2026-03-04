import 'package:flutter/material.dart';
import '../../../models/exercise/history_model.dart';
import '../../../widgets/app_dialog.dart';
import '../../../widgets/common.dart';

class WorkoutDetailScreen extends StatelessWidget {
  final WorkoutHistory workout;

  const WorkoutDetailScreen({super.key, required this.workout});

  String _formatDate(DateTime dt) {
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
    return '${days[dt.weekday - 1]}, ${months[dt.month - 1]} ${dt.day}';
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await AppDialog.show<bool>(
      context: context,
      title: 'Delete Workout?',
      message: 'This workout will be permanently deleted.',
      actions: [
        const AppDialogAction(label: 'Cancel', value: false, color: kPrimary),
        const AppDialogAction(label: 'Delete', value: true, color: kRed),
      ],
    );
    if (confirmed == true && context.mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppTopBar(
        title: workout.title ?? 'Workout',
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () => _confirmDelete(context),
              child: const Icon(Icons.delete_outline, color: kRed, size: 22),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Summary card
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: kWhite,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatDate(workout.startTime),
                  style: const TextStyle(fontSize: 12, color: kTextGrey),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (workout.durationMin != null)
                      _Chip(
                        icon: Icons.timer_outlined,
                        label: '${workout.durationMin}min',
                      ),
                    const SizedBox(width: 10),
                    if (workout.totalVolume > 0)
                      _Chip(
                        icon: Icons.monitor_weight_outlined,
                        label: '${workout.totalVolume}kg',
                      ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          SectionLabel('EXERCISES (${workout.exercises.length})'),
          const SizedBox(height: 12),

          ...workout.exercises.map(
            (ex) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _ExerciseBlock(exercise: ex),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExerciseBlock extends StatelessWidget {
  final WorkoutHistoryExercise exercise;

  const _ExerciseBlock({required this.exercise});

  @override
  Widget build(BuildContext context) {
    final isCardio = exercise.exercise?.isCardio ?? false;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            exercise.exercise?.name ?? 'Exercise',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: kTextDark,
            ),
          ),

          const SizedBox(height: 10),

          if (exercise.workoutSets.isEmpty)
            const Text(
              'No sets recorded',
              style: TextStyle(fontSize: 12, color: kTextGrey),
            ),

          ...exercise.workoutSets.map(
            (set) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
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
                  Expanded(
                    child: Text(
                      isCardio ? _cardioLabel(set) : _strengthLabel(set),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: set.isCompleted ? kTextDark : kTextHint,
                      ),
                    ),
                  ),
                  if (set.rpe != null)
                    Text(
                      'RPE ${set.rpe}',
                      style: const TextStyle(fontSize: 11, color: kTextGrey),
                    ),
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
            ),
          ),
        ],
      ),
    );
  }

  String _strengthLabel(WorkoutHistorySet set) {
    final w = set.weightKg != null ? '${set.weightKg}kg' : '-';
    final r = set.reps != null ? '${set.reps} reps' : '-';
    return '$w × $r';
  }

  String _cardioLabel(WorkoutHistorySet set) {
    final d = set.durationSec != null
        ? '${(set.durationSec! / 60).toStringAsFixed(1)}min'
        : '-';
    final dist = set.distanceMeters != null
        ? '${(set.distanceMeters! / 1000).toStringAsFixed(2)}km'
        : '';
    return dist.isNotEmpty ? '$d · $dist' : d;
  }
}

class _Chip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _Chip({required this.icon, required this.label});

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
