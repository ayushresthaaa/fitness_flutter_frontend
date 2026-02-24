import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/exercise/exercise_model.dart';
import '../../../providers/exercise/workout_provider.dart';
import '../../../widgets/app_dialog.dart';
import '../../../widgets/common.dart';
import '../../../screens/exercise/exercise_picker_screen_v2.dart';
import 'v2/finish_workout_screen.dart';
import 'v2/widgets/active_set_model.dart';
import 'v2/widgets/exercise_set_card_v2.dart';
import 'v2/widgets/rest_timer_banner_v2.dart';
import 'v2/widgets/workout_timer_v2.dart';

// Active workout screen
// Everything is local until user taps Finish
// No backend calls here at all
class ActiveWorkoutScreenV2 extends StatefulWidget {
  const ActiveWorkoutScreenV2({super.key});

  @override
  State<ActiveWorkoutScreenV2> createState() => _ActiveWorkoutScreenV2State();
}

class _ActiveWorkoutScreenV2State extends State<ActiveWorkoutScreenV2> {
  // Timer starts when screen opens
  final DateTime _startTime = DateTime.now();

  // Local list of exercises added by user
  // Each item: { 'localId': String, 'exercise': Exercise }
  final List<Map<String, dynamic>> _exercises = [];

  // localId  sets for that exercise
  final Map<String, List<ActiveSet>> _exerciseSets = {};

  // exerciseId → last performance from backend
  final Map<String, List<Map<String, dynamic>>> _lastPerformance = {};

  bool _showRestTimer = false;

  // Open picker, add selected exercises locally
  Future<void> _addExercise() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ExercisePickerScreenV2(
          onExercisesSelected: (exercises) async {
            for (final exercise in exercises) {
              // Unique local key so same exercise can be added twice
              final localId =
                  '${exercise.id}_${DateTime.now().millisecondsSinceEpoch}';

              setState(() {
                _exercises.add({'localId': localId, 'exercise': exercise});
                _exerciseSets[localId] = [ActiveSet(setNumber: 1)];
              });

              // Fetch last performance for this exercise
              await _fetchLastPerf(exercise.id);
            }
          },
        ),
      ),
    );
  }

  // Fetch last performance from backend for one exercise
  Future<void> _fetchLastPerf(String exerciseId) async {
    try {
      final provider = context.read<WorkoutProvider>();
      final result = await provider.getLastPerformanceFor(exerciseId);
      if (result == null) return;
      setState(() => _lastPerformance[exerciseId] = result);
    } catch (_) {}
  }

  // Remove exercise locally
  Future<void> _removeExercise(String localId) async {
    final confirmed = await AppDialog.show<bool>(
      context: context,
      title: 'Remove Exercise?',
      message: 'All sets for this exercise will be lost.',
      actions: [
        const AppDialogAction(label: 'Cancel', value: false, color: kPrimary),
        const AppDialogAction(label: 'Remove', value: true, color: kRed),
      ],
    );
    if (confirmed != true) return;
    setState(() {
      _exercises.removeWhere((e) => e['localId'] == localId);
      _exerciseSets.remove(localId);
    });
  }

  // Add empty set to exercise
  void _addSet(String localId) {
    setState(() {
      final sets = _exerciseSets[localId] ?? [];
      final normalSets = sets.where((s) => !s.isWarmup).length;
      sets.add(ActiveSet(setNumber: normalSets + 1));
      _exerciseSets[localId] = sets;
    });
  }

  // Remove set and renumber remaining
  void _removeSet(String localId, int index) {
    setState(() {
      final sets = _exerciseSets[localId] ?? [];
      sets.removeAt(index);
      int setNum = 1;
      for (final s in sets) {
        if (!s.isWarmup) s.setNumber = setNum++;
      }
      _exerciseSets[localId] = sets;
    });
  }

  // Update set data
  void _updateSet(String localId, int index, ActiveSet updated) {
    setState(() => _exerciseSets[localId]![index] = updated);
  }

  // Mark set complete — PR check + show rest timer
  void _completeSet(String localId, int index, String exerciseId) {
    final set = _exerciseSets[localId]![index];

    // Don't allow completing if kg or reps are empty
    if (set.weightKg == null || set.reps == null) return;

    final lastSets = _lastPerformance[exerciseId] ?? [];
    bool isPR = false;
    if (index < lastSets.length) {
      final lastWeight = (lastSets[index]['weightKg'] as num?)?.toDouble() ?? 0;
      isPR = set.weightKg! > lastWeight;
    }

    setState(() {
      final isNowComplete = !set.isCompleted;
      _exerciseSets[localId]![index] = set.copyWith(
        isCompleted: isNowComplete,
        isPR: isNowComplete ? isPR : false,
      );
      if (isNowComplete) _showRestTimer = true;
    });
  }

  // Discard — just pop, nothing was saved to backend
  Future<void> _discardWorkout() async {
    final confirmed = await AppDialog.show<bool>(
      context: context,
      title: 'Discard Workout?',
      message: 'All your sets will be lost. This cannot be undone.',
      actions: [
        const AppDialogAction(
          label: 'Keep Going',
          value: false,
          color: kPrimary,
        ),
        const AppDialogAction(label: 'Discard', value: true, color: kRed),
      ],
    );
    if (confirmed != true) return;
    if (mounted) Navigator.pop(context);
  }

  // Go to finish screen — backend calls happen there
  void _goToFinish() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FinishWorkoutScreenV2(
          startTime: _startTime,
          exercises: _exercises,
          exerciseSets: _exerciseSets,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppTopBar(
        title: 'My Workout',
        onBack: _discardWorkout,
        actions: [
          // Timer starts from when screen opened
          WorkoutTimerV2(startTime: _startTime),
          const SizedBox(width: 8),

          // Finish button
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: _goToFinish,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: kPrimary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Finish',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Rest timer banner
            if (_showRestTimer)
              RestTimerBannerV2(
                onDone: () => setState(() => _showRestTimer = false),
              ),

            // Exercise list
            Expanded(
              child: _exercises.isEmpty
                  ? const EmptyState(
                      icon: Icons.fitness_center,
                      title: 'No exercises yet',
                      subtitle: 'Tap Add Exercise to get started',
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: _exercises.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final item = _exercises[index];
                        final localId = item['localId'] as String;
                        final exercise = item['exercise'] as Exercise;
                        final sets = _exerciseSets[localId] ?? [];
                        final lastPerf = _lastPerformance[exercise.id] ?? [];

                        return ExerciseSetCardV2(
                          exercise: exercise,
                          sets: sets,
                          lastPerformance: lastPerf,
                          onAddSet: () => _addSet(localId),
                          onRemoveExercise: () => _removeExercise(localId),
                          onSetCompleted: (i) =>
                              _completeSet(localId, i, exercise.id),
                          onSetRemoved: (i) => _removeSet(localId, i),
                          onSetChanged: (i, updated) =>
                              _updateSet(localId, i, updated),
                        );
                      },
                    ),
            ),

            // Add exercise button
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: AddButton(text: 'Add Exercise', onTap: _addExercise),
            ),
          ],
        ),
      ),
    );
  }
}
