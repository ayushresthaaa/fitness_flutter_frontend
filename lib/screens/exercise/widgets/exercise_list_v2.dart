import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/exercise/exercise_model.dart';
import '../../../providers/exercise/exercise_provider.dart';
import '../../../widgets/common.dart';
import 'exercise_card_v2.dart';

// Scrollable exercise list with infinite scroll and loading/error/empty states
class ExerciseListV2 extends StatelessWidget {
  final List<Exercise> selected;
  final ScrollController scrollController;
  final ValueChanged<Exercise> onTap;

  const ExerciseListV2({
    super.key,
    required this.selected,
    required this.scrollController,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ExerciseProvider>();

    // Show spinner on first load
    if (provider.isLoading && provider.exercises.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: kPrimary, strokeWidth: 2),
      );
    }

    // Show error if fetch failed and list is empty
    if (provider.hasError && provider.exercises.isEmpty) {
      return EmptyState(
        icon: Icons.error_outline,
        title: 'Something went wrong',
        subtitle: provider.error ?? 'Please try again',
      );
    }

    // Show empty state if no results
    if (provider.exercises.isEmpty) {
      return const EmptyState(
        icon: Icons.fitness_center,
        title: 'No exercises found',
        subtitle: 'Try a different search or filter',
      );
    }

    return ListView.separated(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      itemCount: provider.exercises.length + (provider.hasMore ? 1 : 0),
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        // Show loader at the bottom while fetching next page
        if (index == provider.exercises.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Center(
              child: CircularProgressIndicator(color: kPrimary, strokeWidth: 2),
            ),
          );
        }

        final exercise = provider.exercises[index];
        final isSelected = selected.any((e) => e.id == exercise.id);

        return ExerciseCardV2(
          exercise: exercise,
          isSelected: isSelected,
          onTap: () => onTap(exercise),
        );
      },
    );
  }
}
