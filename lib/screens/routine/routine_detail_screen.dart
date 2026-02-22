import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/routine/routine_model.dart';
import '../../providers/routine/routine_provider.dart';
import '../../providers/exercise/workout_provider.dart';
import '../../widgets/app_dialog.dart';
import '../workout/active_workout_screen.dart';
import 'create_routine_screen.dart';

class RoutineDetailScreen extends StatelessWidget {
  final Routine routine;

  const RoutineDetailScreen({super.key, required this.routine});

  Future<void> _startRoutine(BuildContext context) async {
    final routineProvider = context.read<RoutineProvider>();
    final workoutProvider = context.read<WorkoutProvider>();

    final workout = await routineProvider.startWorkoutFromRoutine(routine.id);

    if (workout != null && context.mounted) {
      workoutProvider.setCurrentWorkout(workout);
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const ActiveWorkoutScreen()),
        (route) => route.isFirst,
      );
    }
  }

  Future<void> _deleteRoutine(BuildContext context) async {
    final result = await AppDialog.show<bool>(
      context: context,
      title: 'Delete Routine?',
      message: 'This routine will be permanently deleted.',
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
      await context.read<RoutineProvider>().deleteRoutine(routine.id);
      Navigator.pop(context);
    }
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
        title: Text(
          routine.name,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: Color(0xFF212121),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CreateRoutineScreen(routine: routine),
              ),
            ),
            child: const Text(
              'Edit',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E88E5),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(child: _buildExerciseList()),
          _buildBottomButtons(context),
        ],
      ),
    );
  }

  Widget _buildExerciseList() {
    if (routine.exercises.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.fitness_center, size: 48, color: Color(0xFF9E9E9E)),
            SizedBox(height: 12),
            Text(
              'No exercises yet',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFF9E9E9E),
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Tap Edit to add exercises',
              style: TextStyle(fontSize: 13, color: Color(0xFF9E9E9E)),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: routine.exercises.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final re = routine.exercises[index];
        return _RoutineExerciseCard(routineExercise: re);
      },
    );
  }

  Widget _buildBottomButtons(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      child: Column(
        children: [
          // Start Workout button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () => _startRoutine(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E88E5),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Start Workout',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Delete button
          SizedBox(
            width: double.infinity,
            height: 44,
            child: OutlinedButton(
              onPressed: () => _deleteRoutine(context),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFFFCDD2)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Delete Routine',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFF44336),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoutineExerciseCard extends StatelessWidget {
  final RoutineExercise routineExercise;

  const _RoutineExerciseCard({required this.routineExercise});

  @override
  Widget build(BuildContext context) {
    final exercise = routineExercise.exercise;

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
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
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
                if (meta.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    meta,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF9E9E9E),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
