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
import 'v2/widgets/superset_card_v2.dart';

// Active workout screen
// Everything is local until user taps Finish
// No backend calls here at all
class ActiveWorkoutScreenV2 extends StatefulWidget {
  //parameter for the workout start
  final List<Map<String, dynamic>>?
  prefilledExercises; // {exercise, localId, supersetGroup}
  final String? workoutTitle;
  const ActiveWorkoutScreenV2({
    super.key,
    this.prefilledExercises,
    this.workoutTitle,
  });

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
  final Map<String, int> _supersetGroups = {}; // localId : group number

  int _nextSupersetGroup = 1;

  bool _showRestTimer = false;

  @override
  void initState() {
    super.initState();
    if (widget.prefilledExercises != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        for (final item in widget.prefilledExercises!) {
          final exercise = item['exercise'] as Exercise;
          final localId = item['localId'] as String;
          final supersetGroup = item['supersetGroup'] as int?;
          final sets = item['sets'] as int? ?? 3;

          setState(() {
            _exercises.add({'localId': localId, 'exercise': exercise});
            _exerciseSets[localId] = List.generate(
              sets,
              (i) => ActiveSet(setNumber: i + 1),
            );
            if (supersetGroup != null && supersetGroup > 0) {
              _supersetGroups[localId] = supersetGroup;
              if (supersetGroup >= _nextSupersetGroup) {
                _nextSupersetGroup = supersetGroup + 1;
              }
            }
          });

          await _fetchLastPerf(exercise.id);
        }
      });
    }
  }

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
      _supersetGroups.remove(localId);
    });
  }

  // Add empty set to exercise
  void _addSet(String localId) {
    final sets = _exerciseSets[localId] ?? [];
    if (sets.length >= 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Maximum 10 sets per exercise'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    setState(() {
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

  // Mark set complete  PR check + show rest timer
  void _completeSet(String localId, int index, String exerciseId) {
    final set = _exerciseSets[localId]![index];
    final exercise =
        _exercises.firstWhere((e) => e['localId'] == localId)['exercise']
            as Exercise;
    final isCardio = exercise.category == 'cardio';

    // Validate based on type
    if (isCardio) {
      if (set.durationSec == null) return;
    } else {
      if (set.weightKg == null || set.reps == null) return;
    }

    // PR check only for strength
    final lastSets = _lastPerformance[exerciseId] ?? [];
    bool isPR = false;
    if (!isCardio && index < lastSets.length) {
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

  // Discard just pop, nothing was saved to backend
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

  // Go to finish screen  backend calls happen there
  void _goToFinish() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FinishWorkoutScreenV2(
          startTime: _startTime,
          exercises: _exercises,
          exerciseSets: _exerciseSets,
          supersetGroups: _supersetGroups,
        ),
      ),
    );
  }

  void _addWarmupSet(String localId) {
    final sets = _exerciseSets[localId] ?? [];
    if (sets.where((s) => s.isWarmup).length >= 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Maximum 2 warmup sets per exercise'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    if (sets.length >= 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Maximum 10 sets per exercise'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    setState(() {
      sets.insert(0, ActiveSet(setNumber: 0, isWarmup: true));
      _exerciseSets[localId] = sets;
    });
  }

  // Pair two exercises as superset
  void _pairAsSuperset(String localIdA, String localIdB) {
    setState(() {
      _supersetGroups[localIdA] = _nextSupersetGroup;
      _supersetGroups[localIdB] = _nextSupersetGroup;
      _nextSupersetGroup++;
    });
  }

  // Remove exercise from superset
  void _unpair(String localId) {
    final group = _supersetGroups[localId];
    setState(() {
      // Remove all exercises in this group
      _supersetGroups.removeWhere((key, value) => value == group);
    });
  }

  // Show bottom sheet to pick exercise to pair with
  void _showPairPicker(String localId) {
    // Other exercises not already in a superset
    final others = _exercises.where((e) {
      final id = e['localId'] as String;
      return id != localId && !_supersetGroups.containsKey(id);
    }).toList();

    if (others.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No other exercises available to pair'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Pair with...',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
          ),
          for (final item in others)
            ListTile(
              title: Text((item['exercise'] as Exercise).name),
              onTap: () {
                Navigator.pop(context);
                _pairAsSuperset(localId, item['localId'] as String);
              },
            ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppTopBar(
        title: widget.workoutTitle ?? 'My Workout',
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
                  : Builder(
                      builder: (context) {
                        final List<Widget> items = [];
                        final Set<String> rendered = {};

                        for (final item in _exercises) {
                          final localId = item['localId'] as String;
                          if (rendered.contains(localId)) continue;

                          final group = _supersetGroups[localId];

                          if (group != null) {
                            final paired = _exercises.firstWhere(
                              (e) =>
                                  e['localId'] != localId &&
                                  _supersetGroups[e['localId']] == group,
                              orElse: () => item,
                            );
                            final pairedId = paired['localId'] as String;
                            final groupIndex = _supersetGroups.values
                                .toSet()
                                .toList()
                                .indexOf(group);
                            final label = String.fromCharCode(65 + groupIndex);

                            rendered.add(localId);
                            rendered.add(pairedId);

                            final exA = item['exercise'] as Exercise;
                            final exB = paired['exercise'] as Exercise;

                            items.add(
                              SupersetCardV2(
                                label: label,
                                exerciseA: exA,
                                setsA: _exerciseSets[localId] ?? [],
                                lastPerfA: _lastPerformance[exA.id] ?? [],
                                onAddSetA: () => _addSet(localId),
                                onAddWarmupSetA: () => _addWarmupSet(localId),
                                onRemoveExerciseA: () =>
                                    _removeExercise(localId),
                                onSetCompletedA: (i) =>
                                    _completeSet(localId, i, exA.id),
                                onSetRemovedA: (i) => _removeSet(localId, i),
                                onSetChangedA: (i, u) =>
                                    _updateSet(localId, i, u),
                                exerciseB: exB,
                                setsB: _exerciseSets[pairedId] ?? [],
                                lastPerfB: _lastPerformance[exB.id] ?? [],
                                onAddSetB: () => _addSet(pairedId),
                                onAddWarmupSetB: () => _addWarmupSet(pairedId),
                                onRemoveExerciseB: () =>
                                    _removeExercise(pairedId),
                                onSetCompletedB: (i) =>
                                    _completeSet(pairedId, i, exB.id),
                                onSetRemovedB: (i) => _removeSet(pairedId, i),
                                onSetChangedB: (i, u) =>
                                    _updateSet(pairedId, i, u),
                                onUnpair: () => _unpair(localId),
                              ),
                            );
                          } else {
                            rendered.add(localId);
                            final exercise = item['exercise'] as Exercise;
                            items.add(
                              ExerciseSetCardV2(
                                exercise: exercise,
                                sets: _exerciseSets[localId] ?? [],
                                lastPerformance:
                                    _lastPerformance[exercise.id] ?? [],
                                onAddSet: () => _addSet(localId),
                                onAddWarmupSet: () => _addWarmupSet(localId),
                                onRemoveExercise: () =>
                                    _removeExercise(localId),
                                onSetCompleted: (i) =>
                                    _completeSet(localId, i, exercise.id),
                                onSetRemoved: (i) => _removeSet(localId, i),
                                onSetChanged: (i, u) =>
                                    _updateSet(localId, i, u),
                                onLongPress: () => _showPairPicker(localId),
                              ),
                            );
                          }
                        }

                        return ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: items.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 10),
                          itemBuilder: (_, i) => items[i],
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
