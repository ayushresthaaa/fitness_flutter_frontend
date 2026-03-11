import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/routine/routine_model.dart';
import '../../providers/routine/routine_provider.dart';
import '../../widgets/common.dart';
import 'create_routine_screen.dart';
import 'routine_detail_screenV2.dart';
import 'widgets/routine_card.dart';
import '../workout/active_workout_screen_v2.dart';


class FilteredRoutineScreen extends StatelessWidget {
  final String filter;

  const FilteredRoutineScreen({super.key, required this.filter});

  // Returns the screen title based on the filter
  String _getTitle() {
    if (filter == 'mine') {
      return 'My Routines';
    } else if (filter == 'trainer') {
      return 'From Trainer';
    } else if (filter == 'reviewed') {
      return 'Reviewed by Trainer';
    }
    return 'Routines';
  }

  // Returns the empty state message based on the filter
  String _getEmptyTitle() {
    if (filter == 'mine') {
      return 'No routines yet';
    } else if (filter == 'trainer') {
      return 'No trainer routines yet';
    } else if (filter == 'reviewed') {
      return 'No reviewed routines yet';
    }
    return 'No routines found';
  }

  // Returns the empty state subtitle based on the filter
  String _getEmptySubtitle() {
    if (filter == 'mine') {
      return 'Tap + to create your first routine';
    } else if (filter == 'trainer') {
      return 'Your trainer has not assigned any routines yet';
    } else if (filter == 'reviewed') {
      return 'Send a routine for review to get feedback from your trainer';
    }
    return '';
  }

  // Filters the full routines list based on the filter string
  List<Routine> _getFilteredRoutines(List<Routine> allRoutines) {
    if (filter == 'mine') {
      // Show only routines the user created themselves
      final List<Routine> result = [];
      for (final routine in allRoutines) {
        if (routine.createdByTrainer == false) {
          result.add(routine);
        }
      }
      return result;
    } else if (filter == 'trainer') {
      // Show only routines the trainer created for the user
      final List<Routine> result = [];
      for (final routine in allRoutines) {
        if (routine.createdByTrainer == true) {
          result.add(routine);
        }
      }
      return result;
    } else if (filter == 'reviewed') {
      // Show only routines that have been reviewed by the trainer
      final List<Routine> result = [];
      for (final routine in allRoutines) {
        if (routine.reviewStatus == 'reviewed') {
          result.add(routine);
        }
      }
      return result;
    }
    return allRoutines;
  }

  void _createRoutine(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CreateRoutineScreen()),
    );

    // Refresh the full list when coming back
    if (context.mounted) {
      context.read<RoutineProvider>().fetchRoutines();
    }
  }

  // Start a workout from a routine
  Future<void> _startWorkout(BuildContext context, String routineId) async {
    final provider = context.read<RoutineProvider>();
    await provider.fetchRoutineById(routineId);

    final routine = provider.selectedRoutine;
    if (routine == null) return;

    // Build the prefilled exercises list for the active workout screen
    final List<Map<String, dynamic>> prefilled = [];
    for (final re in routine.exercises) {
      if (re.exercise == null) continue;
      final String localId =
          '${re.exerciseId}_${DateTime.now().millisecondsSinceEpoch}';
      prefilled.add({
        'localId': localId,
        'exercise': re.exercise!,
        'supersetGroup': re.supersetGroup,
        'sets': re.sets,
      });
    }

    if (context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ActiveWorkoutScreenV2(
            workoutTitle: routine.name,
            prefilledExercises: prefilled,
            routineId: routine.id,
            originalExercises: routine.exercises
                .map(
                  (e) => {
                    'exerciseId': e.exerciseId,
                    'name': e.exercise?.name ?? '',
                  },
                )
                .toList(),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppTopBar(
        title: _getTitle(),
        actions: [
          // Only show the + button for the 'mine' filter
          if (filter == 'mine')
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: GestureDetector(
                onTap: () => _createRoutine(context),
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: kPrimary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.add, color: kWhite, size: 20),
                ),
              ),
            ),
        ],
      ),
      body: Consumer<RoutineProvider>(
        builder: (context, provider, _) {
          // Show loading spinner if routines are still being fetched
          if (provider.isLoading && provider.routines.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          // Filter the routines list based on the filter string
          final List<Routine> filteredRoutines = _getFilteredRoutines(
            provider.routines,
          );

          // Show empty state if no routines match the filter
          if (filteredRoutines.isEmpty) {
            return EmptyState(
              icon: Icons.list_alt_rounded,
              title: _getEmptyTitle(),
              subtitle: _getEmptySubtitle(),
            );
          }

          // Show the filtered list of routine cards
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: filteredRoutines.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, index) {
              final Routine routine = filteredRoutines[index];

              return RoutineCard(
                routine: routine,
                onTap: () async {
                  // Load the full routine detail then open detail screen
                  provider.fetchRoutineById(routine.id);
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const RoutineDetailScreen(),
                    ),
                  );
                  // Refresh when coming back in case something changed
                  if (context.mounted) {
                    context.read<RoutineProvider>().fetchRoutines();
                  }
                },
                onStart: () => _startWorkout(context, routine.id),
              );
            },
          );
        },
      ),
    );
  }
}
