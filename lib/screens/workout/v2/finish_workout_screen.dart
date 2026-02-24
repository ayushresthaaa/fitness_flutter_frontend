import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/exercise/exercise_model.dart';
import '../../../providers/exercise/workout_provider.dart';
import '../../../widgets/common.dart';
import 'widgets/active_set_model.dart';

class FinishWorkoutScreenV2 extends StatefulWidget {
  final DateTime startTime;
  final List<Map<String, dynamic>> exercises; // { localId, exercise }
  final Map<String, List<ActiveSet>> exerciseSets; // localId → sets

  const FinishWorkoutScreenV2({
    super.key,
    required this.startTime,
    required this.exercises,
    required this.exerciseSets,
  });

  @override
  State<FinishWorkoutScreenV2> createState() => _FinishWorkoutScreenV2State();
}

class _FinishWorkoutScreenV2State extends State<FinishWorkoutScreenV2> {
  final _titleController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  // All backend calls happen here on save
  Future<void> _finish() async {
    final provider = context.read<WorkoutProvider>();

    // 1. Start workout
    await provider.startWorkout(
      title: _titleController.text.trim().isEmpty
          ? 'My Workout'
          : _titleController.text.trim(),
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    );

    final workout = provider.currentWorkout;
    if (workout == null) return;

    // 2. Add exercises and save sets
    final List<Map<String, dynamic>> exerciseSets = [];

    for (final item in widget.exercises) {
      final exercise = item['exercise'] as Exercise;
      final localId = item['localId'] as String;
      final sets = widget.exerciseSets[localId] ?? [];
      if (sets.isEmpty) continue;

      // Add exercise to workout
      await provider.addExerciseToWorkout(exerciseId: exercise.id);
      final addedExercise = workout.exercises.last;

      // Build set payload
      final setPayload = <Map<String, dynamic>>[];
      for (final s in sets) {
        setPayload.add({
          'setNumber': s.setNumber,
          'weightKg': s.weightKg,
          'reps': s.reps,
          'rpe': s.rpe,
          'isWarmup': s.isWarmup,
          'isPR': s.isPR,
          'isCompleted': s.isCompleted,
        });
      }

      exerciseSets.add({
        'workoutExerciseId': addedExercise.id,
        'sets': setPayload,
      });
    }

    // 3. Save sets
    await provider.saveSets(exerciseSets);

    // 4. Finish workout
    await provider.finishWorkout();

    // Pop all the way back to home
    if (mounted) Navigator.popUntil(context, (route) => route.isFirst);
  }

  int get _totalSets {
    int count = 0;
    for (final sets in widget.exerciseSets.values) {
      for (final s in sets) {
        if (s.isCompleted) count++;
      }
    }
    return count;
  }

  int get _totalExercises => widget.exercises.length;

  String get _duration {
    final d = DateTime.now().difference(widget.startTime);
    return '${d.inMinutes}m ${d.inSeconds.remainder(60)}s';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppTopBar(title: 'Finish Workout'),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Summary card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _SummaryItem(label: 'Duration', value: _duration),
                          _SummaryItem(
                            label: 'Exercises',
                            value: '$_totalExercises',
                          ),
                          _SummaryItem(
                            label: 'Sets Done',
                            value: '$_totalSets',
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    const SectionLabel('WORKOUT TITLE'),
                    const SizedBox(height: 8),
                    AppTextField(
                      controller: _titleController,
                      hint: 'e.g. Push Day, Leg Day...',
                    ),

                    const SizedBox(height: 16),

                    const SectionLabel('NOTES (optional)'),
                    const SizedBox(height: 8),
                    AppTextField(
                      controller: _notesController,
                      hint: 'How did it go?',
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: PrimaryButton(text: 'Save Workout', onTap: _finish),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF212121),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Color(0xFF9E9E9E)),
        ),
      ],
    );
  }
}
