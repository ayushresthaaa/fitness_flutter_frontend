import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/routine/routine_model.dart';
import '../../../providers/routine/routine_provider.dart';
import '../../../widgets/app_dialog.dart';
import '../../../widgets/common.dart';
import 'routine_exercise_card.dart';

// Shows the list of exercises in a routine
// isReadOnly = true when routine was created by trainer - hides remove button
class RoutineExerciseList extends StatelessWidget {
  final List<RoutineExercise> exercises;
  final bool isReadOnly;

  const RoutineExerciseList({
    super.key,
    required this.exercises,
    required this.isReadOnly,
  });

  // Remove an exercise after confirmation dialog
  Future<void> _removeExercise(
    BuildContext context,
    String routineExerciseId,
  ) async {
    final confirmed = await AppDialog.show<bool>(
      context: context,
      title: 'Remove Exercise?',
      message: 'This exercise will be removed from the routine.',
      actions: [
        const AppDialogAction(label: 'Cancel', value: false, color: kPrimary),
        const AppDialogAction(label: 'Remove', value: true, color: kRed),
      ],
    );
    if (confirmed != true) return;
    await context.read<RoutineProvider>().removeExerciseFromRoutine(
      routineExerciseId,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Show empty state if no exercises
    if (exercises.isEmpty) {
      return const EmptyState(
        icon: Icons.fitness_center,
        title: 'No exercises yet',
        subtitle: 'Tap Add Exercise to get started',
      );
    }

    // Build a simple list of exercise cards
    final List<Widget> items = [];

    for (final ex in exercises) {
      items.add(
        RoutineExerciseCard(
          routineExercise: ex,
          // Hide remove button in read-only mode
          onRemove: isReadOnly
              ? null
              : () => _removeExercise(context, ex.id),
        ),
      );
      items.add(const SizedBox(height: 10));
    }

    return Column(
      children: items,
    );
  }
}