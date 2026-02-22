import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/exercise/workout_model.dart';
import '../../providers/exercise/workout_provider.dart';
import '../../widgets/app_dialog.dart';

class WorkoutDetailScreen extends StatelessWidget {
  final Workout workout;

  const WorkoutDetailScreen({super.key, required this.workout});

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
                _SummaryCard(workout: workout),
                const SizedBox(height: 10),
                ...workout.exercises.map(
                  (we) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _ExerciseCard(workoutExercise: we),
                  ),
                ),
              ],
            ),
          ),
          _DeleteButton(workout: workout),
        ],
      ),
    );
  }
}

// summary

class _SummaryCard extends StatelessWidget {
  final Workout workout;
  const _SummaryCard({required this.workout});

  String _formatDate(DateTime d) {
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
    return '${days[d.weekday - 1]}, ${months[d.month - 1]} ${d.day}';
  }

  String _formatTime(DateTime d) {
    final h = d.hour;
    final m = d.minute.toString().padLeft(2, '0');
    final period = h >= 12 ? 'PM' : 'AM';
    final hour = h > 12
        ? h - 12
        : h == 0
        ? 12
        : h;
    return '$hour:$m $period';
  }

  String _formatDuration(DateTime start, DateTime? end) {
    if (end == null) return 'In progress';
    final diff = end.difference(start).inMinutes;
    if (diff < 60) return '${diff}m';
    final h = diff ~/ 60;
    final m = diff % 60;
    return m == 0 ? '${h}h' : '${h}h ${m}m';
  }

  int _totalVolume() {
    int volume = 0;
    for (final we in workout.exercises) {
      for (final s in we.workoutSets) {
        if (s.isCompleted && s.weightKg != null && s.reps != null) {
          volume += (s.weightKg! * s.reps!).toInt();
        }
      }
    }
    return volume;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDate(workout.startTime),
                style: const TextStyle(fontSize: 13, color: Color(0xFF9E9E9E)),
              ),
              Text(
                _formatTime(workout.startTime),
                style: const TextStyle(fontSize: 13, color: Color(0xFF9E9E9E)),
              ),
            ],
          ),
          const Divider(height: 20, color: Color(0xFFF0F0F0)),
          Row(
            children: [
              _StatItem(
                value: _formatDuration(workout.startTime, workout.endTime),
                label: 'Duration',
              ),
              const _StatDivider(),
              _StatItem(
                value: '${workout.exercises.length}',
                label: 'Exercises',
              ),
              const _StatDivider(),
              _StatItem(value: '${_totalVolume()}kg', label: 'Volume'),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  const _StatItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF212121),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: Color(0xFF9E9E9E)),
          ),
        ],
      ),
    );
  }
}

class _StatDivider extends StatelessWidget {
  const _StatDivider();

  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 28, color: const Color(0xFFF0F0F0));
  }
}

//exercise

class _ExerciseCard extends StatelessWidget {
  final WorkoutExercise workoutExercise;
  const _ExerciseCard({required this.workoutExercise});

  @override
  Widget build(BuildContext context) {
    final exercise = workoutExercise.exercise;
    final completedSets = workoutExercise.workoutSets
        .where((s) => s.isCompleted)
        .length;

    // meta: "Strength, Chest"
    final parts = <String>[];
    if (exercise?.category.isNotEmpty == true) {
      parts.add(
        exercise!.category[0].toUpperCase() + exercise.category.substring(1),
      );
    }
    if (exercise?.primaryMuscles.isNotEmpty == true) {
      parts.add(exercise!.primaryMuscles.first);
    }
    final meta = parts.join(', ');

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          // Exercise header
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exercise?.name ?? 'Exercise',
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
                  ],
                ),
                Text(
                  '$completedSets sets',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF9E9E9E),
                  ),
                ),
              ],
            ),
          ),

          if (workoutExercise.workoutSets.isNotEmpty) ...[
            const Divider(height: 1, color: Color(0xFFF5F5F5)),

            // Column labels
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 4),
              child: Row(
                children: const [
                  SizedBox(width: 28, child: _ColLabel('SET')),
                  SizedBox(width: 8),
                  Expanded(child: _ColLabel('KG')),
                  SizedBox(width: 8),
                  Expanded(child: _ColLabel('REPS')),
                  SizedBox(width: 8),
                  SizedBox(width: 55, child: _ColLabel('STATUS')),
                ],
              ),
            ),

            // Set rows
            ...workoutExercise.workoutSets.map(
              (s) => Padding(
                padding: const EdgeInsets.fromLTRB(14, 4, 14, 4),
                child: Row(
                  children: [
                    SizedBox(
                      width: 28,
                      child: Text(
                        '${s.setNumber}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFFBDBDBD),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        s.weightKg != null ? '${s.weightKg}' : '-',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: s.isCompleted
                              ? const Color(0xFF212121)
                              : const Color(0xFFBDBDBD),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        s.reps != null ? '${s.reps}' : '-',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: s.isCompleted
                              ? const Color(0xFF212121)
                              : const Color(0xFFBDBDBD),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 55,
                      child: Text(
                        s.isCompleted ? 'Done' : 'Skipped',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: s.isCompleted
                              ? const Color(0xFF388E3C)
                              : const Color(0xFFBDBDBD),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}

// delete

class _DeleteButton extends StatelessWidget {
  final Workout workout;
  const _DeleteButton({required this.workout});

  @override
  Widget build(BuildContext context) {
    return Container(
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
              await context.read<WorkoutProvider>().deleteWorkout(workout.id);
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
    );
  }
}

// ─── Column Label ────────────────────────────────────────────

class _ColLabel extends StatelessWidget {
  final String text;
  const _ColLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        color: Color(0xFFBDBDBD),
        letterSpacing: 0.4,
      ),
    );
  }
}
