import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/exercise/exercise_provider.dart';
import '../../../models/exercise/exercise_model.dart';
import 'exercise_card.dart';

class ExerciseList extends StatefulWidget {
  final List<Exercise> selectedExercises;
  final String? search;
  final String? selectedMuscle;
  final String? selectedLevel;
  final ValueChanged<Exercise> onExerciseTap;
  final ValueChanged<Exercise> onExerciseAdd;

  const ExerciseList({
    super.key,
    required this.selectedExercises,
    required this.onExerciseTap,
    required this.onExerciseAdd,
    this.search,
    this.selectedMuscle,
    this.selectedLevel,
  });

  @override
  State<ExerciseList> createState() => _ExerciseListState();
}

class _ExerciseListState extends State<ExerciseList> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<ExerciseProvider>().loadMoreExercises(
        search: widget.search,
        muscleGroup: widget.selectedMuscle,
        level: widget.selectedLevel,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ExerciseProvider>(
      builder: (context, provider, _) {
        // Error state
        if (provider.hasError && provider.exercises.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Color(0xFF6B7280),
                  size: 40,
                ),
                const SizedBox(height: 8),
                Text(
                  provider.error ?? 'Something went wrong',
                  style: const TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () =>
                      context.read<ExerciseProvider>().fetchExercises(
                        search: widget.search,
                        muscleGroup: widget.selectedMuscle,
                        level: widget.selectedLevel,
                      ),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        // Initial loading state
        if (provider.isLoading && provider.exercises.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(
              color: Color(0xFF2563EB),
              strokeWidth: 2,
            ),
          );
        }

        // Empty state
        if (provider.exercises.isEmpty) {
          return const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.fitness_center, color: Color(0xFF6B7280), size: 40),
                SizedBox(height: 8),
                Text(
                  'No exercises found',
                  style: TextStyle(color: Color(0xFF6B7280), fontSize: 14),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          controller: _scrollController,
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          itemCount: provider.exercises.length + (provider.hasMore ? 1 : 0),
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            // Bottom loader
            if (index == provider.exercises.length) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF2563EB),
                    strokeWidth: 2,
                  ),
                ),
              );
            }

            final exercise = provider.exercises[index];
            final isSelected = widget.selectedExercises.any(
              (e) => e.id == exercise.id,
            );

            return ExerciseCard(
              exercise: exercise,
              isSelected: isSelected,
              onTap: () => widget.onExerciseTap(exercise),
              onAdd: () => widget.onExerciseAdd(exercise),
            );
          },
        );
      },
    );
  }
}
