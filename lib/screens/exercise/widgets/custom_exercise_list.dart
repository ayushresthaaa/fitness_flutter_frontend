import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/exercise/exercise_model.dart';
import '../../../models/exercise/custom_exercise_model.dart';
import '../../../providers/exercise/custom_exercise_provider.dart';
import '../../../widgets/common.dart';
import 'custom_exercise_card.dart';

class CustomExerciseList extends StatelessWidget {
  final List<Exercise> selected;
  final ValueChanged<Exercise> onTap;
  final VoidCallback onCreateTap;
  final ValueChanged<CustomExercise> onEditTap;

  const CustomExerciseList({
    super.key,
    required this.selected,
    required this.onTap,
    required this.onCreateTap,
    required this.onEditTap,
  });

  Exercise _toExercise(CustomExercise custom) {
    return Exercise(
      id: custom.id,
      name: custom.name,
      category: custom.category,
      level: custom.level,
      force: custom.force,
      mechanic: custom.mechanic,
      equipment: custom.equipment,
      primaryMuscles: custom.primaryMuscles,
      secondaryMuscles: custom.secondaryMuscles,
      instructions: custom.instructions,
      images: custom.images,
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CustomExerciseProvider>();

    if (provider.isLoading && provider.exercises.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: kPrimary, strokeWidth: 2),
      );
    }

    if (provider.hasError && provider.exercises.isEmpty) {
      return EmptyState(
        icon: Icons.error_outline,
        title: 'Something went wrong',
        subtitle: provider.error ?? 'Please try again',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      itemCount: provider.exercises.length + 1, // +1 for the Create button
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        if (index == 0) {
          return AddButton(text: 'Create Exercise', onTap: onCreateTap);
        }

        final exercise = provider.exercises[index - 1];
        final asExercise = _toExercise(exercise);
        final isSelected = selected.any((e) => e.id == exercise.id);

        return CustomExerciseCard(
          exercise: exercise,
          isSelected: isSelected,
          onTap: () => onTap(asExercise),
          onEditTap: () => onEditTap(exercise),
        );
      },
    );
  }
}
