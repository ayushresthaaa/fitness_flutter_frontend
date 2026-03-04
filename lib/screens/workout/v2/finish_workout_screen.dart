import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/exercise/exercise_model.dart';
import '../../../providers/exercise/workout_provider.dart';
import '../../../providers/routine/routine_provider.dart';
import '../../../widgets/common.dart';
import 'widgets/active_set_model.dart';

class FinishWorkoutScreenV2 extends StatefulWidget {
  final DateTime startTime;
  final List<Map<String, dynamic>> exercises;
  final Map<String, List<ActiveSet>> exerciseSets;
  final Map<String, int> supersetGroups;
  final String? routineId;
  final List<Map<String, dynamic>>? originalExercises; // {exerciseId, name}
  final String? workoutTitle;

  const FinishWorkoutScreenV2({
    super.key,
    required this.startTime,
    required this.exercises,
    required this.exerciseSets,
    required this.supersetGroups,
    this.routineId,
    this.originalExercises,
    this.workoutTitle,
  });

  @override
  State<FinishWorkoutScreenV2> createState() => _FinishWorkoutScreenV2State();
}

class _FinishWorkoutScreenV2State extends State<FinishWorkoutScreenV2> {
  final _titleController = TextEditingController();
  final _notesController = TextEditingController();
  @override
  void initState() {
    super.initState();
    if (widget.workoutTitle != null) {
      _titleController.text = widget.workoutTitle!;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    final provider = context.read<WorkoutProvider>();

    await provider.startWorkout(
      title: _titleController.text.trim().isEmpty
          ? 'My Workout'
          : _titleController.text.trim(),
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    );

    if (provider.currentWorkout == null) return;

    final Map<String, String> localIdToWorkoutExerciseId = {};

    for (final item in widget.exercises) {
      final exercise = item['exercise'] as Exercise;
      final localId = item['localId'] as String;
      final sets = widget.exerciseSets[localId] ?? [];
      if (sets.isEmpty) continue;

      final supersetGroup = widget.supersetGroups[localId];
      await provider.addExerciseToWorkout(
        exerciseId: exercise.id,
        supersetGroup: supersetGroup,
      );

      final addedId = provider.currentWorkout!.exercises.last.id;
      localIdToWorkoutExerciseId[localId] = addedId;
    }

    final List<Map<String, dynamic>> exerciseSets = [];
    for (final item in widget.exercises) {
      final localId = item['localId'] as String;
      final workoutExerciseId = localIdToWorkoutExerciseId[localId];
      if (workoutExerciseId == null) continue;

      final sets = widget.exerciseSets[localId] ?? [];
      if (sets.isEmpty) continue;

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
          'durationSec': s.durationSec,
          'distanceMeters': s.distanceMeters,
        });
      }
      exerciseSets.add({
        'workoutExerciseId': workoutExerciseId,
        'sets': setPayload,
      });
    }

    await provider.saveSets(exerciseSets);
    await provider.finishWorkout();

    final hasChanges = await _checkRoutineChanges();

    if (!hasChanges && mounted) {
      _popAndNotify('Workout saved!');
    }
  }

  // Returns true if changes were found and bottom sheet was shown
  Future<bool> _checkRoutineChanges() async {
    if (widget.routineId == null || widget.originalExercises == null) {
      return false;
    }

    final currentExerciseIds = widget.exercises
        .map((e) => (e['exercise'] as Exercise).id)
        .toList();

    final originalExerciseIds = widget.originalExercises!
        .map((e) => e['exerciseId'] as String)
        .toList();

    // Exercises added during workout
    final added = widget.exercises
        .where(
          (e) => !originalExerciseIds.contains((e['exercise'] as Exercise).id),
        )
        .map((e) => e['exercise'] as Exercise)
        .toList();

    // Exercises removed during workout
    final removed = widget.originalExercises!
        .where((e) => !currentExerciseIds.contains(e['exerciseId'] as String))
        .toList();

    if (added.isEmpty && removed.isEmpty) return false;

    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Update Routine?',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: kTextDark,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'You made changes during this workout.',
              style: TextStyle(fontSize: 13, color: kTextGrey),
            ),
            const SizedBox(height: 16),

            for (final ex in added)
              _ChangeRow(
                icon: Icons.add_circle_outline,
                color: kGreen,
                name: ex.name,
                label: 'Added',
              ),

            for (final ex in removed)
              _ChangeRow(
                icon: Icons.remove_circle_outline,
                color: kRed,
                name: ex['name'] as String,
                label: 'Removed',
              ),

            const SizedBox(height: 16),

            PrimaryButton(
              text: 'Update Routine',
              onTap: () async {
                Navigator.pop(ctx);
                await _updateRoutine(added, removed);
                if (mounted) _popAndNotify('Routine updated!');
              },
            ),
            const SizedBox(height: 8),
            DangerButton(
              text: 'Keep Original',
              onTap: () {
                Navigator.pop(ctx);
                if (mounted) _popAndNotify('Workout saved!');
              },
            ),
          ],
        ),
      ),
    );

    return true;
  }

  Future<void> _updateRoutine(
    List<Exercise> addedExercises,
    List<Map<String, dynamic>> removedExercises,
  ) async {
    final routineProvider = context.read<RoutineProvider>();
    await routineProvider.fetchRoutineById(widget.routineId!);

    for (final exercise in addedExercises) {
      await routineProvider.addExerciseToRoutine(exerciseId: exercise.id);
    }

    for (final ex in removedExercises) {
      final routine = routineProvider.selectedRoutine;
      if (routine == null) continue;
      final match = routine.exercises
          .where((e) => e.exerciseId == ex['exerciseId'])
          .toList();
      if (match.isEmpty) continue;
      await routineProvider.removeExerciseFromRoutine(match.first.id);
    }
  }

  void _popAndNotify(String message) {
    Navigator.popUntil(context, (route) => route.isFirst);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: kGreen,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  int get _completedSets {
    int count = 0;
    for (final sets in widget.exerciseSets.values) {
      for (final s in sets) {
        if (s.isCompleted) count++;
      }
    }
    return count;
  }

  int get _totalSets {
    int count = 0;
    for (final sets in widget.exerciseSets.values) {
      count += sets.where((s) => !s.isWarmup).length;
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
                        color: kWhite,
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
                            value: '$_completedSets/$_totalSets',
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
              child: Consumer<WorkoutProvider>(
                builder: (context, provider, _) => PrimaryButton(
                  text: 'Save Workout',
                  isLoading: provider.isLoading,
                  onTap: _finish,
                ),
              ),
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
            color: kTextDark,
          ),
        ),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 12, color: kTextGrey)),
      ],
    );
  }
}

class _ChangeRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String name;
  final String label;

  const _ChangeRow({
    required this.icon,
    required this.color,
    required this.name,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(fontSize: 13, color: kTextDark),
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
