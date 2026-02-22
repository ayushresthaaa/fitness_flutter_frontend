import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/exercise/workout_provider.dart';
import '../../models/exercise/exercise_model.dart';
import '../../widgets/app_dialog.dart';
import '../exercise/exericse_picker_screen.dart';
import 'widget/rest_timer_banner.dart';
import 'widget/set_row.dart';
import 'widget/workout_exercise.dart';
import 'widget/workout_timer.dart';

class ActiveWorkoutScreen extends StatefulWidget {
  const ActiveWorkoutScreen({super.key});

  @override
  State<ActiveWorkoutScreen> createState() => _ActiveWorkoutScreenState();
}

class _ActiveWorkoutScreenState extends State<ActiveWorkoutScreen> {
  final Map<String, List<SetData>> _setsMap = {};
  bool _showRestTimer = false;

  @override
  void initState() {
    super.initState();
    _initSets();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WorkoutProvider>().fetchLastPerformances();
    });
  }

  void _initSets() {
    final workout = context.read<WorkoutProvider>().currentWorkout;
    if (workout == null) return;
    for (final we in workout.exercises) {
      _setsMap[we.id] = [SetData(weightKg: we.weightKg, reps: we.reps)];
    }
  }

  List<SetData> _getSets(String id) => _setsMap[id] ?? [];

  void _addSet(String id) {
    setState(() {
      final last = _setsMap[id]?.last;
      _setsMap[id] = [
        ...?_setsMap[id],
        SetData(weightKg: last?.weightKg, reps: last?.reps),
      ];
    });
  }

  void _removeSet(String id, int index) {
    setState(() {
      final sets = List<SetData>.from(_setsMap[id] ?? []);
      if (sets.length > 1) sets.removeAt(index);
      _setsMap[id] = sets;
    });
  }

  void _updateSet(String id, int index, SetData updated) {
    setState(() {
      final sets = List<SetData>.from(_setsMap[id] ?? []);
      sets[index] = updated;
      _setsMap[id] = sets;
    });
  }

  void _toggleSet(String id, int index) {
    final sets = List<SetData>.from(_setsMap[id] ?? []);
    final set = sets[index];

    // block marking done if reps empty
    if (!set.isCompleted && set.reps == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter reps before marking set as done.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // confirm before unchecking a completed set
    if (set.isCompleted) {
      AppDialog.show<bool>(
        context: context,
        title: 'Undo Set?',
        message: 'Are you sure you want to mark this set as incomplete?',
        actions: [
          const AppDialogAction(label: 'Cancel', value: false),
          const AppDialogAction(label: 'Undo', value: true, color: Colors.red),
        ],
      ).then((result) {
        if (result == true) {
          setState(() {
            sets[index] = set.copyWith(isCompleted: false);
            _setsMap[id] = sets;
            _showRestTimer = false;
          });
        }
      });
      return;
    }

    setState(() {
      sets[index] = set.copyWith(isCompleted: true);
      _setsMap[id] = sets;
      _showRestTimer = false;
      Future.microtask(() => setState(() => _showRestTimer = true));
    });
  }

  Future<void> _addExercises(List<Exercise> exercises) async {
    final provider = context.read<WorkoutProvider>();
    for (final exercise in exercises) {
      await provider.addExerciseToWorkout(exerciseId: exercise.id);
      final we = provider.currentWorkout?.exercises.last;
      if (we != null) _setsMap[we.id] = [const SetData()];
    }
    // fetch last performance after adding exercises
    await provider.fetchLastPerformances();
    setState(() {});
  }

  List<Map<String, dynamic>> _buildExerciseSets() {
    final workout = context.read<WorkoutProvider>().currentWorkout;
    if (workout == null) return [];
    return workout.exercises.map((we) {
      final sets = _setsMap[we.id] ?? [];
      return {
        'workoutExerciseId': we.id,
        'sets': sets
            .asMap()
            .entries
            .map(
              (e) => {
                'setNumber': e.key + 1,
                'weightKg': e.value.weightKg,
                'reps': e.value.reps,
                'isCompleted': e.value.isCompleted,
              },
            )
            .toList(),
      };
    }).toList();
  }

  Future<void> _finishWorkout() async {
    final provider = context.read<WorkoutProvider>();

    final exerciseSets = _buildExerciseSets().where((e) {
      final sets = e['sets'] as List;
      return sets.any((s) => s['isCompleted'] == true);
    }).toList();

    // warn user if some exercises had no completed sets
    final totalExercises = _buildExerciseSets().length;
    if (exerciseSets.length < totalExercises && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Exercises with no completed sets were not saved.'),
          duration: Duration(seconds: 2),
        ),
      );
    }

    await provider.saveSets(exerciseSets);
    await provider.finishWorkout();
    if (mounted) Navigator.pop(context);
  }

  Future<void> _confirmFinish() async {
    final result = await AppDialog.show<bool>(
      context: context,
      title: 'Finish Workout?',
      message: 'Are you sure you want to finish?',
      actions: [
        const AppDialogAction(label: 'Cancel', value: false),
        const AppDialogAction(label: 'Finish', value: true, isButton: true),
      ],
    );
    if (result == true) _finishWorkout();
  }

  Future<bool> _onWillPop() async {
    final result = await AppDialog.show<String>(
      context: context,
      title: 'Leave Workout?',
      message: 'Your workout is still in progress. What would you like to do?',
      actions: [
        const AppDialogAction(label: 'Stay', value: 'stay'),
        const AppDialogAction(
          label: 'Discard',
          value: 'discard',
          color: Colors.red,
        ),
        const AppDialogAction(label: 'Finish', value: 'finish', isButton: true),
      ],
    );

    if (result == 'finish') {
      await _finishWorkout();
      return false;
    }
    if (result == 'discard') return true;
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final workout = context.watch<WorkoutProvider>().currentWorkout;

    if (workout == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        appBar: _buildAppBar(),
        body: Column(
          children: [
            _buildWorkoutNameRow(workout),
            if (_showRestTimer)
              RestTimerBanner(
                seconds: 60,
                onFinished: () => setState(() => _showRestTimer = false),
              ),
            Expanded(child: _buildExerciseList(workout)),
            _buildFinishButton(),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Color(0xFF212121)),
        onPressed: () async {
          final shouldPop = await _onWillPop();
          if (shouldPop && mounted) Navigator.pop(context);
        },
      ),
      title: const Text(
        'Active Workout',
        style: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: Color(0xFF212121),
        ),
      ),
      actions: const [
        Padding(
          padding: EdgeInsets.only(right: 16),
          child: Center(child: WorkoutTimer()),
        ),
      ],
    );
  }

  Widget _buildWorkoutNameRow(workout) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  workout.title ?? 'My Workout',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF212121),
                  ),
                ),
                Text(
                  'Started ${_formatTime(workout.startTime)}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF9E9E9E),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.edit_outlined,
              size: 16,
              color: Color(0xFF616161),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseList(workout) {
    final lastPerformance = context
        .watch<WorkoutProvider>()
        .lastPerformance; // ← TOP LEVEL
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ...workout.exercises.map(
          (we) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: WorkoutExerciseCard(
              workoutExercise: we,
              sets: _getSets(we.id),
              lastPerformance:
                  lastPerformance[we.exerciseId] ?? [], // ← USE VARIABLE
              onAddSet: () => _addSet(we.id),
              onInfoTap: () {},
              onSetChanged: (i, updated) => _updateSet(we.id, i, updated),
              onSetToggled: (i) => _toggleSet(we.id, i),
              onSetRemoved: (i) => _removeSet(we.id, i),
            ),
          ),
        ),
        _buildAddExerciseButton(),
      ],
    );
  }

  Widget _buildAddExerciseButton() {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              ExercisePickerScreen(onExercisesSelected: _addExercises),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFBDBDBD), width: 1.5),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, color: Color(0xFF1E88E5), size: 18),
            SizedBox(width: 6),
            Text(
              'Add Exercise',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1E88E5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinishButton() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: _confirmFinish,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1E88E5),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            'Finish Workout',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final local = time.toLocal();
    final h = local.hour;
    final m = local.minute.toString().padLeft(2, '0');
    final period = h >= 12 ? 'PM' : 'AM';
    final hour = h > 12
        ? h - 12
        : h == 0
        ? 12
        : h;
    return '$hour:$m $period';
  }
}
