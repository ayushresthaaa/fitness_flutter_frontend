import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/routine/routine_model.dart';
import '../../providers/routine/routine_provider.dart';
import '../../providers/exercise/workout_provider.dart';
import '../../widgets/app_dialog.dart';
import '../workout/active_workout_screen.dart';
import 'create_routine_screen.dart';

class RoutineDetailScreen extends StatefulWidget {
  final Routine routine;
  const RoutineDetailScreen({super.key, required this.routine});

  @override
  State<RoutineDetailScreen> createState() => _RoutineDetailScreenState();
}

class _RoutineDetailScreenState extends State<RoutineDetailScreen> {
  @override
  void initState() {
    super.initState();
    // fetch fresh routine data on load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RoutineProvider>().fetchRoutineById(widget.routine.id);
    });
  }

  Future<void> _startRoutine() async {
    final routineProvider = context.read<RoutineProvider>();
    final workoutProvider = context.read<WorkoutProvider>();
    final workout = await routineProvider.startWorkoutFromRoutine(
      widget.routine.id,
    );
    if (workout != null && mounted) {
      workoutProvider.setCurrentWorkout(workout);
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const ActiveWorkoutScreen()),
        (route) => route.isFirst,
      );
    }
  }

  Future<void> _deleteRoutine() async {
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
    if (result == true && mounted) {
      await context.read<RoutineProvider>().deleteRoutine(widget.routine.id);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RoutineProvider>();

    // use fresh data from provider, fall back to passed routine
    final routine = provider.selectedRoutine ?? widget.routine;

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
            onPressed: () =>
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CreateRoutineScreen(routine: routine),
                  ),
                ).then((_) {
                  // refresh after coming back from edit
                  context.read<RoutineProvider>().fetchRoutineById(routine.id);
                }),
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
          Expanded(
            child: provider.isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF1E88E5)),
                  )
                : routine.exercises.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.fitness_center,
                          size: 48,
                          color: Color(0xFF9E9E9E),
                        ),
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
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF9E9E9E),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: routine.exercises.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final re = routine.exercises[index];
                      final exercise = re.exercise;
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(
                          exercise?.name ?? 'Exercise',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF212121),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _startRoutine,
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
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: OutlinedButton(
                    onPressed: _deleteRoutine,
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
          ),
        ],
      ),
    );
  }
}
