import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/exercise/workout_model.dart';
import '../../providers/exercise/workout_provider.dart';
import '../../widgets/app_dialog.dart';

class WorkoutDetailScreen extends StatelessWidget {
  final Workout workout;
  const WorkoutDetailScreen({super.key, required this.workout});

  String get _date {
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
    final d = workout.startTime;
    return '${days[d.weekday - 1]}, ${months[d.month - 1]} ${d.day}';
  }

  String get _duration {
    final end = workout.endTime;
    if (end == null) return 'In progress';
    final diff = end.difference(workout.startTime).inMinutes;
    if (diff < 60) return '${diff} mins';
    final h = diff ~/ 60;
    final m = diff % 60;
    return m == 0 ? '${h}h' : '${h}h ${m}m';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF212121)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Workout Detail',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: Color(0xFF212121),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // summary card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        workout.title ?? 'My Workout',
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF212121),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _date,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF9E9E9E),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Duration: $_duration',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF9E9E9E),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${workout.exercises.length} exercises',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF9E9E9E),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // exercise list
                ...workout.exercises.map((we) {
                  final name = we.exercise?.name ?? 'Exercise';
                  final category = we.exercise?.category ?? '';
                  final muscle = we.exercise?.primaryMuscles.isNotEmpty == true
                      ? we.exercise!.primaryMuscles.first
                      : '';
                  final meta = [
                    if (category.isNotEmpty)
                      category[0].toUpperCase() + category.substring(1),
                    if (muscle.isNotEmpty) muscle,
                  ].join(', ');

                  final completedSets = we.workoutSets
                      .where((s) => s.isCompleted)
                      .toList();
                  final skippedSets = we.workoutSets
                      .where((s) => !s.isCompleted)
                      .toList();

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // exercise name and meta
                          Text(
                            name,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF212121),
                            ),
                          ),
                          if (meta.isNotEmpty)
                            Text(
                              meta,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF9E9E9E),
                              ),
                            ),

                          const SizedBox(height: 10),

                          // completed sets
                          ...completedSets.map(
                            (s) => Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.check_circle,
                                    color: Color(0xFF1E88E5),
                                    size: 16,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Set ${s.setNumber}  —  ${s.weightKg != null ? '${s.weightKg}kg' : 'bodyweight'}  ×  ${s.reps ?? '-'} reps',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF212121),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // skipped sets
                          ...skippedSets.map(
                            (s) => Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.remove_circle_outline,
                                    color: Color(0xFFBDBDBD),
                                    size: 16,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Set ${s.setNumber}  —  Skipped',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFFBDBDBD),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),

          // delete button
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                onPressed: () async {
                  final result = await AppDialog.show<bool>(
                    context: context,
                    title: 'Delete Workout?',
                    message: 'This workout will be permanently deleted.',
                    actions: [
                      const AppDialogAction(label: 'Cancel', value: false),
                      const AppDialogAction(
                        label: 'Delete',
                        value: true,
                        isButton: true,
                        color: Colors.red,
                      ),
                    ],
                  );
                  if (result == true && context.mounted) {
                    await context.read<WorkoutProvider>().deleteWorkout(
                      workout.id,
                    );
                    Navigator.pop(context);
                  }
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFFFCDD2)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Delete Workout',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFF44336),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
